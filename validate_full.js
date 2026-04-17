const fs=require('fs');
function readJson(p){let r=fs.readFileSync(p,'utf8');if(r.charCodeAt(0)===0xFEFF)r=r.slice(1);return JSON.parse(r);}
const required=['id','name','city','country','lat','lng','thumbnail','website','entryPrices','openingHours','currency'];
const index=readJson('assets/data/parks/parks_index.json');
let ok=true;
index.forEach((p,i)=>{
  required.forEach(k=>{
    if(p[k]===undefined||p[k]===null||p[k]===''){
      console.log(`BAD [${i}] ${p.id}: missing "${k}"`);
      ok=false;
    }
  });
  if(p.entryPrices && (p.entryPrices.adult===undefined||p.entryPrices.child===undefined)){
    console.log(`BAD [${i}] ${p.id}: entryPrices missing adult or child`);
    ok=false;
  }
});
if(ok) console.log('All 52 entries valid');