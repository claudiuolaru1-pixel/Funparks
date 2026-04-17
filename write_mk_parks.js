const fs=require('fs');
function readJson(path){let raw=fs.readFileSync(path,'utf8');if(raw.charCodeAt(0)===0xFEFF)raw=raw.slice(1);return JSON.parse(raw);}
const parkEntry={id:"magic_kingdom",thumbnailAsset:"assets/images/magic_kingdom/park_thumbnail.png",tailAsset:"",name:"Magic Kingdom",type:"Theme Park",entryPrice:{child:109,adult:114},currency:"USD",openingHours:"09:00 - 22:00",lng:-81.5811,country:"USA",city:"Orlando, Florida",ticketsUrl:"https://www.disneyworld.com/destinations/magic-kingdom/",queueTimesId:0};
const indexEntry={id:"magic_kingdom",name:"Magic Kingdom",city:"Orlando, Florida",country:"USA",type:"Theme Park",lat:28.4194,lng:-81.5811,thumbnail:"assets/images/magic_kingdom/park_thumbnail.png",website:"https://www.disneyworld.com/destinations/magic-kingdom/",ticketsUrl:"https://www.disneyworld.com/destinations/magic-kingdom/",detailAsset:"",openingHours:"09:00 - 22:00",entryPrices:{adult:114,child:109},currency:"USD",queueTimesId:0};
const parks=readJson('assets/data/parks.json');
if(!parks.find(p=>p.id==='magic_kingdom')){parks.push(parkEntry);fs.writeFileSync('assets/data/parks.json',JSON.stringify(parks,null,4),'utf8');console.log('parks.json updated, total:',parks.length);}
else{console.log('already exists');}
const index=readJson('assets/data/parks/parks_index.json');
if(!index.find(p=>p.id==='magic_kingdom')){index.push(indexEntry);fs.writeFileSync('assets/data/parks/parks_index.json',JSON.stringify(index,null,4),'utf8');console.log('parks_index.json updated, total:',index.length);}
else{console.log('already exists');}