const fs=require('fs');
let c=fs.readFileSync('pubspec.yaml','utf8');
// Replace any 2.0.1+xxx with 2.0.1+122
c=c.replace(/version: 2\.0\.1\+\d+/,'version: 2.0.1+122');
fs.writeFileSync('pubspec.yaml',c,'utf8');
console.log('Version:',fs.readFileSync('pubspec.yaml','utf8').match(/version:.*/)[0]);