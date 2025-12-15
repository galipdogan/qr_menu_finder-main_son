/**
 * One-off backfill script
 * Usage: set ALGOLIA_ADMIN_KEY and ALGOLIA_APP_ID env vars or set functions config and run from functions/ folder:
 * ALGOLIA_ADMIN_KEY=... ALGOLIA_APP_ID=... node ./scripts/backfill_items.js
 */
const admin = require('firebase-admin');
const algoliasearch = require('algoliasearch');

admin.initializeApp();
const db = admin.firestore();

const ALGOLIA_ADMIN_KEY = process.env.ALGOLIA_ADMIN_KEY;
const ALGOLIA_APP_ID = process.env.ALGOLIA_APP_ID;
const ALGOLIA_INDEX = process.env.ALGOLIA_INDEX || 'items_idx';

if (!ALGOLIA_ADMIN_KEY || !ALGOLIA_APP_ID) {
  console.error('Set ALGOLIA_ADMIN_KEY and ALGOLIA_APP_ID env vars before running');
  process.exit(1);
}

const client = algoliasearch(ALGOLIA_APP_ID, ALGOLIA_ADMIN_KEY);
const index = client.initIndex(ALGOLIA_INDEX);

async function run() {
  console.log('Starting backfill...');
  const batchSize = 500;
  let lastDoc = null;
  let total = 0;

  while (true) {
    let q = db.collection('items').orderBy('__name__').limit(batchSize);
    if (lastDoc) q = q.startAfter(lastDoc);
    const snap = await q.get();
    if (snap.empty) break;

    const objects = [];
    snap.forEach(doc => {
      const data = doc.data();
      objects.push({ objectID: doc.id, ...data });
    });

    // send to algolia in chunks of 1000 (Algolia limit)
    for (let i = 0; i < objects.length; i += 1000) {
      const chunk = objects.slice(i, i + 1000);
      await index.saveObjects(chunk);
    }

    total += objects.length;
    lastDoc = snap.docs[snap.docs.length - 1];
    console.log(`Indexed ${total} items...`);
    if (snap.size < batchSize) break;
  }

  console.log(`Backfill complete. Total indexed: ${total}`);
}

run().catch(err => {
  console.error('Backfill failed', err);
  process.exit(1);
});
