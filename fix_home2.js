const fs=require('fs');
let code=fs.readFileSync('lib/screens/home_map_screen.dart','utf8');
code=code.replace(/\r\n/g,'\n');

const bad =
  '                          _openPark(p);\n' +
  '                            },\n' +
  '                          );\n' +
  '                    },\n' +
  '                    ),\n' +
  '                  ),\n' +
  '                ),';

const good =
  '                          _openPark(p);\n' +
  '                        },\n' +
  '                      );\n' +
  '                    },\n' +
  '                  ),\n' +
  '                ),';

if(code.includes(bad)){
  code=code.replace(bad,good);
  console.log('✓ Fixed');
} else {
  console.log('⚠ Not found');
  const idx=code.indexOf('_openPark(p);');
  console.log(JSON.stringify(code.substring(idx,idx+250)));
}
fs.writeFileSync('lib/screens/home_map_screen.dart',code,'utf8');