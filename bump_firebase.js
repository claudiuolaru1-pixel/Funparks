const fs=require('fs');
let c=fs.readFileSync('pubspec.yaml','utf8');
c=c.replace('firebase_core: ^3.5.0','firebase_core: ^4.9.0');
c=c.replace('firebase_auth: ^5.3.1','firebase_auth: ^6.5.1');
c=c.replace('firebase_storage: ^12.3.3','firebase_storage: ^13.4.1');
fs.writeFileSync('pubspec.yaml',c,'utf8');
console.log('Done');