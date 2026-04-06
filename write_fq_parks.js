const fs=require('fs');
function readJson(path){let raw=fs.readFileSync(path,'utf8');if(raw.charCodeAt(0)===0xFEFF)raw=raw.slice(1);return JSON.parse(raw);}

const parkEntry={id:"fujiq_highland",thumbnailAsset:"assets/images/fujiq_highland/park_thumbnail.png",tailAsset:"",name:"Fuji-Q Highland",type:"Theme Park",entryPrice:{child:2000,adult:6000},currency:"JPY",openingHours:"09:00 - 17:00",lng:138.7820,country:"Japan",city:"Fujiyoshida, Yamanashi",ticketsUrl:"https://www.fujiq.jp/en/ticket/",queueTimesId:0};

const indexEntry={id:"fujiq_highland",name:"Fuji-Q Highland",city:"Fujiyoshida, Yamanashi",country:"Japan",type:"Theme Park",lat:35.4895,lng:138.7820,thumbnail:"assets/images/fujiq_highland/park_thumbnail.png",website:"https://www.fujiq.jp/en/",ticketsUrl:"https://www.fujiq.jp/en/ticket/",detailAsset:"",openingHours:"09:00 - 17:00",entryPrices:{adult:6000,child:2000},currency:"JPY",queueTimesId:0};

const parks=readJson('assets/data/parks.json');
if(!parks.find(p=>p.id==='fujiq_highland')){parks.push(parkEntry);fs.writeFileSync('assets/data/parks.json',JSON.stringify(parks,null,4),'utf8');console.log('parks.json updated, total:',parks.length);}
else{console.log('already exists');}
const index=readJson('assets/data/parks/parks_index.json');
if(!index.find(p=>p.id==='fujiq_highland')){index.push(indexEntry);fs.writeFileSync('assets/data/parks/parks_index.json',JSON.stringify(index,null,4),'utf8');console.log('parks_index.json updated, total:',index.length);}
else{console.log('already exists');}