const fs=require('fs');
let code=fs.readFileSync('lib/screens/home_map_screen.dart','utf8');
code=code.replace(/\r\n/g,'\n');
const lines=code.split('\n');
for(let i=285;i<310;i++) console.log((i+1)+'\t'+lines[i]);
console.log('...');
for(let i=435;i<495;i++) console.log((i+1)+'\t'+lines[i]);