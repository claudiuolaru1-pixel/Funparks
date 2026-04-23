const fs=require('fs');
const path='lib/screens/park_detail_screen.dart';
const lines=fs.readFileSync(path,'utf8').split('\n');

// Find and fix the broken Get Your Tickets Now row
// Currently looks like:
//   Expanded(
//     child: FilledButton...
//     style: ...deepOrange),
//   ],        <-- WRONG: this closes children of Row prematurely
// ),          <-- WRONG
//     ),      <-- WRONG: orphaned
// Should be:
//   Expanded(
//     child: FilledButton...
//     style: ...deepOrange),
//   ),        <-- closes FilledButton
// ),          <-- closes Expanded
// ],          <-- closes children
// ),          <-- closes Row

for(let i=0;i<lines.length;i++){
  if(lines[i] && lines[i].includes('backgroundColor: Colors.deepOrange),')){
    // Check next few lines
    console.log('Found deepOrange at',i);
    for(let j=i;j<i+6;j++) console.log(j,JSON.stringify(lines[j]));
    
    // Fix: replace the 4 bad lines after deepOrange with correct closing
    // lines[i+1] should be "              )," (closes FilledButton.styleFrom)
    // lines[i+2] should be "            )," (closes FilledButton.icon)  
    // lines[i+3] should be "          )," (closes Expanded)
    // lines[i+4] should be "        ]," (closes children)
    // lines[i+5] should be "      )," (closes Row)
    
    // Current wrong state after deepOrange:
    // "          ],"
    // "        ),"
    // "            ),"
    
    if(lines[i+1] && lines[i+1].trim()==='],'){
      lines.splice(i+1, 3,
        '              ),',
        '            ),',
        '          ),',
        '        ],',
        '      ),'
      );
      console.log('Fixed brackets');
    }
    break;
  }
}

fs.writeFileSync(path,lines.join('\n'),'utf8');
console.log('Done');