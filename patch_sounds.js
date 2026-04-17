// patch_sounds.js — run from project root: node patch_sounds.js
const fs = require('fs');

// ═══════════════════════════════════════════════════════
// 1. start_screen.dart — replace tap_splash with water_plop
// ═══════════════════════════════════════════════════════
let ss = fs.readFileSync('lib/screens/start_screen.dart', 'utf8');
ss = ss.replace(/\r\n/g, '\n');

ss = ss.replace("'assets/sounds/tap_splash.wav'", "'assets/sounds/water_plop.wav'");
fs.writeFileSync('lib/screens/start_screen.dart', ss, 'utf8');
console.log('✓ start_screen: sound updated to water_plop.wav');

// ═══════════════════════════════════════════════════════
// 2. home_map_screen.dart — plop sound when opening a park
// ═══════════════════════════════════════════════════════
let home = fs.readFileSync('lib/screens/home_map_screen.dart', 'utf8');
home = home.replace(/\r\n/g, '\n');

// Add audioplayers import if not present
if (!home.includes('audioplayers')) {
  home = home.replace(
    "import 'package:flutter/services.dart';",
    "import 'package:flutter/services.dart';\nimport 'package:audioplayers/audioplayers.dart';"
  );
  console.log('✓ audioplayers import added to home_map_screen');
}

// Add _playPlop helper method before _openPark
if (!home.includes('_playPlop')) {
  home = home.replace(
    'void _openPark(ParkSummary park) {',
    `Future<void> _playPlop() async {
    try {
      final p = AudioPlayer();
      await p.play(AssetSource('sounds/water_plop.wav'));
    } catch (_) {}
  }

  void _openPark(ParkSummary park) {`
  );
  console.log('✓ _playPlop helper added');
}

// Call _playPlop in onTap of list item (already has HapticFeedback)
home = home.replace(
  `                    onTap: () {\n                      HapticFeedback.lightImpact();\n                      _controller?.animateCamera(`,
  `                    onTap: () {\n                      HapticFeedback.lightImpact();\n                      _playPlop();\n                      _controller?.animateCamera(`
);
console.log('✓ _playPlop called on list item tap');

// Call _playPlop in marker onTap
home = home.replace(
  `            onTap: () {\n              if (!mounted) return;\n              _openPark(park);`,
  `            onTap: () {\n              if (!mounted) return;\n              _playPlop();\n              _openPark(park);`
);
console.log('✓ _playPlop called on map marker tap');

fs.writeFileSync('lib/screens/home_map_screen.dart', home, 'utf8');
console.log('✓ home_map_screen.dart written');

// ═══════════════════════════════════════════════════════
// 3. park_detail_screen.dart — haptic on attraction/food/hotel tap
// ═══════════════════════════════════════════════════════
let detail = fs.readFileSync('lib/screens/park_detail_screen.dart', 'utf8');
detail = detail.replace(/\r\n/g, '\n');

// Ensure HapticFeedback import
if (!detail.includes("'package:flutter/services.dart'")) {
  detail = detail.replace(
    "import 'package:flutter/material.dart';",
    "import 'package:flutter/material.dart';\nimport 'package:flutter/services.dart';"
  );
  console.log('✓ services import added to park_detail_screen');
}

// Find attraction card onTap — look for Navigator.push to attraction detail
// Add haptic before every GestureDetector onTap that navigates to detail screens
// Strategy: wrap existing onTap calls in attraction/food/hotel list items

// Attraction list item tap
const oldAttrTap = `onTap: () {\n                Navigator.push(\n                  context,\n                  MaterialPageRoute(\n                    builder: (_) => AttractionDetailScreen(`;
const newAttrTap = `onTap: () {\n                HapticFeedback.selectionClick();\n                Navigator.push(\n                  context,\n                  MaterialPageRoute(\n                    builder: (_) => AttractionDetailScreen(`;
if (detail.includes(oldAttrTap)) {
  detail = detail.replaceAll(oldAttrTap, newAttrTap);
  console.log('✓ Haptic added to attraction taps');
} else {
  console.warn('⚠ Attraction tap anchor not found — skipping');
}

// Food list item tap
const oldFoodTap = `onTap: () {\n                Navigator.push(\n                  context,\n                  MaterialPageRoute(\n                    builder: (_) => FoodDetailScreen(`;
const newFoodTap = `onTap: () {\n                HapticFeedback.selectionClick();\n                Navigator.push(\n                  context,\n                  MaterialPageRoute(\n                    builder: (_) => FoodDetailScreen(`;
if (detail.includes(oldFoodTap)) {
  detail = detail.replaceAll(oldFoodTap, newFoodTap);
  console.log('✓ Haptic added to food taps');
} else {
  console.warn('⚠ Food tap anchor not found — skipping');
}

// Hotel list item tap
const oldHotelTap = `onTap: () {\n                Navigator.push(\n                  context,\n                  MaterialPageRoute(\n                    builder: (_) => HotelDetailScreen(`;
const newHotelTap = `onTap: () {\n                HapticFeedback.selectionClick();\n                Navigator.push(\n                  context,\n                  MaterialPageRoute(\n                    builder: (_) => HotelDetailScreen(`;
if (detail.includes(oldHotelTap)) {
  detail = detail.replaceAll(oldHotelTap, newHotelTap);
  console.log('✓ Haptic added to hotel taps');
} else {
  console.warn('⚠ Hotel tap anchor not found — skipping');
}

fs.writeFileSync('lib/screens/park_detail_screen.dart', detail, 'utf8');
console.log('✓ park_detail_screen.dart written');

console.log('\n✅ patch_sounds.js complete');
