// Load environment variables from .env file (for emulator)
require("dotenv").config();

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const vision = require("@google-cloud/vision");
const algoliasearch = require("algoliasearch");
const axios = require("axios");

admin.initializeApp();
const db = admin.firestore();
const storage = admin.storage();

// Algolia config must be set via: firebase functions:config:set algolia.admin_key="..." algolia.app_id="..." algolia.index="items_idx"
const ALGOLIA_ADMIN_KEY =
  functions.config().algolia?.admin_key || process.env.ALGOLIA_ADMIN_KEY;
const ALGOLIA_APP_ID =
  functions.config().algolia?.app_id || process.env.ALGOLIA_APP_ID;
const ALGOLIA_INDEX =
  functions.config().algolia?.index || process.env.ALGOLIA_INDEX || "items_idx";

let algoliaClient = null;
if (ALGOLIA_ADMIN_KEY && ALGOLIA_APP_ID) {
  algoliaClient = algoliasearch(ALGOLIA_APP_ID, ALGOLIA_ADMIN_KEY);
}

const visionClient = new vision.ImageAnnotatorClient();

/**
 * menuProcessor
 * Trigger: onFinalize (file uploaded to Storage)
 * Flow: download image, run OCR via Vision, parse simple name+price pairs,
 * write parsed rows into `items_staging/{autoId}` with metadata for owner verification.
 */
exports.menuProcessor = functions.storage
  .object("qrmenufinder.firebasestorage.app")
  .onFinalize(async (object) => {
    const filePath = object.name;
    const contentType = object.contentType || "";
    if (!filePath) return null;

    // Only process images
    if (!contentType.startsWith("image/")) return null;

    // Extract restaurantId from file path: menus/{restaurantId}/{fileName}
    const pathParts = filePath.split("/");
    if (pathParts.length < 2 || pathParts[0] !== "menus") {
      console.warn("Invalid file path format, skipping:", filePath);
      return null;
    }
    const restaurantId = pathParts[1];

    // Get metadata
    const metadata = object.metadata || {};
    const uploadedBy = metadata.uploadedBy;

    console.log("🔍 Processing menu image:", {
      filePath,
      restaurantId,
      uploadedBy,
      contentType,
    });

    // Get public gs:// path
    const gcsUri = `gs://${object.bucket}/${filePath}`;

    try {
      const [result] = await visionClient.textDetection(gcsUri);
      const detections = result.textAnnotations;
      const fullText =
        detections && detections.length ? detections[0].description : "";

      console.log("📝 OCR detected text length:", fullText.length);

      // VERY simple parser: split lines, look for price-like tokens (e.g., 12.50, 12,50, 12 TL)
      const lines = fullText
        .split(/\r?\n/)
        .map((l) => l.trim())
        .filter((l) => l.length > 0);
      const parsed = [];
      const priceRegex = /([0-9]{1,4}(?:[.,][0-9]{1,2})?)\s*(tl|₺|try)?/i;

      for (const line of lines) {
        const m = line.match(priceRegex);
        if (m) {
          // assume the rest is the name
          const priceRaw = m[1].replace(",", ".");
          const price = parseFloat(priceRaw);
          const name = line.replace(m[0], "").trim() || "item";
          parsed.push({ name, price, raw: line, currency: "TRY" });
        }
      }

      console.log("✅ Parsed items count:", parsed.length);

      // Write parsed items to staging collection
      const batch = db.batch();
      const meta = {
        sourcePath: filePath,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        uploadedBy: uploadedBy || "unknown",
      };

      for (const item of parsed) {
        const ref = db.collection("items_staging").doc();
        batch.set(ref, {
          ...item,
          meta,
          restaurantId: restaurantId, // IMPORTANT: Store restaurantId for filtering
        });
      }

      if (parsed.length) {
        await batch.commit();
        console.log(
          `✅ Successfully wrote ${parsed.length} items to items_staging`
        );
      } else {
        console.warn("⚠️ No items parsed from OCR text");
      }

      return { parsedCount: parsed.length };
    } catch (err) {
      console.error("❌ menuProcessor error", err);
      throw err;
    }
  });

/**
 * algoliaSync
 * Trigger: onWrite for /items/{itemId}
 * Flow: ONLY index approved items into Algolia, remove if deleted or status changed to non-approved
 */
