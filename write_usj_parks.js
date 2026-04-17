const fs=require('fs');
function readJson(path){let raw=fs.readFileSync(path,'utf8');if(raw.charCodeAt(0)===0xFEFF)raw=raw.slice(1);return JSON.parse(raw);}

const parkEntry={id:"universal_studios_japan",thumbnailAsset:"assets/images/universal_studios_japan/park_thumbnail.png",tailAsset:"",name:"Universal Studios Japan",type:"Theme Park",entryPrice:{child:7400,adult:9400},currency:"JPY",openingHours:"09:00 - 21:00",lng:135.4323,country:"Japan",city:"Osaka",ticketsUrl:"https://www.usj.co.jp/web/en/us/tickets",queueTimesId:0};

const indexEntry={id:"universal_studios_japan",name:"Universal Studios Japan",city:"Osaka",country:"Japan",type:"Theme Park",lat:34.6654,lng:135.4323,thumbnail:"assets/images/universal_studios_japan/park_thumbnail.png",website:"https://www.usj.co.jp/web/en/us",ticketsUrl:"https://www.usj.co.jp/web/en/us/tickets",detailAsset:"",openingHours:"09:00 - 21:00",entryPrices:{adult:9400,child:7400},currency:"JPY",queueTimesId:0};

const parks=readJson('assets/data/parks.json');
if(!parks.find(p=>p.id==='universal_studios_japan')){parks.push(parkEntry);fs.writeFileSync('assets/data/parks.json',JSON.stringify(parks,null,4),'utf8');console.log('parks.json updated, total:',parks.length);}
else{console.log('already exists');}
const index=readJson('assets/data/parks/parks_index.json');
if(!index.find(p=>p.id==='universal_studios_japan')){index.push(indexEntry);fs.writeFileSync('assets/data/parks/parks_index.json',JSON.stringify(index,null,4),'utf8');console.log('parks_index.json updated, total:',index.length);}
else{console.log('already exists');}