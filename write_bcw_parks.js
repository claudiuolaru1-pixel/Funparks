const fs=require('fs');
function readJson(path){let raw=fs.readFileSync(path,'utf8');if(raw.charCodeAt(0)===0xFEFF)raw=raw.slice(1);return JSON.parse(raw);}
const parkEntry={id:"beto_carrero_world",thumbnailAsset:"assets/images/beto_carrero_world/park_thumbnail.png",tailAsset:"",name:"Beto Carrero World",type:"Theme Park",entryPrice:{child:170,adult:220},currency:"BRL",openingHours:"09:00 - 18:00",lng:-48.6453,country:"Brazil",city:"Penha, Santa Catarina",ticketsUrl:"https://www.betocarrero.com.br/ingressos",queueTimesId:0};
const indexEntry={id:"beto_carrero_world",name:"Beto Carrero World",city:"Penha, Santa Catarina",country:"Brazil",type:"Theme Park",lat:-26.7814,lng:-48.6453,thumbnail:"assets/images/beto_carrero_world/park_thumbnail.png",website:"https://www.betocarrero.com.br/",ticketsUrl:"https://www.betocarrero.com.br/ingressos",detailAsset:"",openingHours:"09:00 - 18:00",entryPrices:{adult:220,child:170},currency:"BRL",queueTimesId:0};
const parks=readJson('assets/data/parks.json');
if(!parks.find(p=>p.id==='beto_carrero_world')){parks.push(parkEntry);fs.writeFileSync('assets/data/parks.json',JSON.stringify(parks,null,4),'utf8');console.log('parks.json updated, total:',parks.length);}
else{console.log('already exists');}
const index=readJson('assets/data/parks/parks_index.json');
if(!index.find(p=>p.id==='beto_carrero_world')){index.push(indexEntry);fs.writeFileSync('assets/data/parks/parks_index.json',JSON.stringify(index,null,4),'utf8');console.log('parks_index.json updated, total:',index.length);}
else{console.log('already exists');}