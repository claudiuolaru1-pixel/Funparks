const fs=require('fs');
function readJson(path){let raw=fs.readFileSync(path,'utf8');if(raw.charCodeAt(0)===0xFEFF)raw=raw.slice(1);return JSON.parse(raw);}
const parkEntry={id:"disneyland_park",thumbnailAsset:"assets/images/disneyland_park/park_thumbnail.png",tailAsset:"",name:"Disneyland Park",type:"Theme Park",entryPrice:{child:104,adult:109},currency:"USD",openingHours:"08:00 - 23:00",lng:-117.9189,country:"USA",city:"Anaheim, California",ticketsUrl:"https://disneyland.disney.go.com/tickets/",queueTimesId:0};
const indexEntry={id:"disneyland_park",name:"Disneyland Park",city:"Anaheim, California",country:"USA",type:"Theme Park",lat:33.8121,lng:-117.9189,thumbnail:"assets/images/disneyland_park/park_thumbnail.png",website:"https://disneyland.disney.go.com/",ticketsUrl:"https://disneyland.disney.go.com/tickets/",detailAsset:"",openingHours:"08:00 - 23:00",entryPrices:{adult:109,child:104},currency:"USD",queueTimesId:0};
const parks=readJson('assets/data/parks.json');
if(!parks.find(p=>p.id==='disneyland_park')){parks.push(parkEntry);fs.writeFileSync('assets/data/parks.json',JSON.stringify(parks,null,4),'utf8');console.log('parks.json updated, total:',parks.length);}
else{console.log('already exists');}
const index=readJson('assets/data/parks/parks_index.json');
if(!index.find(p=>p.id==='disneyland_park')){index.push(indexEntry);fs.writeFileSync('assets/data/parks/parks_index.json',JSON.stringify(index,null,4),'utf8');console.log('parks_index.json updated, total:',index.length);}
else{console.log('already exists');}