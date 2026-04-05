const fs=require('fs');
function readJson(path){let raw=fs.readFileSync(path,'utf8');if(raw.charCodeAt(0)===0xFEFF)raw=raw.slice(1);return JSON.parse(raw);}

const parkEntry={id:"lotte_world",thumbnailAsset:"assets/images/lotte_world/park_thumbnail.png",tailAsset:"",name:"Lotte World",type:"Theme Park",entryPrice:{child:52000,adult:62000},currency:"KRW",openingHours:"09:30 - 21:00",lng:127.0982,country:"South Korea",city:"Seoul",ticketsUrl:"https://adventure.lotteworld.com/eng/ticket/index.do",queueTimesId:0};

const indexEntry={id:"lotte_world",name:"Lotte World",city:"Seoul",country:"South Korea",type:"Theme Park",lat:37.5111,lng:127.0982,thumbnail:"assets/images/lotte_world/park_thumbnail.png",website:"https://adventure.lotteworld.com/eng/main/index.do",ticketsUrl:"https://adventure.lotteworld.com/eng/ticket/index.do",detailAsset:"",openingHours:"09:30 - 21:00",entryPrices:{adult:62000,child:52000},currency:"KRW",queueTimesId:0};

const parks=readJson('assets/data/parks.json');
if(!parks.find(p=>p.id==='lotte_world')){parks.push(parkEntry);fs.writeFileSync('assets/data/parks.json',JSON.stringify(parks,null,4),'utf8');console.log('parks.json updated, total:',parks.length);}
else{console.log('already exists');}
const index=readJson('assets/data/parks/parks_index.json');
if(!index.find(p=>p.id==='lotte_world')){index.push(indexEntry);fs.writeFileSync('assets/data/parks/parks_index.json',JSON.stringify(index,null,4),'utf8');console.log('parks_index.json updated, total:',index.length);}
else{console.log('already exists');}