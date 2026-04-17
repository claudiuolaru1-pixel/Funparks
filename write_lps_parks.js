const fs=require('fs');
function readJson(path){let raw=fs.readFileSync(path,'utf8');if(raw.charCodeAt(0)===0xFEFF)raw=raw.slice(1);return JSON.parse(raw);}

const parkEntry={id:"luna_park_sydney",thumbnailAsset:"assets/images/luna_park_sydney/park_thumbnail.png",tailAsset:"",name:"Luna Park Sydney",type:"Theme Park",entryPrice:{child:10,adult:10},currency:"AUD",openingHours:"10:00 - 22:00",lng:151.2100,country:"Australia",city:"Milsons Point, Sydney",ticketsUrl:"https://www.lunaparksydney.com/tickets",queueTimesId:0};

const indexEntry={id:"luna_park_sydney",name:"Luna Park Sydney",city:"Milsons Point, Sydney",country:"Australia",type:"Theme Park",lat:-33.8484,lng:151.2100,thumbnail:"assets/images/luna_park_sydney/park_thumbnail.png",website:"https://www.lunaparksydney.com/",ticketsUrl:"https://www.lunaparksydney.com/tickets",detailAsset:"",openingHours:"10:00 - 22:00",entryPrices:{adult:10,child:10},currency:"AUD",queueTimesId:0};

const parks=readJson('assets/data/parks.json');
if(!parks.find(p=>p.id==='luna_park_sydney')){parks.push(parkEntry);fs.writeFileSync('assets/data/parks.json',JSON.stringify(parks,null,4),'utf8');console.log('parks.json updated, total:',parks.length);}
else{console.log('already exists');}
const index=readJson('assets/data/parks/parks_index.json');
if(!index.find(p=>p.id==='luna_park_sydney')){index.push(indexEntry);fs.writeFileSync('assets/data/parks/parks_index.json',JSON.stringify(index,null,4),'utf8');console.log('parks_index.json updated, total:',index.length);}
else{console.log('already exists');}