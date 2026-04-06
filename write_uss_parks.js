const fs=require('fs');
function readJson(path){let raw=fs.readFileSync(path,'utf8');if(raw.charCodeAt(0)===0xFEFF)raw=raw.slice(1);return JSON.parse(raw);}

const parkEntry={id:"universal_studios_singapore",thumbnailAsset:"assets/images/universal_studios_singapore/park_thumbnail.png",tailAsset:"",name:"Universal Studios Singapore",type:"Theme Park",entryPrice:{child:68,adult:83},currency:"SGD",openingHours:"10:00 - 19:00",lng:103.8238,country:"Singapore",city:"Sentosa Island",ticketsUrl:"https://www.rwsentosa.com/en/attractions/universal-studios-singapore/buy-tickets",queueTimesId:0};

const indexEntry={id:"universal_studios_singapore",name:"Universal Studios Singapore",city:"Sentosa Island",country:"Singapore",type:"Theme Park",lat:1.2543,lng:103.8238,thumbnail:"assets/images/universal_studios_singapore/park_thumbnail.png",website:"https://www.universalstudiossingapore.com/",ticketsUrl:"https://www.rwsentosa.com/en/attractions/universal-studios-singapore/buy-tickets",detailAsset:"",openingHours:"10:00 - 19:00",entryPrices:{adult:83,child:68},currency:"SGD",queueTimesId:0};

const parks=readJson('assets/data/parks.json');
if(!parks.find(p=>p.id==='universal_studios_singapore')){parks.push(parkEntry);fs.writeFileSync('assets/data/parks.json',JSON.stringify(parks,null,4),'utf8');console.log('parks.json updated, total:',parks.length);}
else{console.log('already exists');}
const index=readJson('assets/data/parks/parks_index.json');
if(!index.find(p=>p.id==='universal_studios_singapore')){index.push(indexEntry);fs.writeFileSync('assets/data/parks/parks_index.json',JSON.stringify(index,null,4),'utf8');console.log('parks_index.json updated, total:',index.length);}
else{console.log('already exists');}