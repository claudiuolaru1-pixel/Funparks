const fs=require('fs');
let c=fs.readFileSync('lib/screens/park_detail_screen.dart','utf8');

// Fix route name and add logged-in check
c=c.replace(
  `OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed('/sign_in'),
                  icon: const Icon(Icons.rate_review_outlined),
                  label: const Text('Log in or Register to write a review'),
                ),`,
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
console.log('Review button fixed:', c.includes("pushNamed('/signin'") ? 'YES' : 'NO');