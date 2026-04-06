const fs=require('fs');
function readJson(path){let raw=fs.readFileSync(path,'utf8');if(raw.charCodeAt(0)===0xFEFF)raw=raw.slice(1);return JSON.parse(raw);}

const parkEntry={id:"img_worlds",thumbnailAsset:"assets/images/img_worlds/park_thumbnail.png",tailAsset:"",name:"IMG Worlds of Adventure",type:"Theme Park",entryPrice:{child:275,adult:345},currency:"AED",openingHours:"11:00 - 22:00",lng:55.2880,country:"United Arab Emirates",city:"Dubai",ticketsUrl:"https://www.imgworlds.com/tickets/",queueTimesId:0};

const indexEntry={id:"img_worlds",name:"IMG Worlds of Adventure",city:"Dubai",country:"United Arab Emirates",type:"Theme Park",lat:25.0723,lng:55.2880,thumbnail:"assets/images/img_worlds/park_thumbnail.png",website:"https://www.imgworlds.com/",ticketsUrl:"https://www.imgworlds.com/tickets/",detailAsset:"",openingHours:"11:00 - 22:00",entryPrices:{adult:345,child:275},currency:"AED",queueTimesId:0};

const parks=readJson('assets/data/parks.json');
if(!parks.find(p=>p.id==='img_worlds')){parks.push(parkEntry);fs.writeFileSync('assets/data/parks.json',JSON.stringify(parks,null,4),'utf8');console.log('parks.json updated, total:',parks.length);}
else{console.log('already exists');}
const index=readJson('assets/data/parks/parks_index.json');
if(!index.find(p=>p.id==='img_worlds')){index.push(indexEntry);fs.writeFileSync('assets/data/parks/parks_index.json',JSON.stringify(index,null,4),'utf8');console.log('parks_index.json updated, total:',index.length);}
else{console.log('already exists');}