const fs=require('fs');
let code=fs.readFileSync('lib/screens/home_map_screen.dart','utf8');
code=code.replace(/\r\n/g,'\n');
const lines=code.split('\n');

// Print exact chars around lines 484-490
for(let i=483;i<491;i++){
  const line=lines[i];
  let spaces=0;
  for(let c of line){ if(c===' ') spaces++; else break; }
  console.log((i+1)+'\t['+spaces+' spaces]\t'+JSON.stringify(line));
}