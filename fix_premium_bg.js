const fs=require('fs');
let c=fs.readFileSync('lib/screens/park_detail_screen.dart','utf8');

c=c.replace(
  `    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF72C8FF).withOpacity(0.14),
            Colors.white,
          ],
        ),
      ),
      child: child,
    );`,
  `    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF72C8FF).withOpacity(0.14),
            Colors.white,
          ],
        ),
      ),
      child: child,
    );`
);

fs.writeFileSync('lib/screens/park_detail_screen.dart',c,'utf8');
console.log('Fixed PremiumBackground');
console.log('Has Container:',c.includes('width: double.infinity'));