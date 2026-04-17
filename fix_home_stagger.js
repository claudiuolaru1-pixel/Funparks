const fs=require('fs');
let code=fs.readFileSync('lib/screens/home_map_screen.dart','utf8');
code=code.replace(/\r\n/g,'\n');

// Remove staggered animation wrapper — replace with just the ListTile child directly
const oldStagger = `return AnimationConfiguration.staggeredList(\n                    position: i,\n                    duration: const Duration(milliseconds: 375),\n                    child: SlideAnimation(\n                      verticalOffset: 28.0,\n                      child: FadeInAnimation(\n                        child: ListTile(`;
const newStagger = `return ListTile(`;
if (code.includes(oldStagger)) {
  // Find the closing brackets of the 3 wrappers after the ListTile block
  // Replace the open
  code = code.replace(oldStagger, newStagger);
  // Remove the 3 extra closing brackets that belonged to FadeInAnimation, SlideAnimation, AnimationConfiguration
  // They appear as ),\n                    ),\n                  );\n after the ListTile closing )
  code = code.replace(
    `),\n                    ),\n                  );\n`,
    `);\n`
  );
  console.log('✓ Staggered animation removed');
} else {
  console.log('⚠ Stagger pattern not found — logging snippet');
  const idx=code.indexOf('AnimationConfiguration');
  console.log(JSON.stringify(code.substring(idx,idx+400)));
}

fs.writeFileSync('lib/screens/home_map_screen.dart',code,'utf8');
console.log('✓ home_map_screen.dart written');