const fs=require('fs');
const path='lib/screens/park_detail_screen.dart';
const lines=fs.readFileSync(path,'utf8').split('\n');
let changes=0;

for(let i=0;i<lines.length;i++){
  // 1. Change "Buy Tickets" to "Get Your Tickets Now"
  if(lines[i].includes("label: const Text('Buy Tickets'") || lines[i].includes('label: const Text("Buy Tickets"')){
    lines[i]=lines[i].replace(/Buy Tickets/g,'Get Your Tickets Now');
    console.log('Fixed Buy Tickets at line',i);
    changes++;
  }
  // 2. Change "Website" button label
  if(lines[i].includes("label: const Text('Website')") || lines[i].includes('label: const Text("Website")')){
    lines[i]=lines[i].replace(/label: const Text\('Website'\)/,"label: const Text('Skip the Line')");
    lines[i]=lines[i].replace(/label: const Text\("Website"\)/,'label: const Text("Skip the Line")');
    console.log('Replaced Website label at line',i);
    changes++;
  }
  // 3. Change website icon to bolt
  if(lines[i].includes('icon: const Icon(Icons.public)') && lines[i+1] && lines[i+1].includes('Website')){
    lines[i]=lines[i].replace('Icons.public','Icons.bolt');
    console.log('Changed website icon at line',i);
    changes++;
  }
}

console.log('Total changes:',changes);
fs.writeFileSync(path,lines.join('\n'),'utf8');