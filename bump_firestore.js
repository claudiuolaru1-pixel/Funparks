const fs=require('fs');
let c=fs.readFileSync('pubspec.yaml','utf8');
c=c.replace('cloud_firestore: ^5.6.12','cloud_firestore: ^6.4.1');
fs.writeFileSync('pubspec.yaml',c,'utf8');
console.log('Done');