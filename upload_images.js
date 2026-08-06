const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: 'funparks-779c6.firebasestorage.app'
});

const bucket = admin.storage().bucket();
const imagesRoot = path.join(__dirname, 'assets', 'images');

async function uploadAll() {
  const parkFolders = fs.readdirSync(imagesRoot).filter(f =>
    fs.statSync(path.join(imagesRoot, f)).isDirectory()
  );

  for (const parkId of parkFolders) {
    const parkDir = path.join(imagesRoot, parkId);
    const files = fs.readdirSync(parkDir).filter(f =>
      fs.statSync(path.join(parkDir, f)).isFile()
    );

    for (const file of files) {
      const localPath = path.join(parkDir, file);
      const destination = `images/${parkId}/${file}`;
      console.log(`Uploading: ${destination}`);
      await bucket.upload(localPath, {
        destination,
        metadata: { cacheControl: 'public, max-age=31536000' }
      });
    }
  }
  console.log('All done!');
}

uploadAll().catch(err => {
  console.error('Upload error:', err);
  process.exit(1);
});
