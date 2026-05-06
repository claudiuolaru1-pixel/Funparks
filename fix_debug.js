const fs=require('fs');
let c=fs.readFileSync('lib/screens/park_detail_screen.dart','utf8');

// Find the attraction detail screen build method and add error-showing try-catch
// The build starts with "final locRaw = AppLocalizations"
const buildStart = `  Widget build(BuildContext context) {
    final locRaw = AppLocalizations.of(context);
    if (locRaw == null) return Scaffold(backgroundColor: Colors.white, appBar: AppBar(title: Text(widget.attraction.name)), body: const SizedBox.shrink());
    final loc = locRaw;`;

const buildStartWithTry = `  Widget build(BuildContext context) {
    try {
    final locRaw = AppLocalizations.of(context);
    if (locRaw == null) return Scaffold(backgroundColor: Colors.white, appBar: AppBar(title: Text(widget.attraction.name)), body: const SizedBox.shrink());
    final loc = locRaw;`;

c = c.replace(buildStart, buildStartWithTry);

// Find the end of the build method (just before "  }\n}" that ends the class)
// and add the catch block
c = c.replace(
  `        ],
      ),
    ));
  }
}

// ===============================================================
// FOOD TAB`,
  `        ],
      ),
    ));
    } catch (e) {
      return Scaffold(
        backgroundColor: Colors.red[100],
        appBar: AppBar(title: Text('ERR: ${e.toString().substring(0, e.toString().length > 60 ? 60 : e.toString().length)}'), backgroundColor: Colors.red),
        body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Text(e.toString())),
      );
    }
  }
}

// ===============================================================
// FOOD TAB`
);

fs.writeFileSync('lib/screens/park_detail_screen.dart',c,'utf8');
console.log('try-catch added:', c.includes('backgroundColor: Colors.red[100]') ? 'YES' : 'NO');