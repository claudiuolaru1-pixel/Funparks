const fs=require('fs');
function readJson(path){let raw=fs.readFileSync(path,'utf8');if(raw.charCodeAt(0)===0xFEFF)raw=raw.slice(1);return JSON.parse(raw);}
const url='https://www.betocarrero.com.br/passaportes';
const index=readJson('assets/data/parks/parks_index.json');
const p=index.find(p=>p.id==='beto_carrero_world');
p.ticketsUrl=url;
fs.writeFileSync('assets/data/parks/parks_index.json',JSON.stringify(index,null,4),'utf8');
const parks=readJson('assets/data/parks.json');
const pp=parks.find(p=>p.id==='beto_carrero_world');
pp.ticketsUrl=url;
fs.writeFileSync('assets/data/parks.json',JSON.stringify(parks,null,4),'utf8');
console.log('Done');