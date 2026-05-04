const fs=require('fs');
let c=fs.readFileSync('lib/screens/park_detail_screen.dart','utf8');

// Replace context.watch with context.read inside _I18nLookup methods
// context.watch in helper classes causes issues on iOS AOT release
c=c.replace(/final lang = context\.watch<AppState>\(\)\.languageCode;/g,
  'final lang = context.read<AppState>().languageCode;');

fs.writeFileSync('lib/screens/park_detail_screen.dart',c,'utf8');
const count=(c.match(/context\.watch<AppState>/g)||[]).length;
console.log('Remaining context.watch<AppState>:',count);