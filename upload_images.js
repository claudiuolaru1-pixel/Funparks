const { initializeApp, cert } = require('firebase-admin/app');
const { getStorage } = require('firebase-admin/storage');
const fs = require('fs');
const path = require('path');

const serviceAccount = require('./serviceAccountKey.json');

const app = initializeApp({
  credential: cert(serviceAccount),
  storageBucket: 'funparks-779c6.firebasestorage.app'
});

const storage = getStorage(app);
const bucket = storage.bucket();

const imagesDir = path.join(__dirname, 'assets', 'images');

async function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function uploadFile(localPath, remotePath, retries = 3) {
  for (let i = 0; i < retries; i++) {
    try {
      // Check if already exists
      const file = bucket.file(remotePath);
      const [exists] = await file.exists();
      if (exists) {
        console.log('Skipping (exists): ' + remotePath);
        return;
      }
      console.log('Uploading: ' + remotePath);
      await bucket.upload(localPath, {
        destination: remotePath,
        metadata: { contentType: 'image/png' },
        public: true
      });
      return;
    } catch (e) {
      if (i < retries - 1) {
        console.log('Retrying (' + (i+1) + '): ' + remotePath);
        await sleep(2000);
      } else {
        console.error('Failed after retries: ' + remotePath + ' - ' + e.message);
      }
    }
  }
}

async function uploadDir(localDir, remotePrefix) {
  const entries = fs.readdirSync(localDir, { withFileTypes: true });
  for (const entry of entries) {
    const localPath = path.join(localDir, entry.name);
    const remotePath = remotePrefix + '/' + entry.name;
    if (entry.isDirectory()) {
      await uploadDir(localPath, remotePath);
    } else if (entry.name.endsWith('.png') || entry.name.endsWith('.jpg')) {
      await uploadFile(localPath, remotePath);
    }
  }
}

uploadDir(imagesDir, 'images')
  .then(() => { console.log('All done!'); process.exit(0); })
  .catch(e => { console.error('Fatal:', e.message); process.exit(1); });