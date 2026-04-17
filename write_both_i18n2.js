const fs=require('fs');
const lr=JSON.parse(fs.readFileSync('la_ronde_i18n_source.json','utf8'));
fs.writeFileSync('assets/i18n/la_ronde.json',JSON.stringify(lr,null,2),'utf8');
console.log('La Ronde i18n done:',fs.statSync('assets/i18n/la_ronde.json').size,'bytes');
const cp=JSON.parse(fs.readFileSync('calaway_park_i18n_source.json','utf8'));
fs.writeFileSync('assets/i18n/calaway_park.json',JSON.stringify(cp,null,2),'utf8');
console.log('Calaway Park i18n done:',fs.statSync('assets/i18n/calaway_park.json').size,'bytes');