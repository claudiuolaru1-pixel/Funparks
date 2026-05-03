const fs=require('fs');
let c=fs.readFileSync('lib/screens/park_detail_screen.dart','utf8');

// Fix 1: Explicit white background on attraction detail scaffold
c=c.replace(
  'backgroundColor: Theme.of(context).scaffoldBackgroundColor,',
  'backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF121212) : Colors.white,'
);

// Fix 2: _AttractionRow - use explicit white instead of cs.surface
c=c.replace(
  /color: cs\.surface,\n          border: Border\.all\(color: cs\.outlineVariant\.withOpacity\(0\.35\)\)/g,
  'color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,\n          border: Border.all(color: Colors.grey.withOpacity(0.2))'
);

fs.writeFileSync('lib/screens/park_detail_screen.dart',c,'utf8');
console.log('Fixed iOS grey screen');
console.log('Has brightness check:',c.includes('Brightness.dark'));