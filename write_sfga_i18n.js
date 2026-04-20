const fs=require('fs');
const d=JSON.parse(fs.readFileSync('six_flags_great_adventure_i18n_source.json','utf8'));
fs.writeFileSync('assets/i18n/six_flags_great_adventure.json',JSON.stringify(d,null,2),'utf8');
console.log('done:',fs.statSync('assets/i18n/six_flags_great_adventure.json').size,'bytes');