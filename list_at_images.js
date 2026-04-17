const admin=require('firebase-admin');
const fs=require('fs');
const sa=JSON.parse(fs.readFileSync('service-account.json','utf8'));
admin.initializeApp({credential:admin.credential.cert(sa),storageBucket:`${sa.project_id}.appspot.com`});
const bucket=admin.storage().bucket();
async function list(){
  const [files]=await bucket.getFiles({prefix:'images/altontowers/'});
  files.forEach(f=>console.log(f.name));
  process.exit(0);
}
list().catch(e=>{console.error(e);process.exit(1);});