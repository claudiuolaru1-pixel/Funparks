const fs=require('fs');
let code=fs.readFileSync('lib/screens/home_map_screen.dart','utf8');
code=code.replace(/\r\n/g,'\n');

// Remove the 3 leftover closing brackets after the ListTile
const bad = `            ),\n                            ),\n                          ),\n                        );\n                    },`;
const good = `            ),\n                    },`;
if(code.includes(bad)){
  code=code.replace(bad,good);
  console.log('✓ Extra brackets removed');
} else {
  console.log('⚠ Pattern not found, trying alternate...');
  // Print the area to debug
  const idx=code.indexOf('_openPark(p);');
  console.log(JSON.stringify(code.substring(idx,idx+150)));
}
fs.writeFileSync('lib/screens/home_map_screen.dart',code,'utf8');