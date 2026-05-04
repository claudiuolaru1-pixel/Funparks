const fs=require('fs');
let c=fs.readFileSync('lib/screens/park_detail_screen.dart','utf8');

// 1. Remove WaitTimeService from detail screen build
c=c.replace(
  '    final cat = widget.categoryLabel(a.category);\n    final service = WaitTimeService();\n\n    final factLines',
  '    final cat = widget.categoryLabel(a.category);\n\n    final factLines'
);

// 2. Replace StreamBuilder in detail screen with static pill
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

// 3. Wrap return Scaffold in try-catch
c=c.replace(
  '    return Scaffold(\n      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF121212) : Colors.white,\n      appBar: AppBar(\n        title: Text(a.name),',
  '    try {\n    return Scaffold(\n      backgroundColor: Colors.white,\n      appBar: AppBar(\n        title: Text(a.name),'
);

// 4. Add catch block before end of build method
c=c.replace(
  `        ],
      ),
    );
  }
}

// ===============================================================
// FOOD TAB`,
  `        ],
      ),
    );
    } catch (e) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: Text(widget.attraction.name), backgroundColor: Colors.white),
        body: Container(color: Colors.white, padding: const EdgeInsets.all(16),
          child: Text(widget.attraction.name, style: const TextStyle(fontSize: 20, color: Colors.black))),
      );
    }
  }
}

// ===============================================================
// FOOD TAB`
);

fs.writeFileSync('lib/screens/park_detail_screen.dart',c,'utf8');
console.log('WaitTimeService removed:', !c.includes('final service = WaitTimeService();\n\n    final factLines') ? 'YES' : 'NO');
console.log('try-catch added:', c.includes('} catch (e) {') ? 'YES' : 'NO');
console.log('StreamBuilder removed:', !c.includes('stream: service.streamLiveWaitReading') ? 'YES' : 'NO');