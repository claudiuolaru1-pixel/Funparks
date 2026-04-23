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

// Only upload these specific parks that have new/replacement images
const targetParks = [
  'altontowers',
  'efteling',
  'energylandia',
  'heidepark',
  'phantasialand',
  'plopsaland',
  'portaventura',
  'six_flags_fiesta_texas',
  'thorpepark',
  'tivoli'
];

const imagesDir = path.join(__dirname, 'assets', 'images');

async function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function forceUploadFile(localPath, remotePath) {
  for (let i = 0; i < 3; i++) {
    try {
      console.log('Force uploading: ' + remotePath);
      await bucket.upload(localPath, {
        destination: remotePath,
        metadata: { contentType: 'image/png' },
        public: true
      });
      return;
    } catch (e) {
      if (i < 2) { await sleep(2000); }
      else { console.error('Failed: ' + remotePath, e.message); }
    }
  }
}

async function main() {
  for (const park of targetParks) {
    const parkDir = path.join(imagesDir, park);
    if (!fs.existsSync(parkDir)) continue;
    const files = fs.readdirSync(parkDir).filter(f => f.endsWith('.png'));
    for (const file of files) {
      const localPath = path.join(parkDir, file);
      const remotePath = `images/${park}/${file}`;
      await forceUploadFile(localPath, remotePath);
      await sleep(200);
    }
  }
  console.log('All done!');
  process.exit(0);
}

main();