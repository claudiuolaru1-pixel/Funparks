const fs = require('fs');
let code = fs.readFileSync('lib/screens/home_map_screen.dart', 'utf8');

// Fix leading: replace CircleAvatar with Hero+thumbnail
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
                            ? ParkImage(image: p.thumbnail!, width: 56, height: 56, fit: BoxFit.cover)
                            : Container(
                                width: 56, height: 56,
                                color: cs.primaryContainer,
                                child: Center(child: Text(
                                  p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                                  style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.w900),
                                )),
                              ),
                      ),
                    ),`;
if (code.includes(oldLeading)) { code = code.replace(oldLeading, newLeading); console.log('✓ Hero leading added'); }
else { console.warn('⚠ leading not found'); }

// Fix onTap: add haptic feedback
const oldTap = `                    onTap: () {
                      // Fly to marker on map
                      _controller?.animateCamera(
                          CameraUpdate.newLatLngZoom(
                              LatLng(p.lat, p.lng), 12));
                      _openPark(p);
                    },`;
const newTap = `                    onTap: () {
                      HapticFeedback.lightImpact();
                      _controller?.animateCamera(
                          CameraUpdate.newLatLngZoom(
                              LatLng(p.lat, p.lng), 12));
                      _openPark(p);
                    },`;
if (code.includes(oldTap)) { code = code.replace(oldTap, newTap); console.log('✓ Haptic added'); }
else { console.warn('⚠ onTap not found'); }

// Fix list: wrap with shimmer + staggered animations
const oldList = `                  final p = _filtered[i];
                  return ListTile(`;
const newList = `                  final p = _filtered[i];
                  return AnimationConfiguration.staggeredList(
                    position: i,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 28.0,
                      child: FadeInAnimation(
                        child: ListTile(`;
if (code.includes(oldList)) { code = code.replace(oldList, newList); console.log('✓ Staggered wrapper added'); }
else { console.warn('⚠ list item not found'); }

// Close the extra wrappers after ListTile
const oldClose = `                  );
                },
              ),
            ),
          if (!_loading && _filtered.isEmpty && _hasActiveFilters)`;
const newClose = `                        ),  // ListTile
                        ),  // FadeInAnimation
                      ),  // SlideAnimation
                    );  // AnimationConfiguration
                },
              ),
            ),
          if (!_loading && _filtered.isEmpty && _hasActiveFilters)`;
if (code.includes(oldClose)) { code = code.replace(oldClose, newClose); console.log('✓ Closing brackets added'); }
else { console.warn('⚠ close not found'); }

// Add shimmer when loading (before the park list expanded)
const oldExpanded = `          if (!_loading && _filtered.isNotEmpty)
            Expanded(
              flex: 2,
              child: ListView.separated(`;
const newExpanded = `          if (_loading)
            Expanded(flex: 2, child: const ShimmerParkList()),
          if (!_loading && _filtered.isNotEmpty)
            Expanded(
              flex: 2,
              child: AnimationLimiter(child: ListView.separated(`;
if (code.includes(oldExpanded)) { code = code.replace(oldExpanded, newExpanded); console.log('✓ Shimmer + AnimationLimiter added'); }
else { console.warn('⚠ expanded not found'); }

// Close AnimationLimiter — find ListView close
const oldLVClose = `              ),
            ),
          if (!_loading && _filtered.isEmpty && _hasActiveFilters)`;
const newLVClose = `              )),  // AnimationLimiter + ListView
            ),
          if (!_loading && _filtered.isEmpty && _hasActiveFilters)`;
if (code.includes(oldLVClose)) { code = code.replace(oldLVClose, newLVClose); console.log('✓ AnimationLimiter closed'); }
else { console.warn('⚠ AnimationLimiter close not found'); }

fs.writeFileSync('lib/screens/home_map_screen.dart', code, 'utf8');
console.log('\nDone');