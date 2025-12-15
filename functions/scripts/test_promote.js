const admin = require('firebase-admin');

admin.initializeApp({ projectId: 'qrmenufinder' });
const db = admin.firestore();

async function run() {
  console.log('Creating test user, restaurant and staging doc...');

  const uid = 'test-owner-uid';

  // Create user doc
  await db.collection('users').doc(uid).set({ name: 'Test Owner', role: 'owner' });

  // Create restaurant
  const restaurantRef = db.collection('restaurants').doc('test-restaurant');
  await restaurantRef.set({ name: 'Test R', ownerId: uid, lastSyncedAt: null });

  // Create staging doc
  const stagingRef = db.collection('items_staging').doc();
  const stagingData = { name: 'Test Item', price: 12.5, restaurantId: 'test-restaurant', previousPrices: [] };
  await stagingRef.set(stagingData);

  console.log('stagingId=', stagingRef.id);

  // Run promote logic (similar to promoteToLive transaction but as admin script)
  try {
    await db.runTransaction(async (t) => {
      const stagingSnap = await t.get(stagingRef);
      if (!stagingSnap.exists) throw new Error('staging missing');
      const staging = stagingSnap.data();

      const itemsCol = db.collection('items');
      const newRef = itemsCol.doc();
      t.set(newRef, {
        ...staging,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        previousPrices: staging.previousPrices || []
      });

      t.update(restaurantRef, { lastSyncedAt: admin.firestore.FieldValue.serverTimestamp() });

      t.delete(stagingRef);
    });

    console.log('Promotion transaction committed.');

    // Read results
    const itemsSnap = await db.collection('items').get();
    itemsSnap.forEach(d => console.log('Item:', d.id, d.data()));

    const rest = await restaurantRef.get();
    console.log('Restaurant lastSyncedAt:', rest.data().lastSyncedAt && rest.data().lastSyncedAt.toDate());
  } catch (e) {
    console.error('Error promoting', e);
  }
}

run().catch(e => { console.error(e); process.exit(1); });
