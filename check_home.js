const fs=require('fs');
let code=fs.readFileSync('lib/screens/home_map_screen.dart','utf8');
code=code.replace(/\r\n/g,'\n');
// Find the list building section
const idx=code.indexOf('AnimatedList');
console.log('AnimatedList at:',idx);
const idx2=code.indexOf('ListView');
console.log('ListView at:',idx2);
const idx3=code.indexOf('staggered');
console.log('staggered at:',idx3);
const idx4=code.indexOf('_parks');
console.log('First _parks at:',idx4);
console.log(JSON.stringify(code.substring(idx4,idx4+300)));