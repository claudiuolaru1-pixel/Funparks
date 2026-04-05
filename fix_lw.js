const fs=require('fs');
function readJson(path){let raw=fs.readFileSync(path,'utf8');if(raw.charCodeAt(0)===0xFEFF)raw=raw.slice(1);return JSON.parse(raw);}

const ticketsUrl='https://advticket.lotteworld.com/productList';
const website='https://www.lotteworld.com/';

const index=readJson('assets/data/parks/parks_index.json');
const lw=index.find(p=>p.id==='lotte_world');
lw.ticketsUrl=ticketsUrl;
lw.website=website;
fs.writeFileSync('assets/data/parks/parks_index.json',JSON.stringify(index,null,4),'utf8');

const parks=readJson('assets/data/parks.json');
const lwp=parks.find(p=>p.id==='lotte_world');
lwp.ticketsUrl=ticketsUrl;
fs.writeFileSync('assets/data/parks.json',JSON.stringify(parks,null,4),'utf8');
console.log('Done');