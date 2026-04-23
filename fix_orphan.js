const fs=require('fs');
const path='lib/screens/park_detail_screen.dart';
const lines=fs.readFileSync(path,'utf8').split('\n');

// Find the broken section and fix it
// Look for the Row with price that has orphaned onPressed after it
let fixStart=-1, fixEnd=-1;

for(let i=0;i<lines.length;i++){
  if(lines[i].includes("text: 'Breakfast'),") && fixStart===-1){
    fixStart=i+1; // line after Breakfast pill
  }
  if(fixStart>0 && lines[i].includes("await launchUrl(url, mode: LaunchMode.externalApplication);")){
    // Find the end - need to remove from fixStart to the closing ],),), of the button
    // Look ahead for the pattern
    for(let j=i;j<i+10;j++){
      if(lines[j].includes("),") && lines[j].trim()===")" || lines[j].trim()===")," ){
        fixEnd=j;
        break;
      }
    }
    // Find exact end - 4 closing lines
    fixEnd=i+4;
    break;
  }
}

console.log('Fix range:',fixStart,'to',fixEnd);
console.log('Lines to remove:');
for(let i=fixStart;i<=fixEnd;i++) console.log(i,lines[i]);

// Remove the orphaned lines
lines.splice(fixStart, fixEnd-fixStart+1);

fs.writeFileSync(path,lines.join('\n'),'utf8');
console.log('Fixed');