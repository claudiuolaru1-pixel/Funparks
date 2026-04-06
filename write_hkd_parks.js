const fs=require('fs');
function readJson(path){let raw=fs.readFileSync(path,'utf8');if(raw.charCodeAt(0)===0xFEFF)raw=raw.slice(1);return JSON.parse(raw);}

const parkEntry={id:"hong_kong_disneyland",thumbnailAsset:"assets/images/hong_kong_disneyland/park_thumbnail.png",tailAsset:"",name:"Hong Kong Disneyland",type:"Theme Park",entryPrice:{child:419,adult:639},currency:"HKD",openingHours:"10:00 - 20:00",lng:114.0440,country:"Hong Kong",city:"Lantau Island",ticketsUrl:"https://www.hongkongdisneyland.com/tickets/",queueTimesId:0};

const indexEntry={id:"hong_kong_disneyland",name:"Hong Kong Disneyland",city:"Lantau Island",country:"Hong Kong",type:"Theme Park",lat:22.3130,lng:114.0440,thumbnail:"assets/images/hong_kong_disneyland/park_thumbnail.png",website:"https://www.hongkongdisneyland.com/",ticketsUrl:"https://www.hongkongdisneyland.com/tickets/",detailAsset:"",openingHours:"10:00 - 20:00",entryPrices:{adult:639,child:419},currency:"HKD",queueTimesId:0};

const parks=readJson('assets/data/parks.json');
if(!parks.find(p=>p.id==='hong_kong_disneyland')){parks.push(parkEntry);fs.writeFileSync('assets/data/parks.json',JSON.stringify(parks,null,4),'utf8');console.log('parks.json updated, total:',parks.length);}
else{console.log('already exists');}
const index=readJson('assets/data/parks/parks_index.json');
if(!index.find(p=>p.id==='hong_kong_disneyland')){index.push(indexEntry);fs.writeFileSync('assets/data/parks/parks_index.json',JSON.stringify(index,null,4),'utf8');console.log('parks_index.json updated, total:',index.length);}
else{console.log('already exists');}