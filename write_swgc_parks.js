const fs=require('fs');
function readJson(path){let raw=fs.readFileSync(path,'utf8');if(raw.charCodeAt(0)===0xFEFF)raw=raw.slice(1);return JSON.parse(raw);}

const parkEntry={id:"sea_world_gold_coast",thumbnailAsset:"assets/images/sea_world_gold_coast/park_thumbnail.png",tailAsset:"",name:"Sea World Gold Coast",type:"Theme Park",entryPrice:{child:99,adult:119},currency:"AUD",openingHours:"09:30 - 17:00",lng:153.4283,country:"Australia",city:"Gold Coast, Queensland",ticketsUrl:"https://www.seaworld.com.au/tickets",queueTimesId:0};

const indexEntry={id:"sea_world_gold_coast",name:"Sea World Gold Coast",city:"Gold Coast, Queensland",country:"Australia",type:"Theme Park",lat:-27.9625,lng:153.4283,thumbnail:"assets/images/sea_world_gold_coast/park_thumbnail.png",website:"https://www.seaworld.com.au/",ticketsUrl:"https://www.seaworld.com.au/tickets",detailAsset:"",openingHours:"09:30 - 17:00",entryPrices:{adult:119,child:99},currency:"AUD",queueTimesId:0};

const parks=readJson('assets/data/parks.json');
if(!parks.find(p=>p.id==='sea_world_gold_coast')){parks.push(parkEntry);fs.writeFileSync('assets/data/parks.json',JSON.stringify(parks,null,4),'utf8');console.log('parks.json updated, total:',parks.length);}
else{console.log('already exists');}
const index=readJson('assets/data/parks/parks_index.json');
if(!index.find(p=>p.id==='sea_world_gold_coast')){index.push(indexEntry);fs.writeFileSync('assets/data/parks/parks_index.json',JSON.stringify(index,null,4),'utf8');console.log('parks_index.json updated, total:',index.length);}
else{console.log('already exists');}