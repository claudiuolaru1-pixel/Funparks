const fs=require('fs');
let code=fs.readFileSync('lib/data/parks_repository.dart','utf8');
code=code.replace(/\r\n/g,'\n');
const idx=code.indexOf('loadParkIndex');
console.log(JSON.stringify(code.substring(idx,idx+800)));