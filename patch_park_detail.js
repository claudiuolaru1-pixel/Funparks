// patch_park_detail.js  — run from project root: node patch_park_detail.js
const fs = require('fs');
const path = 'lib/screens/park_detail_screen.dart';
let code = fs.readFileSync(path, 'utf8');

// ── 1. Modify ParkHeroImage class to accept optional heroTag ─────────────
const oldClass = `class ParkHeroImage extends StatelessWidget {
  final String imagePath;
  final double height;
  const ParkHeroImage(
      {super.key, required this.imagePath, this.height = 180});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(16)),
        child: ParkImage(image: imagePath, fit: BoxFit.cover),
      ),
    );
  }
}`;
const newClass = `class ParkHeroImage extends StatelessWidget {
  final String imagePath;
  final double height;
  final String? heroTag;
  const ParkHeroImage(
      {super.key, required this.imagePath, this.height = 180, this.heroTag});
  @override
  Widget build(BuildContext context) {
    final inner = ClipRRect(
      borderRadius:
          const BorderRadius.vertical(bottom: Radius.circular(16)),
      child: ParkImage(image: imagePath, fit: BoxFit.cover),
    );
    return SizedBox(
      height: height,
      width: double.infinity,
      child: heroTag != null ? Hero(tag: heroTag!, child: inner) : inner,
    );
  }
}`;

if (code.includes(oldClass)) {
  code = code.replace(oldClass, newClass);
  console.log('✓ ParkHeroImage updated with heroTag support');
} else {
  console.warn('⚠ ParkHeroImage class not found — check manually');
}

// ── 2. Update call site to pass heroTag ──────────────────────────────────
// The call is:  ParkHeroImage(imagePath: thumb, height: 190),
// We need park.id — it's in scope as `park` in the build method
const oldCall = `          ParkHeroImage(imagePath: thumb, height: 190),`;
const newCall = `          ParkHeroImage(imagePath: thumb, height: 190, heroTag: 'park_hero_\${park.id}'),`;

if (code.includes(oldCall)) {
  code = code.replace(oldCall, newCall);
  console.log('✓ ParkHeroImage call updated with heroTag');
} else {
  console.warn('⚠ ParkHeroImage call site not found — check manually');
}

fs.writeFileSync(path, code, 'utf8');
console.log('\n✅ park_detail_screen.dart patched successfully');
