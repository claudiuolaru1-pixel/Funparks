const admin=require('firebase-admin');
const sa=require('./serviceAccountKey.json');
admin.initializeApp({credential:admin.credential.cert(sa),storageBucket:'funparks-779c6.firebasestorage.app'});
const bucket=admin.storage().bucket();
async function run(){
  const file=bucket.file('data/parks/altontowers/food.json');
  const [contents]=await file.download();
  const d=JSON.parse(contents.toString());
  d.forEach(f=>{
    console.log(f.id, '— items:', f.items?.length);
    f.items?.forEach(i=>console.log('   ',i.name, i.price));
  });
  process.exit(0);
}
run().catch(e=>{console.error(e);process.exit(1);});