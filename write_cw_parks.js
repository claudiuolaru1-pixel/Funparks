const fs=require('fs');
function readJson(path){let raw=fs.readFileSync(path,'utf8');if(raw.charCodeAt(0)===0xFEFF)raw=raw.slice(1);return JSON.parse(raw);}
const parkEntry={id:"canadas_wonderland",thumbnailAsset:"assets/images/canadas_wonderland/park_thumbnail.png",tailAsset:"",name:"Canada's Wonderland",type:"Theme Park",entryPrice:{child:44,adult:49},currency:"CAD",openingHours:"10:00 - 22:00",lng:-79.5384,country:"Canada",city:"Vaughan, Ontario",ticketsUrl:"https://www.canadaswonderland.com/tickets",queueTimesId:0};
const indexEntry={id:"canadas_wonderland",name:"Canada's Wonderland",city:"Vaughan, Ontario",country:"Canada",type:"Theme Park",lat:43.8428,lng:-79.5384,thumbnail:"assets/images/canadas_wonderland/park_thumbnail.png",website:"https://www.canadaswonderland.com/",ticketsUrl:"https://www.canadaswonderland.com/tickets",detailAsset:"",openingHours:"10:00 - 22:00",entryPrices:{adult:49,child:44},currency:"CAD",queueTimesId:0};
const parks=readJson('assets/data/parks.json');
if(!parks.find(p=>p.id==='canadas_wonderland')){parks.push(parkEntry);fs.writeFileSync('assets/data/parks.json',JSON.stringify(parks,null,4),'utf8');console.log('parks.json updated, total:',parks.length);}
else{console.log('already exists in parks.json');}
const index=readJson('assets/data/parks/parks_index.json');
if(!index.find(p=>p.id==='canadas_wonderland')){index.push(indexEntry);fs.writeFileSync('assets/data/parks/parks_index.json',JSON.stringify(index,null,4),'utf8');console.log('parks_index.json updated, total:',index.length);}
else{console.log('already exists in parks_index.json');}