const fs = require('fs');
const d = JSON.parse(fs.readFileSync('tokyo_i18n_source.json', 'utf8'));
fs.writeFileSync('assets/i18n/tokyo_disneyland.json', JSON.stringify(d, null, 2), 'utf8');
console.log('Done! Size:', fs.statSync('assets/i18n/tokyo_disneyland.json').size, 'bytes');