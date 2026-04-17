const fs=require('fs');
let code=fs.readFileSync('lib/screens/home_map_screen.dart','utf8');
code=code.replace(/\r\n/g,'\n');
const idx=code.indexOf('Future<void> _loadParksAndMarkers');
const idx2=code.indexOf('void _loadParksAndMarkers');
const idx3=code.indexOf('_loadParksAndMarkers() async');
const idx4=code.indexOf('_loadParksAndMarkers() {');
console.log('Future<void>:',idx,'void:',idx2,'async:',idx3,'sync:',idx4);
// Find the actual definition
let i=0;
while(i<code.length){
  const found=code.indexOf('_loadParksAndMarkers',i);
  if(found===-1) break;
  console.log('at',found,':',JSON.stringify(code.substring(found-10,found+60)));
  i=found+1;
}