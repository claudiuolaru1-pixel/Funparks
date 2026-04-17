const fs=require('fs');
function readJson(path){let raw=fs.readFileSync(path,'utf8');if(raw.charCodeAt(0)===0xFEFF)raw=raw.slice(1);return JSON.parse(raw);}

const parkEntry={id:"everland",thumbnailAsset:"assets/images/everland/park_thumbnail.png",tailAsset:"",name:"Everland",type:"Theme Park",entryPrice:{child:52000,adult:62000},currency:"KRW",openingHours:"10:00 - 21:00",lng:127.2003,country:"South Korea",city:"Yongin, Gyeonggi-do",ticketsUrl:"https://www.everland.com/web/everland/ticket/index.html",queueTimesId:0};

const indexEntry={id:"everland",name:"Everland",city:"Yongin, Gyeonggi-do",country:"South Korea",type:"Theme Park",lat:37.2939,lng:127.2003,thumbnail:"assets/images/everland/park_thumbnail.png",website:"https://www.everland.com/",ticketsUrl:"https://www.everland.com/web/everland/ticket/index.html",detailAsset:"",openingHours:"10:00 - 21:00",entryPrices:{adult:62000,child:52000},currency:"KRW",queueTimesId:0};

const parks=readJson('assets/data/parks.json');
if(!parks.find(p=>p.id==='everland')){parks.push(parkEntry);fs.writeFileSync('assets/data/parks.json',JSON.stringify(parks,null,4),'utf8');console.log('parks.json updated, total:',parks.length);}
else{console.log('already exists');}
const index=readJson('assets/data/parks/parks_index.json');
if(!index.find(p=>p.id==='everland')){index.push(indexEntry);fs.writeFileSync('assets/data/parks/parks_index.json',JSON.stringify(index,null,4),'utf8');console.log('parks_index.json updated, total:',index.length);}
else{console.log('already exists');}