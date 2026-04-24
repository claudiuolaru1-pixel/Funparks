const fs=require('fs');
let c=fs.readFileSync('lib/widgets/blog_card.dart','utf8');

// Load all posts and show different one based on position
// Add a postIndex parameter
c=c.replace(
  'class BlogCard extends StatefulWidget {\n  const BlogCard({super.key});',
  'class BlogCard extends StatefulWidget {\n  final int postIndex;\n  const BlogCard({super.key, this.postIndex = 0});'
);
c=c.replace(
  "Uri.parse('https://funparks.app/blog-posts.json'),",
  "Uri.parse('https://funparks.app/blog-posts.json'),"
);
c=c.replace(
  'if (list.isNotEmpty && mounted) {\n          setState(() { _post = list[0] as Map<String, dynamic>; _loading = false; });',
  'if (list.isNotEmpty && mounted) {\n          final idx = widget.postIndex % list.length;\n          setState(() { _post = list[idx] as Map<String, dynamic>; _loading = false; });'
);

fs.writeFileSync('lib/widgets/blog_card.dart',c,'utf8');
console.log('BlogCard now rotates posts by index');