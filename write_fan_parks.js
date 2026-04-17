const fs=require('fs');
function readJson(path){let raw=fs.readFileSync(path,'utf8');if(raw.charCodeAt(0)===0xFEFF)raw=raw.slice(1);return JSON.parse(raw);}
const parkEntry={id:"fantasilandia",thumbnailAsset:"assets/images/fantasilandia/park_thumbnail.png",tailAsset:"",name:"Fantasilandia",type:"Theme Park",entryPrice:{child:12000,adult:18000},currency:"CLP",openingHours:"11:00 - 21:00",lng:-70.6506,country:"Chile",city:"Santiago",ticketsUrl:"https://www.fantasilandia.cl/entradas",queueTimesId:0};
const indexEntry={id:"fantasilandia",name:"Fantasilandia",city:"Santiago",country:"Chile",type:"Theme Park",lat:-33.4674,lng:-70.6506,thumbnail:"assets/images/fantasilandia/park_thumbnail.png",website:"https://www.fantasilandia.cl/",ticketsUrl:"https://www.fantasilandia.cl/entradas",detailAsset:"",openingHours:"11:00 - 21:00",entryPrices:{adult:18000,child:12000},currency:"CLP",queueTimesId:0};
const parks=readJson('assets/data/parks.json');
if(!parks.find(p=>p.id==='fantasilandia')){parks.push(parkEntry);fs.writeFileSync('assets/data/parks.json',JSON.stringify(parks,null,4),'utf8');console.log('parks.json updated, total:',parks.length);}
else{console.log('already exists');}
const index=readJson('assets/data/parks/parks_index.json');
if(!index.find(p=>p.id==='fantasilandia')){index.push(indexEntry);fs.writeFileSync('assets/data/parks/parks_index.json',JSON.stringify(index,null,4),'utf8');console.log('parks_index.json updated, total:',index.length);}
else{console.log('already exists');}