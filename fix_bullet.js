const fs=require('fs');
let c=fs.readFileSync('lib/screens/park_detail_screen.dart','utf8');
// Replace corrupted bullet with clean one
const before=c.length;
c=c.replace(/return 'Adult \$a [^']+Child \$c \${park\.currency}';/,
  "return 'Adult \$a \u2022 Child \$c \${park.currency}';");
fs.writeFileSync('lib/screens/park_detail_screen.dart',c,'utf8');
console.log('Fixed:', c.includes('\u2022') ? 'YES' : 'NO');