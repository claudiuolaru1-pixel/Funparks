const fs=require('fs');
let c=fs.readFileSync('lib/screens/home_map_screen.dart','utf8');
c=c.replace(
  'return const BlogCard();',
  'return BlogCard(postIndex: blogInserts - 1);'
);
fs.writeFileSync('lib/screens/home_map_screen.dart',c,'utf8');
console.log('Fixed blog card rotation');