exports.algoliaSync = functions.firestore
  .document("items/{itemId}")
  .onWrite(async (change, context) => {
    if (!algoliaClient) {
      console.warn(
        "Algolia client not configured. Set functions config algolia.admin_key & algolia.app_id"
      );
      return null;
    }

    const index = algoliaClient.initIndex(ALGOLIA_INDEX);
    const before = change.before.exists ? change.before.data() : null;
    const after = change.after.exists ? change.after.data() : null;
    const objectID = context.params.itemId;

    try {
      // Only index approved items
      const isAfterApproved = after && after.status === "approved";
      const wasBeforeApproved = before && before.status === "approved";

      if (isAfterApproved) {
        // Index or update approved item
        const toIndex = { ...after, objectID };
        await index.saveObject(toIndex);
        console.log(`✅ Indexed approved item ${objectID}`);
        return null;
      }

      if (wasBeforeApproved && !isAfterApproved) {
        // Item was approved but now is not (rejected/pending/deleted) - remove from index
        await index.deleteObject(objectID);
        console.log(`🗑️ Removed non-approved item ${objectID} from index`);
        return null;
      }

      // Item is pending/rejected - don't index
      console.log(
        `⏸️ Skipping non-approved item ${objectID} (status: ${
          after?.status || "deleted"
        })`
      );
      return null;
    } catch (err) {
      console.error("algoliaSync error", err);
      throw err;
    }
  });

/**
 * promoteToLive
 * Callable function that promotes a staging item to live items collection.
 * - ANY authenticated user can add items (user contribution model)
 * - Items are created with status='pending' and await admin approval
 * - If data.itemId is provided, updates existing item (append previous price if changed)
 * - Otherwise creates a new item document
 * - Updates restaurants.lastSyncedAt
 * - Deletes the staging document
 * - Includes idempotency check
 *
 * Expected data: { stagingId: string, itemId?: string, restaurantId: string, idempotencyKey?: string }
 */
