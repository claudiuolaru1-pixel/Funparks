const fs=require('fs');
let c=fs.readFileSync('pubspec.yaml','utf8');
c=c.replace('intl: ^0.19.0','intl: ^0.20.2');
fs.writeFileSync('pubspec.yaml',c,'utf8');
console.log('Fixed intl version to ^0.20.2');