const fs=require('fs');
let c=fs.readFileSync('lib/main.dart','utf8');

// Add scaffoldBackgroundColor white to ThemeData
c=c.replace(
  `          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF72C8FF),
            ),`,
  `          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.white,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF72C8FF),
              surface: Colors.white,
              background: Colors.white,
            ),`
);

fs.writeFileSync('lib/main.dart',c,'utf8');
console.log('Fixed theme scaffold background');
console.log('Has scaffoldBackgroundColor:',c.includes('scaffoldBackgroundColor: Colors.white'));