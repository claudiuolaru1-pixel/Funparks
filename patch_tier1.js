// patch_tier1.js — run from project root: node patch_tier1.js
const fs = require('fs');

// ═══════════════════════════════════════════════════════
// 1.  home_map_screen.dart
// ═══════════════════════════════════════════════════════
let home = fs.readFileSync('lib/screens/home_map_screen.dart', 'utf8');
home = home.replace(/\r\n/g, '\n');

// ── Add new imports ──────────────────────────────────────────────────────
const animImport = "import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';";
if (!home.includes("premium_park_card.dart")) {
  home = home.replace(
    animImport,
    animImport +
      "\nimport '../widgets/premium_park_card.dart';" +
      "\nimport '../widgets/featured_parks_banner.dart';"
  );
  console.log('✓ Imports added');
} else {
  console.log('ℹ imports already present');
}

// ── Replace AnimationLimiter+ListView section with PremiumParkCard ───────
// Use regex to find the entire block from AnimationLimiter( to closing //
const listRegex = /child: AnimationLimiter\(\s*child: ListView\.\w+\([\s\S]*?\/\/ AnimationLimiter \+ ListView/;
const match = home.match(listRegex);

if (match) {
  const newList = `child: AnimationLimiter(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: _hasActiveFilters
                      ? _filtered.length
                      : _filtered.length + 1,
                  itemBuilder: (_, i) {
                    // Header: featured banner (only when no filters)
                    if (!_hasActiveFilters && i == 0) {
                      return FeaturedParksBanner(
                        parks: _allParks.take(8).toList(),
                        onTap: _openPark,
                      );
                    }
                    final idx = _hasActiveFilters ? i : i - 1;
                    final p = _filtered[idx];
                    return AnimationConfiguration.staggeredList(
                      position: idx,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 28.0,
                        child: FadeInAnimation(
                          child: PremiumParkCard(
                            park: p,
                            onTap: () {
                              _controller?.animateCamera(
                                  CameraUpdate.newLatLngZoom(
                                      LatLng(p.lat, p.lng), 12));
                              _openPark(p);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),  // ListView
              ),  // AnimationLimiter`;
  home = home.replace(match[0], newList);
  console.log('✓ List replaced with PremiumParkCard + FeaturedBanner');
} else {
  // Fallback: try matching just the ListView.separated part
  console.warn('⚠ Regex miss — trying fallback');

  const fbOld = `child: AnimationLimiter(\n                child: ListView.builder(`;
  if (home.includes('ListView.builder')) {
    console.log('ℹ ListView.builder already present — skipping list replacement');
  } else {
    console.warn('⚠ Could not patch list section — check manually');
  }
}

fs.writeFileSync('lib/screens/home_map_screen.dart', home, 'utf8');
console.log('✓ home_map_screen.dart written');

// ═══════════════════════════════════════════════════════
// 2.  park_detail_screen.dart — cinematic header
// ═══════════════════════════════════════════════════════
let detail = fs.readFileSync('lib/screens/park_detail_screen.dart', 'utf8');
detail = detail.replace(/\r\n/g, '\n');

// Increase header height to 220px for more cinematic feel
const old190 = "ParkHeroImage(imagePath: thumb, height: 190, heroTag: 'park_hero_\${park.id}'),";
const new220 = "ParkHeroImage(imagePath: thumb, height: 220, heroTag: 'park_hero_\${park.id}'),";

if (detail.includes(old190)) {
  detail = detail.replace(old190, new220);
  console.log('✓ Park header height increased to 220px');
} else if (detail.includes('height: 220')) {
  console.log('ℹ Header already 220px');
} else {
  console.warn('⚠ Header height anchor not found');
}

// Enhance ParkHeroImage class — add subtle shimmer/loading state
// and round the bottom corners more
const oldBorderRadius = 'const BorderRadius.vertical(bottom: Radius.circular(16)),';
const newBorderRadius = 'const BorderRadius.vertical(bottom: Radius.circular(22)),';
if (detail.includes(oldBorderRadius)) {
  detail = detail.replace(oldBorderRadius, newBorderRadius);
  console.log('✓ Header border radius increased to 22px');
}

fs.writeFileSync('lib/screens/park_detail_screen.dart', detail, 'utf8');
console.log('✓ park_detail_screen.dart written');

console.log('\n✅ Tier 1 patch complete');
