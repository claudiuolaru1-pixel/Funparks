const fs=require('fs');
const files=[
  'lib/screens/home_map_screen.dart',
  'lib/screens/start_screen.dart'
];
files.forEach(f=>{
  const p=require('path').join(process.cwd(),f);
  let c=fs.readFileSync(p,'utf8');
  const updated=c.replace(/sounds\/water_plop\.wav/g,'sounds/water_drop.mp3');
  if(c!==updated){fs.writeFileSync(p,updated,'utf8');console.log('fixed sound in:',f);}
  else{console.log('no change needed:',f);}
});