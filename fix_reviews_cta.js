const fs=require('fs');
let c=fs.readFileSync('lib/screens/park_detail_screen.dart','utf8');

// Replace "Reviews coming soon" with login CTA
c=c.replace(
  "Text('Reviews coming soon', style: TextStyle(color: Colors.grey.shade600)),",
  `OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed('/sign_in'),
                  icon: const Icon(Icons.rate_review_outlined),
                  label: const Text('Log in or Register to write a review'),
                ),`
);

fs.writeFileSync('lib/screens/park_detail_screen.dart',c,'utf8');
console.log('Fixed:', c.includes('Log in or Register') ? 'YES' : 'NO');