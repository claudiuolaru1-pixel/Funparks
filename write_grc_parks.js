const fs=require('fs');
function readJson(path){let raw=fs.readFileSync(path,'utf8');if(raw.charCodeAt(0)===0xFEFF)raw=raw.slice(1);return JSON.parse(raw);}

const parkEntry={id:"gold_reef_city",thumbnailAsset:"assets/images/gold_reef_city/park_thumbnail.png",tailAsset:"",name:"Gold Reef City",type:"Theme Park",entryPrice:{child:175,adult:235},currency:"ZAR",openingHours:"09:30 - 17:00",lng:27.9942,country:"South Africa",city:"Johannesburg",ticketsUrl:"https://www.goldreefcity.co.za/theme-park/tickets",queueTimesId:0};

const indexEntry={id:"gold_reef_city",name:"Gold Reef City",city:"Johannesburg",country:"South Africa",type:"Theme Park",lat:-26.2461,lng:27.9942,thumbnail:"assets/images/gold_reef_city/park_thumbnail.png",website:"https://www.goldreefcity.co.za/",ticketsUrl:"https://www.goldreefcity.co.za/theme-park/tickets",detailAsset:"",openingHours:"09:30 - 17:00",entryPrices:{adult:235,child:175},currency:"ZAR",queueTimesId:0};

const parks=readJson('assets/data/parks.json');
if(!parks.find(p=>p.id==='gold_reef_city')){parks.push(parkEntry);fs.writeFileSync('assets/data/parks.json',JSON.stringify(parks,null,4),'utf8');console.log('parks.json updated, total:',parks.length);}
else{console.log('parks.json already has gold_reef_city');}

const index=readJson('assets/data/parks/parks_index.json');
if(!index.find(p=>p.id==='gold_reef_city')){index.push(indexEntry);fs.writeFileSync('assets/data/parks/parks_index.json',JSON.stringify(index,null,4),'utf8');console.log('parks_index.json updated, total:',index.length);}
else{console.log('parks_index.json already has gold_reef_city');}