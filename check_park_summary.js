const fs=require('fs');
let code=fs.readFileSync('lib/models/park_summary.dart','utf8');
code=code.replace(/\r\n/g,'\n');
console.log(JSON.stringify(code.substring(0,2000)));