exports.promoteToLive = functions.https.onCall(async (data, context) => {
  if (!context.auth || !context.auth.uid) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Authentication required"
    );
  }

  // App Check verification - Required for security
  // DEVELOPMENT MODE: App Check bypassed - enable in production!
  if (!context.app) {
    console.warn(
      "⚠️ App Check verification failed for uid:",
      context.auth.uid,
      "- Bypassing in development mode"
    );
    // throw new functions.https.HttpsError('failed-precondition', 'App Check verification required. Please update your app.');
  }

  const uid = context.auth.uid;

  // Debug logging
  console.log("🔍 promoteToLive called with:", {
    uid: context.auth.uid,
    stagingId: data.stagingId,
    restaurantId: data.restaurantId,
    hasIdempotencyKey: !!data.idempotencyKey,
    hasUpdatedName: !!data.updatedName,
    hasUpdatedPrice: !!data.updatedPrice,
    updatedName: data.updatedName,
    updatedPrice: data.updatedPrice,
    updatedCurrency: data.updatedCurrency
  });
  const stagingId = data.stagingId;
  const idempotencyKey = data.idempotencyKey;

  if (!stagingId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "stagingId is required"
    );
  }

  // Idempotency check
  if (idempotencyKey) {
    const idemRef = db.collection("idempotency").doc(idempotencyKey);
    const idemSnap = await idemRef.get();
    if (idemSnap.exists) {
      console.log("Duplicate request detected, returning success");
      return { success: true, deduped: true };
    }
    // Set idempotency record
    await idemRef.set({
      uid: uid,
      stagingId: stagingId,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  const stagingRef = db.collection("items_staging").doc(stagingId);
  const stagingSnap = await stagingRef.get();
  if (!stagingSnap.exists) {
    throw new functions.https.HttpsError(
      "not-found",
      "staging document not found"
    );
  }

  const staging = stagingSnap.data();
  console.log("📋 Staging data:", staging);
  
  const restaurantId = staging.restaurantId || data.restaurantId;
  if (!restaurantId) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "restaurantId not present in staging document"
    );
  }

  // Verify restaurant exists (no owner check needed - user contribution model)
  const restaurantRef = db.collection("restaurants").doc(restaurantId);
  const restaurantSnap = await restaurantRef.get();
  if (!restaurantSnap.exists) {
    throw new functions.https.HttpsError("not-found", "restaurant not found");
  }

  const itemIdToUpdate = data.itemId;

  // Get restaurant data for denormalized fields
  const restaurant = restaurantSnap.data();
  console.log("🏪 Restaurant data:", {
    name: restaurant.name,
    city: restaurant.city,
    district: restaurant.district
  });

  try {
    await db.runTransaction(async (t) => {
      const itemsCol = db.collection("items");

      // Prepare item data with user contribution fields
      // Remove unnecessary fields from staging data
      const { meta, raw, ...stagingData } = staging;

      // Use updated values if provided, otherwise use staging data
      const finalName = data.updatedName || stagingData.name;
      const finalPrice =
        data.updatedPrice !== undefined ? data.updatedPrice : stagingData.price;
      const finalCurrency =
        data.updatedCurrency || stagingData.currency || "TRY";

      // Validate required data
      if (!finalName || finalPrice == null || finalPrice <= 0) {
        throw new Error(
          `Invalid item data: name="${finalName}", price="${finalPrice}"`
        );
      }

      // Denormalize restaurant data (city, district) - required for items collection
      const itemData = {
        name: finalName,
        price: finalPrice,
        currency: finalCurrency,
        restaurantId: restaurantId,
        menuId: data.menuId || restaurantId,
        restaurantName: restaurant.name || "Unknown Restaurant",
        city: restaurant.city || "",
        district: restaurant.district || "",
        searchableText: `${finalName || ""} ${restaurant.name || ""} ${
          restaurant.city || ""
        } ${restaurant.district || ""}`.toLowerCase(),
        contributedBy: uid,
        status: "pending",
        reportCount: 0,
      };

      if (itemIdToUpdate) {
        const targetRef = itemsCol.doc(itemIdToUpdate);
        const targetSnap = await t.get(targetRef);
        if (!targetSnap.exists) {
          // create with provided id
          t.set(targetRef, {
            ...itemData,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            previousPrices: staging.previousPrices || [],
          });
        } else {
          const target = targetSnap.data() || {};
          const prevPrices = Array.isArray(target.previousPrices)
            ? target.previousPrices.slice()
            : [];
          // if price changed, append previous (limit to 50 items)
          if (
            staging.price != null &&
            target.price != null &&
            staging.price !== target.price
          ) {
            prevPrices.push({
              price: target.price,
              date:
                target.updatedAt ||
                admin.firestore.FieldValue.serverTimestamp(),
            });
          }
          t.update(targetRef, {
            ...itemData,
            previousPrices: prevPrices.slice(-50), // Keep last 50 prices
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
      } else {
        // create new item
        const newRef = itemsCol.doc();
        t.set(newRef, {
          ...itemData,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          previousPrices: staging.previousPrices || [],
        });
      }

      // update restaurant lastSyncedAt
      t.update(restaurantRef, {
        lastSyncedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // delete staging doc
      t.delete(stagingRef);
    });

    return { success: true };
  } catch (err) {
    console.error("❌ promoteToLive error:", err);
    console.error("Error details:", {
      message: err.message,
      code: err.code,
      stack: err.stack,
      stagingId: data.stagingId,
      restaurantId: data.restaurantId,
      uid: uid,
    });

    // Clean up idempotency record on error if it was created
    if (idempotencyKey) {
      try {
        await db.collection("idempotency").doc(idempotencyKey).delete();
        console.log("Cleaned up idempotency record after error");
      } catch (cleanupErr) {
        console.warn("Failed to cleanup idempotency record:", cleanupErr);
      }
    }

    // Provide more specific error messages
    if (err.code === "functions/not-found") {
      throw new functions.https.HttpsError(
        "not-found",
        "Staging item not found"
      );
    } else if (err.code === "functions/permission-denied") {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Permission denied"
      );
    } else if (err.code === "functions/failed-precondition") {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Restaurant verification failed"
      );
    } else if (err.message && err.message.includes("Invalid staging data")) {
      throw new functions.https.HttpsError("invalid-argument", err.message);
    } else {
      throw new functions.https.HttpsError(
        "internal",
        `internalError promoting item: ${err.message}`
      );
    }
  }
});

/**
 * reviewSentiment
 * Triggered when a review is created or updated
 * Analyzes sentiment using Cloud NLP (placeholder - requires @google-cloud/language)
 */
exports.reviewSentiment = functions.firestore
  .document("reviews/{reviewId}")
  .onCreate(async (snap, context) => {
    const review = snap.data();
    const text = review.text || "";

    if (!text || text.length < 10) {
      return null; // Skip short reviews
    }

    try {
      // Placeholder for Cloud NLP integration
      // const language = require('@google-cloud/language');
      // const client = new language.LanguageServiceClient();
      // const document = { content: text, type: 'PLAIN_TEXT' };
      // const [result] = await client.analyzeSentiment({ document });
      // const sentimentScore = result.documentSentiment.score;

      // For now, return a mock sentiment
      const sentimentScore = 0.0; // -1.0 to 1.0

      await snap.ref.update({
        sentimentScore: sentimentScore,
        sentimentAnalyzedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return { success: true };
    } catch (err) {
      console.error("reviewSentiment error", err);
      return null;
    }
  });

/**
 * setUserRole
 * Callable function to set custom claims for user roles
 * This enables Storage rules to check roles via request.auth.token.role
 *
 * Expected data: { userId: string, role: 'user' | 'owner' | 'admin' | 'pendingOwner' }
 */
exports.setUserRole = functions.https.onCall(async (data, context) => {
  // Only admins can set roles (or users can set their own to 'user' on first signup)
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Authentication required"
    );
  }

  // App Check verification - Required for security
  // DEVELOPMENT MODE: App Check bypassed - enable in production!
  if (!context.app) {
    console.warn(
      "⚠️ App Check verification failed for uid:",
      context.auth.uid,
      "- Bypassing in development mode"
    );
    // throw new functions.https.HttpsError('failed-precondition', 'App Check verification required. Please update your app.');
  }

  const { userId, role } = data;

  if (!userId || !role) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "userId and role are required"
    );
  }

  // Valid roles
  const validRoles = ["user", "owner", "admin", "pendingOwner"];
  if (!validRoles.includes(role)) {
    throw new functions.https.HttpsError("invalid-argument", "Invalid role");
  }

  // Check permissions: admin can set any role, user can only set their own to 'user'
  const callerUid = context.auth.uid;
  let isAdmin = false;

  try {
    const userSnap = await db.collection("users").doc(callerUid).get();
    if (userSnap.exists) {
      const userData = userSnap.data();
      isAdmin = userData && userData.role === "admin";
    }
  } catch (e) {
    console.warn("Error checking admin status:", e);
  }

  // If not admin, can only set own role to 'user'
  if (!isAdmin && (userId !== callerUid || role !== "user")) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Only admins can change user roles"
    );
  }

  try {
    // Set custom claims
    await admin.auth().setCustomUserClaims(userId, { role });
    console.log(`Set role '${role}' for user ${userId}`);

    return { success: true, role };
  } catch (err) {
    console.error("setUserRole error:", err);
    throw new functions.https.HttpsError("internal", "Failed to set user role");
  }
});

