const fs=require('fs');
function readJson(p){let r=fs.readFileSync(p,'utf8');if(r.charCodeAt(0)===0xFEFF)r=r.slice(1);return JSON.parse(r);}
function writeJson(p,d){fs.writeFileSync(p,JSON.stringify(d,null,4),'utf8');}

const url='https://www.parquewarner.com/en/comprar-entradas';

['assets/data/parks/parks_index.json','assets/data/parks.json'].forEach(p=>{
  const data=readJson(p);
  const park=data.find(x=>x.id==='parque_warner_madrid');
  if(park){park.ticketsUrl=url;writeJson(p,data);console.log('Fixed in',p);}
});