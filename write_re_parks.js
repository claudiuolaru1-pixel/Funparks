const fs=require('fs');
function readJson(path){let raw=fs.readFileSync(path,'utf8');if(raw.charCodeAt(0)===0xFEFF)raw=raw.slice(1);return JSON.parse(raw);}

const parkEntry={id:"rainbows_end",thumbnailAsset:"assets/images/rainbows_end/park_thumbnail.png",tailAsset:"",name:"Rainbow's End",type:"Theme Park",entryPrice:{child:44,adult:55},currency:"NZD",openingHours:"10:00 - 17:00",lng:174.8613,country:"New Zealand",city:"Auckland",ticketsUrl:"https://www.rainbowsend.co.nz/tickets/",queueTimesId:0};

const indexEntry={id:"rainbows_end",name:"Rainbow's End",city:"Auckland",country:"New Zealand",type:"Theme Park",lat:-36.9001,lng:174.8613,thumbnail:"assets/images/rainbows_end/park_thumbnail.png",website:"https://www.rainbowsend.co.nz/",ticketsUrl:"https://www.rainbowsend.co.nz/tickets/",detailAsset:"",openingHours:"10:00 - 17:00",entryPrices:{adult:55,child:44},currency:"NZD",queueTimesId:0};

const parks=readJson('assets/data/parks.json');
if(!parks.find(p=>p.id==='rainbows_end')){parks.push(parkEntry);fs.writeFileSync('assets/data/parks.json',JSON.stringify(parks,null,4),'utf8');console.log('parks.json updated, total:',parks.length);}
else{console.log('already exists');}
const index=readJson('assets/data/parks/parks_index.json');
if(!index.find(p=>p.id==='rainbows_end')){index.push(indexEntry);fs.writeFileSync('assets/data/parks/parks_index.json',JSON.stringify(index,null,4),'utf8');console.log('parks_index.json updated, total:',index.length);}
else{console.log('already exists');}