const fs=require('fs');
let c=fs.readFileSync('lib/screens/park_detail_screen.dart','utf8');

// Replace the spread map with for-in loop
const oldSpread = `        ...[list.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AttractionRow(
                parkId: widget.parkId,
                attraction: a,
                i18n: widget.i18n,
                categoryLabel: widget.categoryLabel,
                onTap: () { HapticFeedback.selectionClick(); _openDetails(a); },
                onDirections: () => widget.onDirections(a),
              ),
            ))],`;

const newFor = `        for (final a in list)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _AttractionRow(
              parkId: widget.parkId,
              attraction: a,
              i18n: widget.i18n,
              categoryLabel: widget.categoryLabel,
              onTap: () { HapticFeedback.selectionClick(); _openDetails(a); },
              onDirections: () => widget.onDirections(a),
            ),
          ),`;

if(c.includes(oldSpread)){
  c=c.replace(oldSpread, newFor);
  console.log('Replaced spread with for loop');
} else {
  console.log('Pattern not found - searching for partial match...');
  const idx=c.indexOf('...[list.map');
  if(idx>-1) console.log('Found at char:',idx,'context:',c.substring(idx,idx+100));
}

fs.writeFileSync('lib/screens/park_detail_screen.dart',c,'utf8');