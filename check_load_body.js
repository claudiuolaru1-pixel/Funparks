const fs=require('fs');
let code=fs.readFileSync('lib/screens/home_map_screen.dart','utf8');
code=code.replace(/\r\n/g,'\n');
console.log(JSON.stringify(code.substring(3031,3031+1500)));