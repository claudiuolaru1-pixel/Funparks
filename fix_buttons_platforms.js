const fs=require('fs');
const path='lib/screens/park_detail_screen.dart';
const lines=fs.readFileSync(path,'utf8').split('\n');

// Find both button blocks and replace entirely
let inSkipBlock=false;
let inToursBlock=false;
let skipStart=-1, toursStart=-1;

for(let i=0;i<lines.length;i++){
  if(lines[i].includes("icon: const Icon(Icons.bolt)") && lines[i+1] && lines[i+1].includes("'Skip the Line'")){
    // Find the onPressed block above
    for(let j=i;j>i-25;j--){
      if(lines[j].includes('onPressed: () async {')){
        skipStart=j;
        break;
      }
    }
    console.log('Skip block onPressed at line',skipStart);
  }
  if(lines[i].includes("icon: const Icon(Icons.explore)") && lines[i+1] && lines[i+1].includes("'Tours & Experiences'")){
    for(let j=i;j>i-25;j--){
      if(lines[j].includes('onPressed: () async {')){
        toursStart=j;
        break;
      }
    }
    console.log('Tours block onPressed at line',toursStart);
  }
}

// Replace Skip the Line onPressed - always GYG with skip-line filter
if(skipStart>0){
  // Find end of this async block
  let depth=0, end=skipStart;
  for(let i=skipStart;i<skipStart+20;i++){
    if(lines[i].includes('{'))depth++;
    if(lines[i].includes('}')){depth--;if(depth===0){end=i;break;}}
  }
  const indent='                  ';
  const newBlock=[
    `${indent}onPressed: () async {`,
    `${indent}  final q = Uri.encodeComponent('\${park.city ?? ''} \${park.name}'.trim());`,
    `${indent}  final url = Uri.parse('https://www.getyourguide.com/s/?q=\$q&filters=activity_type%3ASkip+the+Line&partner_id=GVNQTTL');`,
    `${indent}  await launchUrl(url, mode: LaunchMode.externalApplication);`,
    `${indent}},`,
  ];
  lines.splice(skipStart, end-skipStart+1, ...newBlock);
  console.log('Skip the Line fixed - always GYG with skip-line filter');
}

// Recalculate toursStart after splice
for(let i=0;i<lines.length;i++){
  if(lines[i].includes("icon: const Icon(Icons.explore)") && lines[i+1] && lines[i+1].includes("'Tours & Experiences'")){
    for(let j=i;j>i-25;j--){
      if(lines[j].includes('onPressed: () async {')){
        toursStart=j;
        break;
      }
    }
    console.log('Tours block recalculated at line',toursStart);
  }
}

// Replace Tours & Experiences onPressed - always Viator
if(toursStart>0){
  let depth=0, end=toursStart;
  for(let i=toursStart;i<toursStart+20;i++){
    if(lines[i].includes('{'))depth++;
    if(lines[i].includes('}')){depth--;if(depth===0){end=i;break;}}
  }
  const indent='                  ';
  const newBlock=[
    `${indent}onPressed: () async {`,
    `${indent}  final q = Uri.encodeComponent('\${park.city ?? ''} \${park.name} tours'.trim());`,
    `${indent}  final url = Uri.parse('https://www.viator.com/search/\$q?pid=P00298240&mcid=42383&medium=link');`,
    `${indent}  await launchUrl(url, mode: LaunchMode.externalApplication);`,
    `${indent}},`,
  ];
  lines.splice(toursStart, end-toursStart+1, ...newBlock);
  console.log('Tours & Experiences fixed - always Viator');
}

fs.writeFileSync(path,lines.join('\n'),'utf8');
console.log('Done');