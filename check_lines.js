const fs=require('fs');
let code=fs.readFileSync('lib/screens/home_map_screen.dart','utf8');
code=code.replace(/\r\n/g,'\n');
const lines=code.split('\n');
// Print lines 440-500
for(let i=439;i<505;i++){
  console.log((i+1)+'\t'+lines[i]);
}