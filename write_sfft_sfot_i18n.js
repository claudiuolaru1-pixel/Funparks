const fs=require('fs');
['six_flags_fiesta_texas','six_flags_over_texas'].forEach(id=>{
  const d=JSON.parse(fs.readFileSync(id+'_i18n_source.json','utf8'));
  fs.writeFileSync('assets/i18n/'+id+'.json',JSON.stringify(d,null,2),'utf8');
  console.log(id,'done:',fs.statSync('assets/i18n/'+id+'.json').size,'bytes');
});