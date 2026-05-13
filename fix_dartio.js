const fs=require('fs');
let c=fs.readFileSync('lib/main.dart','utf8');
if(!c.includes("import 'dart:io'")){
  c=c.replace("import 'dart:flutter'","import 'dart:io';\nimport 'dart:flutter'");
  if(!c.includes("import 'dart:io'")){
    // Add after first import line
    c=c.replace(/^(import .+;\n)/m,"$1import 'dart:io';\n");
  }
}
fs.writeFileSync('lib/main.dart',c,'utf8');
console.log('dart:io added:', c.includes("import 'dart:io'"));