/**
 * syncUserRoleClaims
 * Firestore trigger that automatically syncs role changes to custom claims
 * Triggers when /users/{userId} document is created or updated
 */
exports.syncUserRoleClaims = functions.firestore
  .document("users/{userId}")
  .onWrite(async (change, context) => {
    const userId = context.params.userId;
    const after = change.after.exists ? change.after.data() : null;

    if (!after) {
      // User deleted - remove custom claims
      try {
        await admin.auth().setCustomUserClaims(userId, null);
        console.log(`Cleared custom claims for deleted user ${userId}`);
      } catch (err) {
        console.error("Error clearing custom claims:", err);
      }
      return null;
    }

    const role = after.role || "user";

    try {
      // Get current custom claims
      const user = await admin.auth().getUser(userId);
      const currentClaims = user.customClaims || {};

      // Only update if role changed
      if (currentClaims.role !== role) {
        await admin.auth().setCustomUserClaims(userId, { role });
        console.log(`Auto-synced role '${role}' for user ${userId}`);
      }
    } catch (err) {
      console.error("syncUserRoleClaims error:", err);
      // Don't throw - this is best effort
    }

    return null;
  });

/**
 * cleanupStagingItems
 * Scheduled function to delete expired staging items (older than 7 days)
 * Schedule: Run daily at midnight
 */
exports.cleanupStagingItems = functions.pubsub
  .schedule("0 0 * * *")
  .timeZone("UTC")
  .onRun(async (context) => {
    const sevenDaysAgo = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
    );

    const query = db
      .collection("items_staging")
      .where("createdAt", "<", sevenDaysAgo)
      .limit(500);

    const snapshot = await query.get();
    const batch = db.batch();
    let count = 0;

    snapshot.forEach((doc) => {
      batch.delete(doc.ref);
      count++;
    });

    if (count > 0) {
      await batch.commit();
      console.log(`Cleaned up ${count} expired staging items`);
    }

    return null;
  });

/**
 * approveItem
 * Admin-only callable function to approve a pending item
 * Changes status from 'pending' to 'approved'
 *
 * Expected data: { itemId: string }
 */
exports.approveItem = functions.https.onCall(async (data, context) => {
  if (!context.auth || !context.auth.uid) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Authentication required"
    );
  }

  const uid = context.auth.uid;
  const { itemId } = data;

  if (!itemId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "itemId is required"
    );
  }

  // Verify admin role
  let isAdmin = false;
  try {
    const userSnap = await db.collection("users").doc(uid).get();
    if (userSnap.exists) {
      const u = userSnap.data();
      if (u && u.role === "admin") isAdmin = true;
    }
  } catch (e) {
    console.warn("failed to read user role", e);
  }

  if (!isAdmin) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Only admins can approve items"
    );
  }

  try {
    await db.collection("items").doc(itemId).update({
      status: "approved",
      approvedBy: uid,
      approvedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`✅ Item ${itemId} approved by admin ${uid}`);
    return { success: true };
  } catch (err) {
    console.error("approveItem error:", err);
    throw new functions.https.HttpsError("internal", "Failed to approve item");
  }
});

