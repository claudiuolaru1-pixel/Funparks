const fs=require('fs');
let c=fs.readFileSync('lib/screens/park_detail_screen.dart','utf8');

// Remove _PremiumAppear wrapper - just return child directly
c=c.replace(
  `    return _PremiumAppear(
      child: _PressDown(`,
  `    return _PressDown(`
);

// Fix the extra closing ) that was for _PremiumAppear
// Find the pattern: );  }  } where first ); closed _PremiumAppear
c=c.replace(
  `        ),
      ),
    );
  }
}
class _AttractionTopCard`,
  `        ),
    );
  }
}
class _AttractionTopCard`
);

fs.writeFileSync('lib/screens/park_detail_screen.dart',c,'utf8');
console.log('Removed _PremiumAppear');
console.log('_PremiumAppear usages remaining:',(c.match(/_PremiumAppear\(/g)||[]).length);