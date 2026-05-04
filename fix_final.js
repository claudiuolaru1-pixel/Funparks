const fs=require('fs');
let c=fs.readFileSync('lib/screens/park_detail_screen.dart','utf8');

// Fix 1: Remove WaitTimeService from detail screen build
c=c.replace(
  '    final cat = widget.categoryLabel(a.category);\n    final service = WaitTimeService();\n\n    final factLines',
  '    final cat = widget.categoryLabel(a.category);\n\n    final factLines'
);

// Fix 2: Replace StreamBuilder with static pill in detail screen
c=c.replace(
  `                  StreamBuilder<WaitTimeReading?>(
                    stream: service.streamLiveWaitReading(
                        parkId: widget.parkId,
                        attractionId: a.id),
                    builder: (_, snap) {
                      final minutes =
                          snap.data?.minutes ?? a.liveWaitMinutes;
                      return _Pill(
                          icon: Icons.timer,
                          text:
                              '\$minutes min (\${loc.liveWait})');
                    },
                  ),`,
  `                  _Pill(icon: Icons.timer, text: '\${a.liveWaitMinutes} min (\${loc.liveWait})'),`
);

// Fix 3: Replace context.watch with context.read in i18n helpers
c=c.replace(/final lang = context\.watch<AppState>\(\)\.languageCode;/g,
  'final lang = context.read<AppState>().languageCode;');

// Fix 4: Hardcode white background - remove brightness check
c=c.replace(
  'backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF121212) : Colors.white,\n      appBar: AppBar(\n        title: Text(a.name),',
  'backgroundColor: Colors.white,\n      appBar: AppBar(\n        backgroundColor: Colors.white,\n        title: Text(a.name),'
);

// Fix 5: Remove CupertinoPageRoute - revert to MaterialPageRoute
c=c.replace(/CupertinoPageRoute/g, 'MaterialPageRoute');

fs.writeFileSync('lib/screens/park_detail_screen.dart',c,'utf8');
console.log('WaitTimeService removed:', !c.includes('final service = WaitTimeService()') ? 'YES' : 'NO');
console.log('StreamBuilder removed:', !c.includes('service.streamLiveWaitReading') ? 'YES' : 'NO');
console.log('context.watch remaining:', (c.match(/context\.watch<AppState>/g)||[]).length);
console.log('White background:', c.includes('backgroundColor: Colors.white,\n      appBar: AppBar(\n        backgroundColor: Colors.white') ? 'YES' : 'NO');