/**
 * rejectItem
 * Admin-only callable function to reject a pending item
 * Changes status from 'pending' to 'rejected'
 *
 * Expected data: { itemId: string, reason?: string }
 */
exports.rejectItem = functions.https.onCall(async (data, context) => {
  if (!context.auth || !context.auth.uid) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Authentication required"
    );
  }

  const uid = context.auth.uid;
  const { itemId, reason } = data;

  if (!itemId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "itemId is required"
    );
  }

  // Verify admin role
  let isAdmin = false;
  try {
    const userSnap = await db.collection("users").doc(uid).get();
    if (userSnap.exists) {
      const u = userSnap.data();
      if (u && u.role === "admin") isAdmin = true;
    }
  } catch (e) {
    console.warn("failed to read user role", e);
  }

  if (!isAdmin) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Only admins can reject items"
    );
  }

  try {
    const updateData = {
      status: "rejected",
      rejectedBy: uid,
      rejectedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    if (reason) {
      updateData.rejectionReason = reason;
    }

    await db.collection("items").doc(itemId).update(updateData);

    console.log(`❌ Item ${itemId} rejected by admin ${uid}`);
    return { success: true };
  } catch (err) {
    console.error("rejectItem error:", err);
    throw new functions.https.HttpsError("internal", "Failed to reject item");
  }
});

/**
 * reportItem
 * User callable function to report an item (spam, wrong price, etc.)
 * Increments reportCount and stores report details
 *
 * Expected data: { itemId: string, reason: string, details?: string }
 */
exports.reportItem = functions.https.onCall(async (data, context) => {
  if (!context.auth || !context.auth.uid) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Authentication required"
    );
  }

  const uid = context.auth.uid;
  const { itemId, reason, details } = data;

  if (!itemId || !reason) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "itemId and reason are required"
    );
  }

  const validReasons = [
    "wrong_price",
    "spam",
    "inappropriate",
    "duplicate",
    "other",
  ];
  if (!validReasons.includes(reason)) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Invalid report reason"
    );
  }

  try {
    // Check if user already reported this item
    const existingReport = await db
      .collection("item_reports")
      .where("itemId", "==", itemId)
      .where("reportedBy", "==", uid)
      .limit(1)
      .get();

    if (!existingReport.empty) {
      throw new functions.https.HttpsError(
        "already-exists",
        "You have already reported this item"
      );
    }

    await db.runTransaction(async (t) => {
      const itemRef = db.collection("items").doc(itemId);
      const itemSnap = await t.get(itemRef);

      if (!itemSnap.exists) {
        throw new functions.https.HttpsError("not-found", "Item not found");
      }

      const item = itemSnap.data();
      const currentReportCount = item.reportCount || 0;

      // Increment report count
      t.update(itemRef, {
        reportCount: admin.firestore.FieldValue.increment(1),
      });

      // Create report document
      const reportRef = db.collection("item_reports").doc();
      t.set(reportRef, {
        itemId: itemId,
        reportedBy: uid,
        reason: reason,
        details: details || "",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // If reportCount exceeds threshold (e.g., 3), auto-flag for admin review
      if (currentReportCount + 1 >= 3) {
        t.update(itemRef, {
          status: "flagged", // Special status for heavily reported items
        });
        console.log(
          `🚩 Item ${itemId} auto-flagged after ${
            currentReportCount + 1
          } reports`
        );
      }
    });

    console.log(`📢 Item ${itemId} reported by user ${uid} for: ${reason}`);
    return { success: true };
  } catch (err) {
    console.error("reportItem error:", err);
    if (err.code) throw err; // Re-throw HttpsError
    throw new functions.https.HttpsError("internal", "Failed to report item");
  }
});

/**
 * addRestaurantFromPlaces
 * Callable function to add a restaurant from Google Places to Firestore
 * - Fetches full place details from Google Places API
 * - Creates restaurant document with contributedBy field
 * - Uses placeId as document ID to prevent duplicates
 *
 * Expected data: { placeId: string }
 */
