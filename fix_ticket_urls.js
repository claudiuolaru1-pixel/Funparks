const fs=require('fs');
function readJson(p){let r=fs.readFileSync(p,'utf8');if(r.charCodeAt(0)===0xFEFF)r=r.slice(1);return JSON.parse(r);}
function writeJson(p,d){fs.writeFileSync(p,JSON.stringify(d,null,4),'utf8');}

// Fix Parque de la Costa tickets URL
const indexPath='assets/data/parks/parks_index.json';
const index=readJson(indexPath);

const pdlc=index.find(p=>p.id==='parque_de_la_costa');
if(pdlc){
  pdlc.ticketsUrl='https://www.parquedelacosta.com.ar/pasaportes/';
  console.log('Fixed Parque de la Costa tickets URL');
}

const pw=index.find(p=>p.id==='parque_warner');
if(pw){
  pw.ticketsUrl='https://www.parquewarner.com/entradas-generales/single-ticket/select-visitors';
  console.log('Fixed Parque Warner tickets URL');
} else {
  console.log('Parque Warner not found - checking IDs...');
  index.filter(p=>p.name.toLowerCase().includes('warner')).forEach(p=>console.log(p.id, p.name));
}

writeJson(indexPath,index);

// Also fix parks.json
const parksPath='assets/data/parks.json';
const parks=readJson(parksPath);

const pdlc2=parks.find(p=>p.id==='parque_de_la_costa');
if(pdlc2){pdlc2.ticketsUrl='https://www.parquedelacosta.com.ar/pasaportes/';console.log('Fixed parks.json pdlc');}

const pw2=parks.find(p=>p.name.toLowerCase().includes('warner'));
if(pw2){
  pw2.ticketsUrl='https://www.parquewarner.com/entradas-generales/single-ticket/select-visitors';
  console.log('Fixed parks.json warner:',pw2.id);
}

writeJson(parksPath,parks);
console.log('Done');