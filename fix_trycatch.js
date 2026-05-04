const fs=require('fs');
let c=fs.readFileSync('lib/screens/park_detail_screen.dart','utf8');

// Find the return Scaffold in detail screen and wrap in try-catch
const oldReturn = `    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(`;

const newReturn = `    try {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(`;

c = c.replace(oldReturn, newReturn);

// Find the closing of this Scaffold - it's the last ); before the closing } of build
// We need to add } catch(e) { return Scaffold(error) } after the build method's return
// Find "  }\n}" pattern that ends the build method  
c = c.replace(
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
        body: Center(child: Text(widget.attraction.name, style: const TextStyle(color: Colors.black))),
      );
    }
  }
}

// ===============================================================
// FOOD TAB`
);

fs.writeFileSync('lib/screens/park_detail_screen.dart',c,'utf8');
console.log('Wrapped build in try-catch');
console.log('Has try-catch:',c.includes('} catch (e) {'));