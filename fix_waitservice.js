const fs=require('fs');
let c=fs.readFileSync('lib/screens/park_detail_screen.dart','utf8');

// Remove WaitTimeService from detail screen build method
c=c.replace(
  `    final cat = widget.categoryLabel(a.category);
    final service = WaitTimeService();

    final factLines`,
  `    final cat = widget.categoryLabel(a.category);

    final factLines`
);

// Remove WaitTimeService from AttractionRow build method  
c=c.replace(
  `    final service = WaitTimeService();
    final lookup = _I18nLookup(i18n);`,
  `    final lookup = _I18nLookup(i18n);`
);

fs.writeFileSync('lib/screens/park_detail_screen.dart',c,'utf8');
const remaining=(c.match(/WaitTimeService/g)||[]).length;
console.log('WaitTimeService remaining:',remaining);