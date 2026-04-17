const admin=require('firebase-admin');
const sa=require('./serviceAccountKey.json');
admin.initializeApp({credential:admin.credential.cert(sa),storageBucket:'funparks-779c6.firebasestorage.app'});
const bucket=admin.storage().bucket();
async function run(){
  const [files]=await bucket.getFiles({prefix:'images/altontowers/'});
  console.log('Files in Firebase for altontowers:');
  files.forEach(f=>console.log(' ',f.name));
  await bucket.upload('assets/data/parks/altontowers/food.json',{
    destination:'data/parks/altontowers/food.json',
    metadata:{contentType:'application/json'}
  });
  console.log('\nUploaded food.json');
  process.exit(0);
}
run().catch(e=>{console.error(e);process.exit(1);});