const fs=require('fs');
let c=fs.readFileSync('pubspec.yaml','utf8');
c=c.replace('version: 2.0.1+110','version: 2.0.1+111');
fs.writeFileSync('pubspec.yaml',c,'utf8');
console.log('Build 111');