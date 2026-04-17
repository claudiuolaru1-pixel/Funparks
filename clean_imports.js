const fs=require('fs');
let code=fs.readFileSync('lib/screens/home_map_screen.dart','utf8');
code=code.replace(/\r\n/g,'\n');

// Remove staggered animations import
code=code.replace("import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';\n",'');
console.log('✓ Removed staggered_animations import');

// Remove unused widget imports
code=code.replace("import '../widgets/premium_park_card.dart';\n",'');
code=code.replace("import '../widgets/featured_parks_banner.dart';\n",'');
console.log('✓ Removed unused widget imports');

// Verify no AnimationLimiter or AnimationConfiguration left
if(code.includes('AnimationLimiter')||code.includes('AnimationConfiguration')||code.includes('StaggeredList')){
  console.log('⚠ Stagger references still present!');
} else {
  console.log('✓ No stagger references remaining');
}

fs.writeFileSync('lib/screens/home_map_screen.dart',code,'utf8');