exports.addRestaurantFromPlaces = functions.https.onCall(
  async (data, context) => {
    if (!context.auth || !context.auth.uid) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Authentication required"
      );
    }

    const uid = context.auth.uid;
    const { placeId } = data;

    if (!placeId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "placeId is required"
      );
    }

    // Get Google Places API key
    const apiKey =
      process.env.GOOGLE_PLACES_API_KEY ||
      functions.config().google?.places_api_key;

    if (!apiKey) {
      console.error("❌ Google Places API key not configured");
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Google Places API key not configured"
      );
    }

    console.log("🏪 addRestaurantFromPlaces called:", { placeId, uid });

    try {
      // Check if restaurant already exists
      const existingRestaurant = await db
        .collection("restaurants")
        .doc(placeId)
        .get();
      if (existingRestaurant.exists) {
        console.log("⚠️ Restaurant already exists:", placeId);
        return {
          success: true,
          alreadyExists: true,
          restaurantId: placeId,
        };
      }

      // Fetch place details from Google Places API
      const response = await axios.get(
        "https://maps.googleapis.com/maps/api/place/details/json",
        {
          params: {
            place_id: placeId,
            fields:
              "name,formatted_address,geometry,rating,formatted_phone_number,website,opening_hours,types",
            key: apiKey,
          },
        }
      );

      if (response.data.status !== "OK") {
        console.error("❌ Google Places API error:", response.data);
        throw new functions.https.HttpsError(
          "internal",
          `Google Places API error: ${response.data.status}`
        );
      }

      const place = response.data.result;
      const location = place.geometry?.location;

      if (!location) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "Place does not have valid location data"
        );
      }

      // Calculate geohash for location queries
      const geohash = require("ngeohash");
      const hash = geohash.encode(location.lat, location.lng, 9);

      // Extract city and district from address components (if available)
      let city = null;
      let district = null;

      // Parse address for Turkey-specific city/district
      const addressParts = place.formatted_address?.split(",") || [];
      if (addressParts.length >= 2) {
        // Last part is usually country, second-to-last is city/postal
        const cityPart = addressParts[addressParts.length - 2]?.trim();
        if (cityPart) {
          // Extract city from postal code format (e.g., "35000 İzmir")
          const cityMatch = cityPart.match(/\d+\s+(.+)/);
          city = cityMatch ? cityMatch[1] : cityPart;
        }
        // District might be in earlier parts
        if (addressParts.length >= 3) {
          district = addressParts[addressParts.length - 3]?.trim();
        }
      }

      // Create restaurant document
      const restaurantData = {
        name: place.name || "Unknown Restaurant",
        address: place.formatted_address || "",
        placeId: placeId,
        location: {
          lat: location.lat,
          lng: location.lng,
        },
        geohash: hash,
        googleRating: place.rating || null,
        phoneNumber: place.formatted_phone_number || null,
        website: place.website || null,
        openingHours: place.opening_hours || null,
        city: city,
        district: district,
        contributedBy: uid,
        isFromGooglePlaces: true,
        menus: [],
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      // Save to Firestore using placeId as document ID
      await db.collection("restaurants").doc(placeId).set(restaurantData);

      console.log(
        `✅ Restaurant added successfully: ${placeId} by user ${uid}`
      );

      return {
        success: true,
        restaurantId: placeId,
        alreadyExists: false,
      };
    } catch (error) {
      console.error("❌ addRestaurantFromPlaces error:", error);
      if (error.code) throw error; // Re-throw HttpsError
      throw new functions.https.HttpsError(
        "internal",
        `Failed to add restaurant: ${error.message}`
      );
    }
  }
);

/**
 * searchNearbyPlaces
 * Callable function to search for nearby restaurants using Google Places API
 * This acts as a proxy to bypass CORS restrictions for web clients
 *
 * Expected data: { lat: number, lng: number, radius: number, type: string }
 */
exports.searchNearbyPlaces = functions.https.onCall(async (data, context) => {
  const { lat, lng, radius = 5000, type = "restaurant" } = data;

  if (!lat || !lng) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "lat and lng are required"
    );
  }

  // Get Google Places API key from environment variable or Firebase config
  const apiKey =
    process.env.GOOGLE_PLACES_API_KEY ||
    functions.config().google?.places_api_key;

  if (!apiKey) {
    console.error("❌ Google Places API key not configured");
    throw new functions.https.HttpsError(
      "failed-precondition",
      "Google Places API key not configured"
    );
  }

  console.log("🔍 searchNearbyPlaces called:", { lat, lng, radius, type });

  try {
    // Call Google Places API - Nearby Search
    const response = await axios.get(
      "https://maps.googleapis.com/maps/api/place/nearbysearch/json",
      {
        params: {
          location: `${lat},${lng}`,
          radius: radius,
          type: type,
          key: apiKey,
        },
      }
    );

    if (
      response.data.status !== "OK" &&
      response.data.status !== "ZERO_RESULTS"
    ) {
      console.error("❌ Google Places API error:", response.data);
      throw new functions.https.HttpsError(
        "internal",
        `Google Places API error: ${response.data.status}`
      );
    }

    console.log(
      "✅ Google Places API success, results:",
      response.data.results?.length || 0
    );

    return {
      status: response.data.status,
      results: response.data.results || [],
    };
  } catch (error) {
    console.error("❌ searchNearbyPlaces error:", error);
    throw new functions.https.HttpsError(
      "internal",
      `Search failed: ${error.message}`
    );
  }
});

