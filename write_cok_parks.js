const fs=require('fs');
function readJson(path){let raw=fs.readFileSync(path,'utf8');if(raw.charCodeAt(0)===0xFEFF)raw=raw.slice(1);return JSON.parse(raw);}

const parkEntry={id:"chimelong_ocean_kingdom",thumbnailAsset:"assets/images/chimelong_ocean_kingdom/park_thumbnail.png",tailAsset:"",name:"Chimelong Ocean Kingdom",type:"Theme Park",entryPrice:{child:260,adult:380},currency:"CNY",openingHours:"10:00 - 20:00",lng:113.5620,country:"China",city:"Zhuhai, Guangdong",ticketsUrl:"https://www.chimelong.com/hengqin/ticket/",queueTimesId:0};

const indexEntry={id:"chimelong_ocean_kingdom",name:"Chimelong Ocean Kingdom",city:"Zhuhai, Guangdong",country:"China",type:"Theme Park",lat:22.1100,lng:113.5620,thumbnail:"assets/images/chimelong_ocean_kingdom/park_thumbnail.png",website:"https://www.chimelong.com/hengqin/",ticketsUrl:"https://www.chimelong.com/hengqin/ticket/",detailAsset:"",openingHours:"10:00 - 20:00",entryPrices:{adult:380,child:260},currency:"CNY",queueTimesId:0};

const parks=readJson('assets/data/parks.json');
if(!parks.find(p=>p.id==='chimelong_ocean_kingdom')){parks.push(parkEntry);fs.writeFileSync('assets/data/parks.json',JSON.stringify(parks,null,4),'utf8');console.log('parks.json updated, total:',parks.length);}
else{console.log('already exists');}
const index=readJson('assets/data/parks/parks_index.json');
if(!index.find(p=>p.id==='chimelong_ocean_kingdom')){index.push(indexEntry);fs.writeFileSync('assets/data/parks/parks_index.json',JSON.stringify(index,null,4),'utf8');console.log('parks_index.json updated, total:',index.length);}
else{console.log('already exists');}