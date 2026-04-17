const fs = require('fs');
let code = fs.readFileSync('lib/screens/park_detail_screen.dart', 'utf8');
code = code.replace(/\r\n/g, '\n');

// Attractions — _openDetails(a)
code = code.replaceAll(
  'onTap: () => _openDetails(a),',
  'onTap: () { HapticFeedback.selectionClick(); _openDetails(a); },'
);
console.log('✓ Attraction haptics added');

// Food — _openDetails(context, f)
code = code.replaceAll(
  'onTap: () => _openDetails(context, f),',
  'onTap: () { HapticFeedback.selectionClick(); _openDetails(context, f); },'
);
console.log('✓ Food haptics added');

// Hotel row open
code = code.replace(
  'onTap: onOpen,\n        child: Padding(\n          padding: const EdgeInsets.all(14),',
  'onTap: () { HapticFeedback.selectionClick(); onOpen(); },\n        child: Padding(\n          padding: const EdgeInsets.all(14),'
);
console.log('✓ Hotel haptics added');

fs.writeFileSync('lib/screens/park_detail_screen.dart', code, 'utf8');
console.log('\n✅ Done');