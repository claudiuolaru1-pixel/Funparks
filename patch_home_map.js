// patch_home_map.js  — run from project root: node patch_home_map.js
const fs = require('fs');
const path = 'lib/screens/home_map_screen.dart';
let code = fs.readFileSync(path, 'utf8');

// ── 1. Add new imports after existing ones ────────────────────────────────
const oldImport = "import '../models/park_summary.dart';";
const newImport = `import '../models/park_summary.dart';
import '../widgets/park_image.dart';
import '../widgets/shimmer_park_list.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';`;
if (code.includes(oldImport)) {
  code = code.replace(oldImport, newImport);
  console.log('✓ Imports added');
} else {
  console.warn('⚠ Import anchor not found — check manually');
}

// ── 2. Replace CircleAvatar leading with Hero + thumbnail image ───────────
const oldLeading = `                    leading: CircleAvatar(
                      backgroundColor:
                          cs.primaryContainer,
                      child: Text(
                        p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                        style: TextStyle(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.w900),
                      ),
                    ),`;
const newLeading = `                    leading: Hero(
                      tag: 'park_hero_\${p.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: (p.thumbnail ?? '').isNotEmpty
                            ? ParkImage(
                                image: p.thumbnail!,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 56,
                                height: 56,
                                color: cs.primaryContainer,
                                child: Center(
                                  child: Text(
                                    p.name.isNotEmpty
                                        ? p.name[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                        color: cs.onPrimaryContainer,
                                        fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ),
                      ),
                    ),`;
if (code.includes(oldLeading)) {
  code = code.replace(oldLeading, newLeading);
  console.log('✓ Hero leading added');
} else {
  console.warn('⚠ Leading anchor not found — check manually');
}

// ── 3. Add haptic feedback to list item tap ───────────────────────────────
const oldOnTap = `                    onTap: () {
                      // Fly to marker on map
                      _controller?.animateCamera(
                          CameraUpdate.newLatLngZoom(
                              LatLng(p.lat, p.lng), 12));
                      _openPark(p);
                    },`;
const newOnTap = `                    onTap: () {
                      HapticFeedback.lightImpact();
                      _controller?.animateCamera(
                          CameraUpdate.newLatLngZoom(
                              LatLng(p.lat, p.lng), 12));
                      _openPark(p);
                    },`;
if (code.includes(oldOnTap)) {
  code = code.replace(oldOnTap, newOnTap);
  console.log('✓ Haptic feedback added to list tap');
} else {
  console.warn('⚠ onTap anchor not found — check manually');
}

// ── 4. Add shimmer before park list + wrap list with staggered animation ──
// Replace the two "if (!_loading" blocks together
const oldListSection = `          if (!_loading && _filtered.isNotEmpty)
            Expanded(
              flex: 2,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (_, i) {
                  final p = _filtered[i];
                  return ListTile(`;
const newListSection = `          if (_loading)
            Expanded(
              flex: 2,
              child: const ShimmerParkList(),
            ),
          if (!_loading && _filtered.isNotEmpty)
            Expanded(
              flex: 2,
              child: AnimationLimiter(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (_, i) {
                    final p = _filtered[i];
                    return AnimationConfiguration.staggeredList(
                      position: i,
                      duration: const Duration(milliseconds: 380),
                      child: SlideAnimation(
                        verticalOffset: 28.0,
                        child: FadeInAnimation(
                          child: ListTile(`;
if (code.includes(oldListSection)) {
  code = code.replace(oldListSection, newListSection);
  console.log('✓ Shimmer + staggered animation added');
} else {
  console.warn('⚠ List section anchor not found — check manually');
}

// ── 5. Close the extra wrappers after ListTile closing brace ─────────────
// The ListTile ends with its closing ), then ListView.separated closes
// We need to add 3 closing brackets for FadeInAnimation, SlideAnimation,
// AnimationConfiguration — and 1 more for AnimationLimiter

// Find the onTap close that ends the ListTile block
const oldListTileClose = `                  ),
                },
              ),
            ),
          if (!_loading && _filtered.isEmpty && _hasActiveFilters)`;
const newListTileClose = `                        ),  // ListTile
                        ),  // FadeInAnimation
                      ),  // SlideAnimation
                    );  // AnimationConfiguration
                  },
                ),  // ListView
              ),  // AnimationLimiter
            ),
          if (!_loading && _filtered.isEmpty && _hasActiveFilters)`;
if (code.includes(oldListTileClose)) {
  code = code.replace(oldListTileClose, newListTileClose);
  console.log('✓ Staggered closing brackets added');
} else {
  console.warn('⚠ ListTile close anchor not found — will attempt fallback');
  // Fallback: try a simpler search
  const alt = `                },\n              ),\n            ),\n          if (!_loading && _filtered.isEmpty && _hasActiveFilters)`;
  if (code.includes(alt)) {
    code = code.replace(alt, `                        ),  // ListTile
                        ),  // FadeInAnimation
                      ),  // SlideAnimation
                    );  // AnimationConfiguration
                  },\n                ),  // ListView\n              ),  // AnimationLimiter\n            ),\n          if (!_loading && _filtered.isEmpty && _hasActiveFilters)`);
    console.log('✓ Staggered closing brackets added (fallback)');
  }
}

fs.writeFileSync(path, code, 'utf8');
console.log('\n✅ home_map_screen.dart patched successfully');
