const fs=require('fs');
['cedar_point','six_flags_magic_mountain','parque_de_la_costa'].forEach(id=>{
  const d=JSON.parse(fs.readFileSync(id+'_i18n_source.json','utf8'));
  fs.writeFileSync('assets/i18n/'+id+'.json',JSON.stringify(d,null,2),'utf8');
  console.log(id,'done:',fs.statSync('assets/i18n/'+id+'.json').size,'bytes');
});