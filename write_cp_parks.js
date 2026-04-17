const fs=require('fs');
function readJson(p){let r=fs.readFileSync(p,'utf8');if(r.charCodeAt(0)===0xFEFF)r=r.slice(1);return JSON.parse(r);}
const pe={id:"calaway_park",thumbnailAsset:"assets/images/calaway_park/park_thumbnail.png",tailAsset:"",name:"Calaway Park",type:"Theme Park",entryPrice:{child:36,adult:42},currency:"CAD",openingHours:"10:00 - 20:00",lng:-114.2108,country:"Canada",city:"Calgary, Alberta",ticketsUrl:"https://www.calawaypark.com/tickets/",queueTimesId:0};
const ie={id:"calaway_park",name:"Calaway Park",city:"Calgary, Alberta",country:"Canada",type:"Theme Park",lat:51.0862,lng:-114.2108,thumbnail:"assets/images/calaway_park/park_thumbnail.png",website:"https://www.calawaypark.com/",ticketsUrl:"https://www.calawaypark.com/tickets/",detailAsset:"",openingHours:"10:00 - 20:00",entryPrices:{adult:42,child:36},currency:"CAD",queueTimesId:0};
const parks=readJson('assets/data/parks.json');
if(!parks.find(p=>p.id==='calaway_park')){parks.push(pe);fs.writeFileSync('assets/data/parks.json',JSON.stringify(parks,null,4),'utf8');console.log('parks.json:',parks.length);}
const index=readJson('assets/data/parks/parks_index.json');
if(!index.find(p=>p.id==='calaway_park')){index.push(ie);fs.writeFileSync('assets/data/parks/parks_index.json',JSON.stringify(index,null,4),'utf8');console.log('parks_index.json:',index.length);}