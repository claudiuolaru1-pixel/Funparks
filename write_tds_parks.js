const fs=require('fs');
function readJson(path){let raw=fs.readFileSync(path,'utf8');if(raw.charCodeAt(0)===0xFEFF)raw=raw.slice(1);return JSON.parse(raw);}

const parkEntry={id:"tokyo_disneysea",thumbnailAsset:"assets/images/tokyo_disneysea/park_thumbnail.png",tailAsset:"",name:"Tokyo DisneySea",type:"Theme Park",entryPrice:{child:7900,adult:10900},currency:"JPY",openingHours:"09:00 - 21:00",lng:139.8855,country:"Japan",city:"Urayasu, Chiba",ticketsUrl:"https://www.tokyodisneyresort.jp/en/ticket/",queueTimesId:0};

const indexEntry={id:"tokyo_disneysea",name:"Tokyo DisneySea",city:"Urayasu, Chiba",country:"Japan",type:"Theme Park",lat:35.6267,lng:139.8855,thumbnail:"assets/images/tokyo_disneysea/park_thumbnail.png",website:"https://www.tokyodisneyresort.jp/en/tds/",ticketsUrl:"https://www.tokyodisneyresort.jp/en/ticket/",detailAsset:"",openingHours:"09:00 - 21:00",entryPrices:{adult:10900,child:7900},currency:"JPY",queueTimesId:0};

const parks=readJson('assets/data/parks.json');
if(!parks.find(p=>p.id==='tokyo_disneysea')){parks.push(parkEntry);fs.writeFileSync('assets/data/parks.json',JSON.stringify(parks,null,4),'utf8');console.log('parks.json updated, total:',parks.length);}
else{console.log('already exists');}
const index=readJson('assets/data/parks/parks_index.json');
if(!index.find(p=>p.id==='tokyo_disneysea')){index.push(indexEntry);fs.writeFileSync('assets/data/parks/parks_index.json',JSON.stringify(index,null,4),'utf8');console.log('parks_index.json updated, total:',index.length);}
else{console.log('already exists');}