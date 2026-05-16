const fs=require('fs');
let m=fs.readFileSync('lib/main.dart','utf8');
// Change E:${e.runtimeType} to show full error message
m=m.replace(
  "firebaseInitError = 'E:\\${e.runtimeType}';",
  "firebaseInitError = e.toString().length > 120 ? e.toString().substring(0,120) : e.toString();"
);
fs.writeFileSync('lib/main.dart',m,'utf8');
console.log('Fixed:', m.includes('substring(0,120)'));