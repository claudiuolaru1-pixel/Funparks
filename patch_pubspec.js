// patch_pubspec.js  — run from project root: node patch_pubspec.js
const fs = require('fs');
const path = 'pubspec.yaml';
let code = fs.readFileSync(path, 'utf8');

// ── 1. Add new packages after share_plus ─────────────────────────────────
const oldDep = `  share_plus: ^10.0.2`;
const newDep = `  share_plus: ^10.0.2
  audioplayers: ^6.1.0
  shimmer: ^3.0.0
  flutter_staggered_animations: ^1.1.1`;

if (code.includes(oldDep) && !code.includes('audioplayers')) {
  code = code.replace(oldDep, newDep);
  console.log('✓ Packages added to pubspec.yaml');
} else if (code.includes('audioplayers')) {
  console.log('ℹ Packages already present — skipping');
} else {
  console.warn('⚠ share_plus anchor not found — add packages manually');
}

// ── 2. Add assets/sounds/ entry ───────────────────────────────────────────
const oldAsset = `    - assets/splash/`;
const newAsset = `    - assets/sounds/
    - assets/splash/`;

if (code.includes(oldAsset) && !code.includes('assets/sounds/')) {
  code = code.replace(oldAsset, newAsset);
  console.log('✓ assets/sounds/ added to pubspec.yaml');
} else if (code.includes('assets/sounds/')) {
  console.log('ℹ assets/sounds/ already present — skipping');
} else {
  console.warn('⚠ assets/splash/ anchor not found — add assets/sounds/ manually');
}

fs.writeFileSync(path, code, 'utf8');
console.log('\n✅ pubspec.yaml patched successfully');
