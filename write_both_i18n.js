const fs=require('fs');
const usf=JSON.parse(fs.readFileSync('universal_studios_florida_i18n_source.json','utf8'));
fs.writeFileSync('assets/i18n/universal_studios_florida.json',JSON.stringify(usf,null,2),'utf8');
console.log('USF i18n done:',fs.statSync('assets/i18n/universal_studios_florida.json').size,'bytes');
const ioa=JSON.parse(fs.readFileSync('islands_of_adventure_i18n_source.json','utf8'));
fs.writeFileSync('assets/i18n/islands_of_adventure.json',JSON.stringify(ioa,null,2),'utf8');
console.log('IOA i18n done:',fs.statSync('assets/i18n/islands_of_adventure.json').size,'bytes');