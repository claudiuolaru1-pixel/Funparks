const fs=require('fs');
function readJson(p){let r=fs.readFileSync(p,'utf8');if(r.charCodeAt(0)===0xFEFF)r=r.slice(1);return JSON.parse(r);}
try {
  const index=readJson('assets/data/parks/parks_index.json');
  console.log('parks_index.json OK, count:',index.length);
  index.forEach((p,i)=>{
    if(!p.id||!p.name||p.lat===undefined||p.lng===undefined){
      console.log('BAD entry at',i,':',JSON.stringify(p).substring(0,100));
    }
  });
  console.log('All entries checked');
} catch(e) {
  console.error('PARSE ERROR:',e.message);
}
try {
  const parks=readJson('assets/data/parks.json');
  console.log('parks.json OK, count:',parks.length);
} catch(e) {
  console.error('parks.json PARSE ERROR:',e.message);
}