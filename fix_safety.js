const fs=require('fs');
let c=fs.readFileSync('lib/main.dart','utf8');
// Keep Firebase enabled - patch should handle it
console.log('Firebase iOS enabled:', c.includes('Firebase.apps.isEmpty') && !c.includes('Platform.isIOS'));