/**
 * updateRestaurantItemCount
 * Firestore trigger that updates restaurant's itemCount when items are approved/rejected/deleted
 * Triggers on /items/{itemId} write events
 * Only counts items with status='approved'
 */
exports.updateRestaurantItemCount = functions.firestore
  .document("items/{itemId}")
  .onWrite(async (change, context) => {
    const before = change.before.exists ? change.before.data() : null;
    const after = change.after.exists ? change.after.data() : null;

    // Determine which restaurant(s) to update
    const restaurantIds = new Set();

    if (before && before.restaurantId) {
      restaurantIds.add(before.restaurantId);
    }
    if (after && after.restaurantId) {
      restaurantIds.add(after.restaurantId);
    }

    if (restaurantIds.size === 0) {
      console.log("No restaurant to update");
      return null;
    }

    // Update itemCount for each affected restaurant
    const promises = [];
    for (const restaurantId of restaurantIds) {
      promises.push(updateItemCountForRestaurant(restaurantId));
    }

    await Promise.all(promises);
    return null;
  });

/**
 * Helper function to recalculate and update itemCount for a restaurant
 */
async function updateItemCountForRestaurant(restaurantId) {
  try {
    // Count approved items for this restaurant
    const itemsSnapshot = await db
      .collection("items")
      .where("restaurantId", "==", restaurantId)
      .where("status", "==", "approved")
      .get();

    const itemCount = itemsSnapshot.size;

    // Update restaurant document
    await db.collection("restaurants").doc(restaurantId).update({
      itemCount: itemCount,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(
      `✅ Updated itemCount for restaurant ${restaurantId}: ${itemCount}`
    );
  } catch (error) {
    console.error(
      `❌ Error updating itemCount for restaurant ${restaurantId}:`,
      error
    );
  }
}

/**
 * placesNearbySearch
 * Callable function to proxy Google Places API Nearby Search
 * Bypasses CORS restrictions for web clients
 */
exports.placesNearbySearch = functions.https.onCall(async (data, context) => {
  // Optional: Verify App Check (uncomment in production)
  // if (!context.app) {
  //   throw new functions.https.HttpsError('failed-precondition', 'App Check required');
  // }

  const { latitude, longitude, radius = 5000, keyword = "restaurant" } = data;

  if (!latitude || !longitude) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "latitude and longitude are required"
    );
  }

  const GOOGLE_API_KEY = process.env.GOOGLE_PLACES_API_KEY || functions.config().google?.places_api_key;

  if (!GOOGLE_API_KEY) {
    console.error("❌ Google Places API key not configured");
    throw new functions.https.HttpsError(
      "failed-precondition",
      "Google Places API key not configured"
    );
  }

  try {
    console.log(`🔍 Places Nearby Search: ${latitude},${longitude} radius:${radius}m keyword:${keyword}`);

    const url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json";
    const response = await axios.get(url, {
      params: {
        location: `${latitude},${longitude}`,
        radius: radius,
        keyword: keyword,
        key: GOOGLE_API_KEY,
      },
    });

    console.log(`✅ Places API Response: ${response.data.status}, ${response.data.results?.length || 0} results`);

    return {
      status: response.data.status,
      results: response.data.results || [],
      nextPageToken: response.data.next_page_token,
    };
  } catch (error) {
    console.error("❌ Places API Error:", error.message);
    throw new functions.https.HttpsError("internal", error.message);
  }
});

/**
 * placesAutocomplete
 * Callable function to proxy Google Places API Autocomplete
 * Bypasses CORS restrictions for web clients
 */
