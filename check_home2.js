const fs=require('fs');
let code=fs.readFileSync('lib/screens/home_map_screen.dart','utf8');
code=code.replace(/\r\n/g,'\n');
const idx=code.indexOf('ListView');
console.log('ListView section:');
console.log(JSON.stringify(code.substring(idx,idx+600)));
const idx2=code.indexOf('staggered');
console.log('\nStaggered section:');
console.log(JSON.stringify(code.substring(idx2-50,idx2+400)));