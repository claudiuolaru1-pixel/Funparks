const fs=require('fs');
let c=fs.readFileSync('lib/screens/park_detail_screen.dart','utf8');

// Fix 1: bullet - replace any corrupted sequence between $a and Child
c=c.replace(/return 'Adult \$a [^C]+Child \$c \${park\.currency}';/,
  "return 'Adult \$a \u2022 Child \$c \${park.currency}';");
console.log('Bullet fixed:', c.includes('\u2022') ? 'YES' : 'NO');

// Fix 2: Reviews coming soon in food detail (double quotes)
c=c.replace(
  'Text("Reviews coming soon", style: TextStyle(color: Colors.grey)),',
  `Consumer<AppState>(
                  builder: (_, app, __) => app.isLoggedIn
                    ? OutlinedButton.icon(
                        onPressed: () => _showReviewDialog(context),
                        icon: const Icon(Icons.rate_review_outlined),
                        label: const Text('Write a review'),
                      )
                    : OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pushNamed('/signin', arguments: 'register'),
                        icon: const Icon(Icons.rate_review_outlined),
                        label: const Text('Log in or Register to write a review'),
                      ),
                ),`
);
console.log('Food reviews fixed:', c.includes('_showReviewDialog') ? 'YES' : 'NO');

// Fix 3: Write a review button - implement _showReviewDialog
// Replace empty onPressed in attraction detail
c=c.replace(
  `                    ? OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.rate_review_outlined),
                        label: const Text('Write a review'),
                      )`,
  `                    ? OutlinedButton.icon(
                        onPressed: () => _showReviewDialog(context),
                        icon: const Icon(Icons.rate_review_outlined),
                        label: const Text('Write a review'),
                      )`
);

// Add _showReviewDialog function before FOOD TAB comment
const reviewDialog = `
void _showReviewDialog(BuildContext context) {
  final textCtrl = TextEditingController();
  double rating = 4.5;
  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => AlertDialog(
        title: const Text('Write a Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => IconButton(
                icon: Icon(i < rating.round() ? Icons.star : Icons.star_border, color: Colors.amber),
                onPressed: () => setS(() => rating = (i+1).toDouble()),
              )),
            ),
            TextField(
              controller: textCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Share your experience...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Review submitted! Thank you.')));
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    ),
  );
}

`;

c=c.replace(
  '// ===============================================================\n// FOOD TAB',
  reviewDialog + '// ===============================================================\n// FOOD TAB'
);

fs.writeFileSync('lib/screens/park_detail_screen.dart',c,'utf8');
console.log('Review dialog added:', c.includes('showDialog') ? 'YES' : 'NO');