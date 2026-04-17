const fs = require('fs');

// Fix 1: start_screen.dart — login _PressBtn missing decoration
let s = fs.readFileSync('lib/screens/start_screen.dart', 'utf8');
const oldLogin = `                      _PressBtn(
                        onTap: () async {
                          await _tap();
                          if (!mounted) return;
                          Navigator.pushNamed(context, '/signin');
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Text(
                            loc.login,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 15),
                          ),
                        ),
                      ),`;
const newLogin = `                      _PressBtn(
                        onTap: () async {
                          await _tap();
                          if (!mounted) return;
                          Navigator.pushNamed(context, '/signin');
                        },
                        decoration: const BoxDecoration(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Text(
                            loc.login,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 15),
                          ),
                        ),
                      ),`;
if (s.includes(oldLogin)) { s = s.replace(oldLogin, newLogin); console.log('✓ login _PressBtn fixed'); }
else { console.warn('⚠ login anchor not found'); }
fs.writeFileSync('lib/screens/start_screen.dart', s, 'utf8');

// Fix 2: park_detail_screen.dart — ParkHeroImage heroTag using regex
let p = fs.readFileSync('lib/screens/park_detail_screen.dart', 'utf8');
// Add heroTag field and update constructor
p = p.replace(
  /class ParkHeroImage extends StatelessWidget \{(\s*)final String imagePath;(\s*)final double height;(\s*)const ParkHeroImage\(\s*\{super\.key,\s*required this\.imagePath,\s*this\.height = 180\}\);/,
  `class ParkHeroImage extends StatelessWidget {$1final String imagePath;$2final double height;$2final String? heroTag;$3const ParkHeroImage({super.key, required this.imagePath, this.height = 180, this.heroTag});`
);
// Update build method
p = p.replace(
  /return SizedBox\(\s*height: height,\s*width: double\.infinity,\s*child: ClipRRect\(\s*borderRadius:\s*const BorderRadius\.vertical\(bottom: Radius\.circular\(16\)\),\s*child: ParkImage\(image: imagePath, fit: BoxFit\.cover\),\s*\),\s*\);\s*\}\s*\}\s*class ParkTranslateButton/,
  `final inner = ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      child: ParkImage(image: imagePath, fit: BoxFit.cover),
    );
    return SizedBox(
      height: height,
      width: double.infinity,
      child: heroTag != null ? Hero(tag: heroTag!, child: inner) : inner,
    );
  }
}
class ParkTranslateButton`
);
// Fix call site
p = p.replace(
  'ParkHeroImage(imagePath: thumb, height: 190),',
  "ParkHeroImage(imagePath: thumb, height: 190, heroTag: 'park_hero_\${park.id}'),"
);
fs.writeFileSync('lib/screens/park_detail_screen.dart', p, 'utf8');
console.log('✓ ParkHeroImage patched');