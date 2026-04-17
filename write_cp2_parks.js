const fs=require('fs');
function readJson(p){let r=fs.readFileSync(p,'utf8');if(r.charCodeAt(0)===0xFEFF)r=r.slice(1);return JSON.parse(r);}
const pe={id:"cedar_point",thumbnailAsset:"assets/images/cedar_point/park_thumbnail.png",tailAsset:"",name:"Cedar Point",type:"Theme Park",entryPrice:{child:59,adult:69},currency:"USD",openingHours:"10:00 - 22:00",lng:-82.6837,country:"USA",city:"Sandusky, Ohio",ticketsUrl:"https://www.cedarpoint.com/tickets-passes",queueTimesId:0};
const ie={id:"cedar_point",name:"Cedar Point",city:"Sandusky, Ohio",country:"USA",type:"Theme Park",lat:41.4793,lng:-82.6837,thumbnail:"assets/images/cedar_point/park_thumbnail.png",website:"https://www.cedarpoint.com/",ticketsUrl:"https://www.cedarpoint.com/tickets-passes",detailAsset:"",openingHours:"10:00 - 22:00",entryPrices:{adult:69,child:59},currency:"USD",queueTimesId:0};
const parks=readJson('assets/data/parks.json');
if(!parks.find(p=>p.id==='cedar_point')){parks.push(pe);fs.writeFileSync('assets/data/parks.json',JSON.stringify(parks,null,4),'utf8');console.log('parks.json:',parks.length);}
const index=readJson('assets/data/parks/parks_index.json');
if(!index.find(p=>p.id==='cedar_point')){index.push(ie);fs.writeFileSync('assets/data/parks/parks_index.json',JSON.stringify(index,null,4),'utf8');console.log('parks_index.json:',index.length);}