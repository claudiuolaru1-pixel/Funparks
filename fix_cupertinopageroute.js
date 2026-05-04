const fs=require('fs');
let c=fs.readFileSync('lib/screens/park_detail_screen.dart','utf8');

// Replace MaterialPageRoute with CupertinoPageRoute for attraction detail
c=c.replace(
  `  void _openDetails(Attraction a) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _AttractionDetailScreen(`,
  `  void _openDetails(Attraction a) {
    Navigator.of(context).push(CupertinoPageRoute(
      builder: (_) => _AttractionDetailScreen(`
);

fs.writeFileSync('lib/screens/park_detail_screen.dart',c,'utf8');
console.log('Switched to CupertinoPageRoute:', c.includes('CupertinoPageRoute') ? 'YES' : 'NO');