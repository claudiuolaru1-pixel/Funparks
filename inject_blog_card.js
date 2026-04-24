const fs=require('fs');
const path='lib/screens/home_map_screen.dart';
let c=fs.readFileSync(path,'utf8');

// Add import for blog_card
if(!c.includes('blog_card')){
  c=c.replace(
    "import '../widgets/shimmer_park_list.dart';",
    "import '../widgets/shimmer_park_list.dart';\nimport '../widgets/blog_card.dart';"
  );
  console.log('Added blog_card import');
}

// Replace the ListView.separated to inject blog card every 6 parks
const oldList=`              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (_, i) {
                  final p = _filtered[i];`;

const newList=`              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: _filtered.length + (_filtered.length ~/ 6),
                itemBuilder: (_, i) {
                  // Insert blog card every 6 parks
                  final blogInserts = i ~/ 7;
                  final parkIndex = i - blogInserts;
                  if (i > 0 && i % 7 == 0 && blogInserts <= _filtered.length ~/ 6) {
                    return const BlogCard();
                  }
                  if (parkIndex >= _filtered.length) return const SizedBox.shrink();
                  final p = _filtered[parkIndex];`;

if(c.includes(oldList)){
  // Also need to fix the closing of the old listview - remove the separatorBuilder closing
  const oldClose=`                  return ListTile(`;
  const newStart=`                  return Column(children:[
                    if (parkIndex > 0) const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(`;

  c=c.replace(oldList,newList);
  console.log('Replaced ListView');

  // Find and fix the ListTile closing - it needs to be wrapped
  // Actually simpler - just add divider inside itemBuilder
  // The old approach had separatorBuilder, now we inline it
  // Find "return ListTile(" and wrap it
  c=c.replace(
    `                  return ListTile(`,
    `                  return Column(children:[if(parkIndex>0)const Divider(height:1,indent:16,endIndent:16),ListTile(`
  );
  // Find the closing of ListTile onTap and add column close
  c=c.replace(
    `                        },
                      );
                    },
                  ),`,
    `                        },
                      ),]);
                    },
                  ),`
  );
  console.log('Fixed ListTile wrapping');
} else {
  console.log('Pattern not found - checking...');
  const idx=c.indexOf('ListView.separated');
  console.log('ListView.separated at:',idx);
}

fs.writeFileSync(path,c,'utf8');
console.log('Done');