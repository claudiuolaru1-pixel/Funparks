const fs=require('fs');
function readJson(path){let raw=fs.readFileSync(path,'utf8');if(raw.charCodeAt(0)===0xFEFF)raw=raw.slice(1);return JSON.parse(raw);}

const parkEntry={id:"dreamworld_australia",thumbnailAsset:"assets/images/dreamworld_australia/park_thumbnail.png",tailAsset:"",name:"Dreamworld",type:"Theme Park",entryPrice:{child:79,adult:99},currency:"AUD",openingHours:"10:00 - 17:00",lng:153.3193,country:"Australia",city:"Coomera, Gold Coast",ticketsUrl:"https://www.dreamworld.com.au/tickets",queueTimesId:0};

const indexEntry={id:"dreamworld_australia",name:"Dreamworld",city:"Coomera, Gold Coast",country:"Australia",type:"Theme Park",lat:-27.8638,lng:153.3193,thumbnail:"assets/images/dreamworld_australia/park_thumbnail.png",website:"https://www.dreamworld.com.au/",ticketsUrl:"https://www.dreamworld.com.au/tickets",detailAsset:"",openingHours:"10:00 - 17:00",entryPrices:{adult:99,child:79},currency:"AUD",queueTimesId:0};

const parks=readJson('assets/data/parks.json');
if(!parks.find(p=>p.id==='dreamworld_australia')){parks.push(parkEntry);fs.writeFileSync('assets/data/parks.json',JSON.stringify(parks,null,4),'utf8');console.log('parks.json updated, total:',parks.length);}
else{console.log('already exists');}
const index=readJson('assets/data/parks/parks_index.json');
if(!index.find(p=>p.id==='dreamworld_australia')){index.push(indexEntry);fs.writeFileSync('assets/data/parks/parks_index.json',JSON.stringify(index,null,4),'utf8');console.log('parks_index.json updated, total:',index.length);}
else{console.log('already exists');}