const fs=require('fs');
let c=fs.readFileSync('lib/screens/park_detail_screen.dart','utf8');

// Revert Positioned.fill - restore original TabBarView
c=c.replace(
  'Positioned.fill(child: TabBarView(',
  'TabBarView('
);
// Fix the extra closing from Positioned.fill
c=c.replace('                    )),', '                    ),');

// Wrap the _AttractionsTab return ListView with Material
c=c.replace(
  `    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),`,
  `    return Material(
      color: Colors.white,
      child: ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),`
);

// Close the Material widget - find end of _AttractionsTabState build
// Add closing ) before the last } of build method
// This is tricky - let's find the specific pattern
const oldEnd = `        const SizedBox(height: 8),
      ],
    );
  }
}`;
const newEnd = `        const SizedBox(height: 8),
      ],
    ),);
  }
}`;
c=c.replace(oldEnd, newEnd);

fs.writeFileSync('lib/screens/park_detail_screen.dart',c,'utf8');
console.log('Fixed - Material wrapper');
console.log('Has Material color white:',c.includes('Material(\n      color: Colors.white'));