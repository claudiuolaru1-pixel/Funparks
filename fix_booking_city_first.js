const fs=require('fs');
const path='lib/screens/park_detail_screen.dart';
const lines=fs.readFileSync(path,'utf8').split('\n');

for(let i=0;i<lines.length;i++){
  if(lines[i].includes("final searchQuery = parkCity.isNotEmpty")){
    lines[i]=lines[i].replace(
      "final searchQuery = parkCity.isNotEmpty ? '${hotel.name} $parkCity' : hotel.name;",
      "final searchQuery = parkCity.isNotEmpty ? '$parkCity ${hotel.name}' : hotel.name;"
    );
    console.log('Fixed at line:',i);
    break;
  }
}

fs.writeFileSync(path,lines.join('\n'),'utf8');
console.log('Done');