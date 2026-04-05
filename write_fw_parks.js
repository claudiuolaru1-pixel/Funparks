const fs=require('fs');
function readJson(path){let raw=fs.readFileSync(path,'utf8');if(raw.charCodeAt(0)===0xFEFF)raw=raw.slice(1);return JSON.parse(raw);}

const parkEntry={id:"ferrari_world",thumbnailAsset:"assets/images/ferrari_world/park_thumbnail.png",tailAsset:"",name:"Ferrari World Abu Dhabi",type:"Theme Park",entryPrice:{child:245,adult:345},currency:"AED",openingHours:"11:00 - 20:00",lng:54.6081,country:"United Arab Emirates",city:"Abu Dhabi",ticketsUrl:"https://www.ferrariworldabudhabi.com/en/buy-tickets",queueTimesId:0};

const indexEntry={id:"ferrari_world",name:"Ferrari World Abu Dhabi",city:"Abu Dhabi",country:"United Arab Emirates",type:"Theme Park",lat:24.4836,lng:54.6081,thumbnail:"assets/images/ferrari_world/park_thumbnail.png",website:"https://www.ferrariworldabudhabi.com/en",ticketsUrl:"https://www.ferrariworldabudhabi.com/en/buy-tickets",detailAsset:"",openingHours:"11:00 - 20:00",entryPrices:{adult:345,child:245},currency:"AED",queueTimesId:0};

const parks=readJson('assets/data/parks.json');
if(!parks.find(p=>p.id==='ferrari_world')){parks.push(parkEntry);fs.writeFileSync('assets/data/parks.json',JSON.stringify(parks,null,4),'utf8');console.log('parks.json updated, total:',parks.length);}
else{console.log('already exists');}
const index=readJson('assets/data/parks/parks_index.json');
if(!index.find(p=>p.id==='ferrari_world')){index.push(indexEntry);fs.writeFileSync('assets/data/parks/parks_index.json',JSON.stringify(index,null,4),'utf8');console.log('parks_index.json updated, total:',index.length);}
else{console.log('already exists');}