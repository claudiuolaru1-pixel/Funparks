const fs = require('fs');

// Fix start_screen.dart
let ss = fs.readFileSync('lib/screens/start_screen.dart', 'utf8');
ss = ss.replace(/\r\n/g, '\n');
ss = ss.replace("sounds/tap_splash.wav", "sounds/water_plop.wav");
fs.writeFileSync('lib/screens/start_screen.dart', ss, 'utf8');
console.log('✓ start_screen sound fixed');

// Fix home_map_screen.dart — check what sound is used
let home = fs.readFileSync('lib/screens/home_map_screen.dart', 'utf8');
home = home.replace(/\r\n/g, '\n');
if (home.includes('tap_splash')) {
  home = home.replace(/tap_splash\.wav/g, 'water_plop.wav');
  console.log('✓ home_map tap_splash replaced');
} else if (home.includes('water_plop')) {
  console.log('ℹ home_map already uses water_plop');
} else {
  console.log('ℹ home_map has no sound reference yet — checking _playPlop');
  const idx = home.indexOf('_playPlop');
  if (idx !== -1) console.log(JSON.stringify(home.substring(idx, idx+150)));
}
fs.writeFileSync('lib/screens/home_map_screen.dart', home, 'utf8');