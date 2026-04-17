const fs=require('fs');
function readJson(path){let raw=fs.readFileSync(path,'utf8');if(raw.charCodeAt(0)===0xFEFF)raw=raw.slice(1);return JSON.parse(raw);}
const parkEntry={id:"epcot",thumbnailAsset:"assets/images/epcot/park_thumbnail.png",tailAsset:"",name:"EPCOT",type:"Theme Park",entryPrice:{child:109,adult:114},currency:"USD",openingHours:"09:00 - 21:00",lng:-81.5494,country:"USA",city:"Orlando, Florida",ticketsUrl:"https://www.disneyworld.com/destinations/epcot/",queueTimesId:0};
const indexEntry={id:"epcot",name:"EPCOT",city:"Orlando, Florida",country:"USA",type:"Theme Park",lat:28.3747,lng:-81.5494,thumbnail:"assets/images/epcot/park_thumbnail.png",website:"https://www.disneyworld.com/destinations/epcot/",ticketsUrl:"https://www.disneyworld.com/destinations/epcot/",detailAsset:"",openingHours:"09:00 - 21:00",entryPrices:{adult:114,child:109},currency:"USD",queueTimesId:0};
const parks=readJson('assets/data/parks.json');
if(!parks.find(p=>p.id==='epcot')){parks.push(parkEntry);fs.writeFileSync('assets/data/parks.json',JSON.stringify(parks,null,4),'utf8');console.log('parks.json updated, total:',parks.length);}
else{console.log('already exists in parks.json');}
const index=readJson('assets/data/parks/parks_index.json');
if(!index.find(p=>p.id==='epcot')){index.push(indexEntry);fs.writeFileSync('assets/data/parks/parks_index.json',JSON.stringify(index,null,4),'utf8');console.log('parks_index.json updated, total:',index.length);}
else{console.log('already exists in parks_index.json');}