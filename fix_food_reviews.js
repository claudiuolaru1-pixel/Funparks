const fs=require('fs');
let c=fs.readFileSync('lib/screens/park_detail_screen.dart','utf8');
c=c.replace(
  "Text('Reviews coming soon', style: TextStyle(color: Colors.grey.shade600)),",
  `Consumer<AppState>(
                  builder: (_, app, __) {
                    if (app.isLoggedIn) {
                      return OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.rate_review_outlined),
                        label: const Text('Write a review'),
                      );
                    }
                    return OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pushNamed('/signin', arguments: 'register'),
                      icon: const Icon(Icons.rate_review_outlined),
                      label: const Text('Log in or Register to write a review'),
                    );
                  },
                ),`
);
fs.writeFileSync('lib/screens/park_detail_screen.dart',c,'utf8');
console.log('Food reviews fixed:', c.includes('Log in or Register') ? 'YES' : 'NO');