const fs=require('fs');
let code=fs.readFileSync('lib/screens/home_map_screen.dart','utf8');
code=code.replace(/\r\n/g,'\n');
// Find loading logic
const idx=code.indexOf('_loading');
console.log('First _loading at:',idx);
console.log(JSON.stringify(code.substring(idx,idx+400)));
const idx2=code.indexOf('setState(() => _loading');
console.log('\nsetState loading:',idx2);
if(idx2!==-1) console.log(JSON.stringify(code.substring(idx2-100,idx2+200)));
const idx3=code.indexOf('loadParks\|fetchParks\|_loadData\|initState');
const idx4=code.indexOf('initState');
console.log('\ninitState at:',idx4);
if(idx4!==-1) console.log(JSON.stringify(code.substring(idx4,idx4+400)));