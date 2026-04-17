const fs=require('fs');
let code=fs.readFileSync('lib/screens/home_map_screen.dart','utf8');
code=code.replace(/\r\n/g,'\n');

// Remove AnimationLimiter wrapper
const old1 = 'flex: 2,\n              child: AnimationLimiter(\n                child: ListView.separated(';
const new1 = 'flex: 2,\n              child: ListView.separated(';
if(code.includes(old1)){ code=code.replace(old1,new1); console.log('✓ AnimationLimiter open removed'); }
else { console.log('⚠ AnimationLimiter open not found'); }

// Remove its closing bracket — appears right after ListView closing )
const old2 = '                ),\n              ),\n            ),\n          ),\n        if (!_loading';
const new2 = '              ),\n            ),\n          ),\n        if (!_loading';
if(code.includes(old2)){ code=code.replace(old2,new2); console.log('✓ AnimationLimiter close removed'); }
else { console.log('⚠ Close bracket not found — checking area');
  const idx=code.indexOf('if (!_loading');
  console.log(JSON.stringify(code.substring(idx-200,idx+50)));
}

fs.writeFileSync('lib/screens/home_map_screen.dart',code,'utf8');
console.log('Done');