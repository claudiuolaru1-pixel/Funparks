const fs=require('fs');
const path='lib/screens/park_detail_screen.dart';
const lines=fs.readFileSync(path,'utf8').split('\n');

for(let i=0;i<lines.length;i++){
  // Fix Skip the Line - use priority access / fast track keywords + GYG filter
  if(lines[i].includes("final query = Uri.encodeComponent('${park.city ?? ''} ${park.name}'.trim())")){
    lines[i]=lines[i].replace(
      "final query = Uri.encodeComponent('${park.city ?? ''} ${park.name}'.trim());",
      "final query = Uri.encodeComponent('${park.city ?? ''} ${park.name} priority access fast track'.trim());"
    );
    // Fix GYG URL to include activity type filter
    if(lines[i+2] && lines[i+2].includes('getyourguide.com/s/')){
      lines[i+2]=lines[i+2].replace(
        "url = Uri.parse('https://www.getyourguide.com/s/?q=\$query&partner_id=GVNQTTL');",
        "url = Uri.parse('https://www.getyourguide.com/s/?q=\$query&filters=activity_type%3ASkip+the+Line&partner_id=GVNQTTL');"
      );
    }
    console.log('Fixed Skip the Line query at line',i);
    break;
  }
}

for(let i=0;i<lines.length;i++){
  // Fix Tours - use guided tour / day trip keywords
  if(lines[i].includes("final query = Uri.encodeComponent('${park.city ?? ''} ${park.name} tours'.trim())")){
    lines[i]=lines[i].replace(
      "final query = Uri.encodeComponent('${park.city ?? ''} ${park.name} tours'.trim());",
      "final query = Uri.encodeComponent('${park.city ?? ''} ${park.name} guided tour day trip'.trim());"
    );
    console.log('Fixed Tours query at line',i);
    break;
  }
}

fs.writeFileSync(path,lines.join('\n'),'utf8');
console.log('Done');