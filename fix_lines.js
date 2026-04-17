const fs=require('fs');
let code=fs.readFileSync('lib/screens/home_map_screen.dart','utf8');
code=code.replace(/\r\n/g,'\n');
const lines=code.split('\n');

// Line 487 (index 486): should be 20 spaces '},  ' (closes itemBuilder)
// Line 488 (index 487): should be 18 spaces '),  ' (closes ListView)
// Line 489 (index 488): should be 16 spaces '),' (closes Expanded)
// Line 490 (index 489): DELETE - extra AnimationLimiter bracket

lines[486] = '                    },';   // 20 spaces - closes itemBuilder
lines[487] = '                  ),';     // 18 spaces - closes ListView.separated
lines[488] = '                ),';       // 16 spaces - closes Expanded
lines[489] = '';                         // delete extra bracket

// Remove the empty line
const result = lines.filter((l,i) => !(i===489 && l===''));
fs.writeFileSync('lib/screens/home_map_screen.dart', result.join('\n'), 'utf8');
console.log('✓ Fixed. New lines 484-492:');
for(let i=483;i<492;i++) console.log((i+1)+'\t'+result[i]);