exports.placesAutocomplete = functions.https.onCall(async (data, context) => {
  // Optional: Verify App Check (uncomment in production)
  // if (!context.app) {
  //   throw new functions.https.HttpsError('failed-precondition', 'App Check required');
  // }

  const { input, types = "establishment" } = data;

  if (!input) {
    throw new functions.https.HttpsError("invalid-argument", "input is required");
  }

  const GOOGLE_API_KEY = process.env.GOOGLE_PLACES_API_KEY || functions.config().google?.places_api_key;

  if (!GOOGLE_API_KEY) {
    console.error("❌ Google Places API key not configured");
    throw new functions.https.HttpsError(
      "failed-precondition",
      "Google Places API key not configured"
    );
  }

  try {
    console.log(`🔍 Places Autocomplete: "${input}" types:${types}`);

    const url = "https://maps.googleapis.com/maps/api/place/autocomplete/json";
    const params = {
      input: input,
      types: types,
      key: GOOGLE_API_KEY,
      // Restrict to Turkey region
      components: "country:tr",
      // Add language preference
      language: "tr",
    };

    const response = await axios.get(url, { params });

    console.log(`✅ Autocomplete API Response: ${response.data.status}, ${response.data.predictions?.length || 0} predictions`);

    // Filter to only include restaurants
    let predictions = response.data.predictions || [];

    // If we have predictions, filter them to only include food establishments
    if (predictions.length > 0) {
      predictions = predictions.filter(prediction => {
        const types = prediction.types || [];
        const description = (prediction.description || '').toLowerCase();

        // Include if it's a food-related establishment
        const isFoodRelated =
          types.includes('restaurant') ||
          types.includes('food') ||
          types.includes('cafe') ||
          types.includes('bar') ||
          types.includes('meal_takeaway') ||
          types.includes('meal_delivery') ||
          description.includes('restoran') ||
          description.includes('restaurant') ||
          description.includes('lokanta') ||
          description.includes('kafe') ||
          description.includes('cafe') ||
          description.includes('pizza') ||
          description.includes('kebap') ||
          description.includes('döner');

        return isFoodRelated;
      });

      console.log(`🍽️ Filtered to ${predictions.length} food establishments`);
    }

    return {
      status: response.data.status,
      predictions: predictions,
    };
  } catch (error) {
    console.error("❌ Autocomplete API Error:", error.message);
    throw new functions.https.HttpsError("internal", error.message);
  }
});

/**
 * placesTextSearch
 * Callable function to proxy Google Places API Text Search
 * Bypasses CORS restrictions for web clients
 */
exports.placesTextSearch = functions.https.onCall(async (data, context) => {
  const { query, location, radius = 50000 } = data;

  if (!query) {
    throw new functions.https.HttpsError("invalid-argument", "query is required");
  }

  const GOOGLE_API_KEY = process.env.GOOGLE_PLACES_API_KEY || functions.config().google?.places_api_key;

  if (!GOOGLE_API_KEY) {
    console.error("❌ Google Places API key not configured");
    throw new functions.https.HttpsError(
      "failed-precondition",
      "Google Places API key not configured"
    );
  }

  try {
    console.log(`🔍 Places Text Search: "${query}" location:${location} radius:${radius}m`);

    const url = "https://maps.googleapis.com/maps/api/place/textsearch/json";
    const params = {
      query: query,
      key: GOOGLE_API_KEY,
    };

    if (location) {
      params.location = location;
      params.radius = radius;
    }

    const response = await axios.get(url, { params });

    console.log(`✅ Text Search API Response: ${response.data.status}, ${response.data.results?.length || 0} results`);

    return {
      status: response.data.status,
      results: response.data.results || [],
      nextPageToken: response.data.next_page_token,
    };
  } catch (error) {
    console.error("❌ Text Search API Error:", error.message);
    throw new functions.https.HttpsError("internal", error.message);
  }
});

/**
 * placesDetails
 * Callable function to proxy Google Places API Place Details
 * Bypasses CORS restrictions for web clients
 */
exports.placesDetails = functions.https.onCall(async (data, context) => {
  const { placeId, fields } = data;

  if (!placeId) {
    throw new functions.https.HttpsError("invalid-argument", "placeId is required");
  }

  const GOOGLE_API_KEY = process.env.GOOGLE_PLACES_API_KEY || functions.config().google?.places_api_key;

  if (!GOOGLE_API_KEY) {
    console.error("❌ Google Places API key not configured");
    throw new functions.https.HttpsError(
      "failed-precondition",
      "Google Places API key not configured"
    );
  }

  try {
    console.log(`🔍 Places Details: placeId="${placeId}" fields="${fields || 'default'}"`);

    const url = "https://maps.googleapis.com/maps/api/place/details/json";
    const params = {
      place_id: placeId,
      key: GOOGLE_API_KEY,
    };

    // Add fields parameter if provided
    if (fields) {
      params.fields = fields;
    }

    const response = await axios.get(url, { params });

    console.log(`✅ Place Details API Response: ${response.data.status}`);

    return {
      status: response.data.status,
      result: response.data.result || null,
    };
  } catch (error) {
    console.error("❌ Place Details API Error:", error.message);
    throw new functions.https.HttpsError("internal", error.message);
  }
});


