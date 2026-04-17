const fs=require('fs');
let code=fs.readFileSync('lib/screens/home_map_screen.dart','utf8');
code=code.replace(/\r\n/g,'\n');
const idx=code.indexOf('AnimationLimiter');
console.log('AnimationLimiter context:');
console.log(JSON.stringify(code.substring(idx-30,idx+300)));