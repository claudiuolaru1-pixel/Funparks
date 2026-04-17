const fs = require('fs');
let code = fs.readFileSync('lib/screens/home_map_screen.dart', 'utf8');

// Normalize CRLF to LF so all replacements work
code = code.replace(/\r\n/g, '\n');

// Remove duplicate imports
code = code.replace(
`import '../widgets/park_image.dart';\nimport '../widgets/shimmer_park_list.dart';\nimport 'package:flutter/services.dart';\nimport 'package:flutter_staggered_animations/flutter_staggered_animations.dart';\nimport '../widgets/park_image.dart';\nimport '../widgets/shimmer_park_list.dart';\nimport 'package:flutter/services.dart';\nimport 'package:flutter_staggered_animations/flutter_staggered_animations.dart';`,
`import '../widgets/park_image.dart';\nimport '../widgets/shimmer_park_list.dart';\nimport 'package:flutter/services.dart';\nimport 'package:flutter_staggered_animations/flutter_staggered_animations.dart';`
);
console.log('✓ CRLF normalized, duplicates removed');

// Replace CircleAvatar with Hero thumbnail
code = code.replace(
`                    leading: CircleAvatar(\n                      backgroundColor:\n                          cs.primaryContainer,\n                      child: Text(\n                        p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',\n                        style: TextStyle(\n                            color: cs.onPrimaryContainer,\n                            fontWeight: FontWeight.w900),\n                      ),\n                    ),`,
`                    leading: Hero(\n                      tag: 'park_hero_\${p.id}',\n                      child: ClipRRect(\n                        borderRadius: BorderRadius.circular(8),\n                        child: (p.thumbnail ?? '').isNotEmpty\n                            ? ParkImage(image: p.thumbnail!, width: 56, height: 56, fit: BoxFit.cover)\n                            : Container(\n                                width: 56, height: 56,\n                                color: cs.primaryContainer,\n                                child: Center(child: Text(\n                                  p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',\n                                  style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.w900),\n                                )),\n                              ),\n                      ),\n                    ),`
);
console.log('✓ Hero leading added');

// Add haptic to onTap
code = code.replace(
`                    onTap: () {\n                      // Fly to marker on map\n                      _controller?.animateCamera(\n                          CameraUpdate.newLatLngZoom(\n                              LatLng(p.lat, p.lng), 12));\n                      _openPark(p);\n                    },`,
`                    onTap: () {\n                      HapticFeedback.lightImpact();\n                      _controller?.animateCamera(\n                          CameraUpdate.newLatLngZoom(\n                              LatLng(p.lat, p.lng), 12));\n                      _openPark(p);\n                    },`
);
console.log('✓ Haptic added');

// Wrap list item with staggered animation
code = code.replace(
`                  final p = _filtered[i];\n                  return ListTile(`,
`                  final p = _filtered[i];\n                  return AnimationConfiguration.staggeredList(\n                    position: i,\n                    duration: const Duration(milliseconds: 375),\n                    child: SlideAnimation(\n                      verticalOffset: 28.0,\n                      child: FadeInAnimation(\n                        child: ListTile(`
);
console.log('✓ Staggered wrapper added');

// Close staggered wrappers
code = code.replace(
`                  );\n                },\n              ),\n            ),\n          if (!_loading && _filtered.isEmpty && _hasActiveFilters)`,
`                        ),\n                        ),\n                      ),\n                    );\n                },\n              ),\n            ),\n          if (!_loading && _filtered.isEmpty && _hasActiveFilters)`
);
console.log('✓ Closing brackets added');

// Add shimmer + AnimationLimiter
code = code.replace(
`          if (!_loading && _filtered.isNotEmpty)\n            Expanded(\n              flex: 2,\n              child: ListView.separated(`,
`          if (_loading)\n            Expanded(flex: 2, child: const ShimmerParkList()),\n          if (!_loading && _filtered.isNotEmpty)\n            Expanded(\n              flex: 2,\n              child: AnimationLimiter(\n                child: ListView.separated(`
);
console.log('✓ Shimmer + AnimationLimiter added');

// Close AnimationLimiter
code = code.replace(
`              ),\n            ),\n          if (!_loading && _filtered.isEmpty && _hasActiveFilters)`,
`                ),\n              ),\n            ),\n          if (!_loading && _filtered.isEmpty && _hasActiveFilters)`
);
console.log('✓ AnimationLimiter closed');

fs.writeFileSync('lib/screens/home_map_screen.dart', code, 'utf8');
console.log('\n✅ Done');