const fs=require('fs');
let code=fs.readFileSync('lib/screens/home_map_screen.dart','utf8');
code=code.replace(/\r\n/g,'\n');

const bad = '_openPark(p);\n                    },\n                        ),\n                        ),\n                      ),\n                    );';
const good = '_openPark(p);\n                        },\n                      );';

if(code.includes(bad)){
  code=code.replace(bad,good);
  console.log('✓ Fixed');
} else {
  console.log('⚠ Not found');
}
fs.writeFileSync('lib/screens/home_map_screen.dart',code,'utf8');