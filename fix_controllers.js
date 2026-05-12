const fs=require('fs');

// Fix home_map_screen.dart
let c=fs.readFileSync('lib/screens/home_map_screen.dart','utf8');
c=c.replace('  final _searchCtrl = TextEditingController();', '  TextEditingController? _searchCtrl;');
// Find initState and add controller init
c=c.replace(/super\.initState\(\);(\s*)/,'super.initState();\n    try { _searchCtrl = TextEditingController(); } catch (_) {}\n');
// Fix usages
c=c.replace(/_searchCtrl\.text/g,"_searchCtrl?.text??''");
c=c.replace(/_searchCtrl\.clear\(\)/g,'_searchCtrl?.clear()');
c=c.replace(/_searchCtrl\.dispose\(\)/g,'_searchCtrl?.dispose()');
c=c.replace(/controller: _searchCtrl([^?])/g,'controller: _searchCtrl$1');
fs.writeFileSync('lib/screens/home_map_screen.dart',c,'utf8');
console.log('home_map_screen fixed');

// Fix park_detail_screen.dart - food detail screen controller
let p=fs.readFileSync('lib/screens/park_detail_screen.dart','utf8');
p=p.replace('  final _commentCtrl = TextEditingController();', '  TextEditingController? _commentCtrl;');
p=p.replace(/super\.initState\(\);(\s*)([\s\S]*?)addPostFrameCallback/,
  (m,sp,mid) => `super.initState();\n    try { _commentCtrl = TextEditingController(); } catch (_) {}\n${sp}${mid}addPostFrameCallback`);
p=p.replace(/_commentCtrl\.text/g,"_commentCtrl?.text??''");
p=p.replace(/_commentCtrl\.dispose\(\)/g,'_commentCtrl?.dispose()');
p=p.replace(/controller: _commentCtrl([^?])/g,'controller: _commentCtrl$1');
fs.writeFileSync('lib/screens/park_detail_screen.dart',p,'utf8');
console.log('park_detail_screen fixed');