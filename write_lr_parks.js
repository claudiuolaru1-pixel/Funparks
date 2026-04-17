const fs=require('fs');
function readJson(p){let r=fs.readFileSync(p,'utf8');if(r.charCodeAt(0)===0xFEFF)r=r.slice(1);return JSON.parse(r);}
const pe={id:"la_ronde",thumbnailAsset:"assets/images/la_ronde/park_thumbnail.png",tailAsset:"",name:"La Ronde",type:"Theme Park",entryPrice:{child:44,adult:49},currency:"CAD",openingHours:"11:00 - 22:00",lng:-73.5330,country:"Canada",city:"Montreal, Quebec",ticketsUrl:"https://www.laronde.com/larondepark/en/tickets",queueTimesId:0};
const ie={id:"la_ronde",name:"La Ronde",city:"Montreal, Quebec",country:"Canada",type:"Theme Park",lat:45.5088,lng:-73.5330,thumbnail:"assets/images/la_ronde/park_thumbnail.png",website:"https://www.laronde.com/",ticketsUrl:"https://www.laronde.com/larondepark/en/tickets",detailAsset:"",openingHours:"11:00 - 22:00",entryPrices:{adult:49,child:44},currency:"CAD",queueTimesId:0};
const parks=readJson('assets/data/parks.json');
if(!parks.find(p=>p.id==='la_ronde')){parks.push(pe);fs.writeFileSync('assets/data/parks.json',JSON.stringify(parks,null,4),'utf8');console.log('parks.json:',parks.length);}
const index=readJson('assets/data/parks/parks_index.json');
if(!index.find(p=>p.id==='la_ronde')){index.push(ie);fs.writeFileSync('assets/data/parks/parks_index.json',JSON.stringify(index,null,4),'utf8');console.log('parks_index.json:',index.length);}