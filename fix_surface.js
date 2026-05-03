const fs=require('fs');
let c=fs.readFileSync('lib/screens/park_detail_screen.dart','utf8');

// Remove RepaintBoundary wrapper from TopCard
c=c.replace(
  `      child: RepaintBoundary(
        child: Container(`,
  `      child: Container(`
);
// Fix the extra closing bracket from RepaintBoundary removal
// Find the pattern where RepaintBoundary closing was
c=c.replace(
  `          ),
        ),
      ),
    );
  }
}
class _AttractionTopCard`,
  `          ),
      ),
    );
  }
}
class _AttractionTopCard`
);

// Fix ALL cs.surface to explicit white
c=c.replace(/color: cs\.surface,/g,'color: Colors.white,');
c=c.replace(/color: cs\.surfaceContainerHighest,/g,'color: const Color(0xFFF5F5F5),');

fs.writeFileSync('lib/screens/park_detail_screen.dart',c,'utf8');
console.log('Fixed RepaintBoundary and all cs.surface');
console.log('Remaining cs.surface:',( c.match(/cs\.surface/g)||[]).length);