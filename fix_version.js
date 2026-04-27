const fs=require('fs');
let c=fs.readFileSync('pubspec.yaml','utf8');
// Increment build number from 108 to 109
c=c.replace('version: 2.0.1+108','version: 2.0.1+109');
fs.writeFileSync('pubspec.yaml',c,'utf8');
console.log('Build number incremented to 109');