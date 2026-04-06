const fs=require('fs');
function readJson(path){let raw=fs.readFileSync(path,'utf8');if(raw.charCodeAt(0)===0xFEFF)raw=raw.slice(1);return JSON.parse(raw);}

const parkEntry={id:"happy_valley_beijing",thumbnailAsset:"assets/images/happy_valley_beijing/park_thumbnail.png",tailAsset:"",name:"Happy Valley Beijing",type:"Theme Park",entryPrice:{child:200,adult:280},currency:"CNY",openingHours:"10:00 - 20:00",lng:116.4732,country:"China",city:"Beijing",ticketsUrl:"https://www.happyvalley.cn/beijing/ticket/",queueTimesId:0};

const indexEntry={id:"happy_valley_beijing",name:"Happy Valley Beijing",city:"Beijing",country:"China",type:"Theme Park",lat:39.8956,lng:116.4732,thumbnail:"assets/images/happy_valley_beijing/park_thumbnail.png",website:"https://www.happyvalley.cn/beijing/",ticketsUrl:"https://www.happyvalley.cn/beijing/ticket/",detailAsset:"",openingHours:"10:00 - 20:00",entryPrices:{adult:280,child:200},currency:"CNY",queueTimesId:0};

const parks=readJson('assets/data/parks.json');
if(!parks.find(p=>p.id==='happy_valley_beijing')){parks.push(parkEntry);fs.writeFileSync('assets/data/parks.json',JSON.stringify(parks,null,4),'utf8');console.log('parks.json updated, total:',parks.length);}
else{console.log('already exists');}
const index=readJson('assets/data/parks/parks_index.json');
if(!index.find(p=>p.id==='happy_valley_beijing')){index.push(indexEntry);fs.writeFileSync('assets/data/parks/parks_index.json',JSON.stringify(index,null,4),'utf8');console.log('parks_index.json updated, total:',index.length);}
else{console.log('already exists');}