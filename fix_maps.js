const fs=require('fs');
let c=fs.readFileSync('pubspec.yaml','utf8');
// Fix google_maps_flutter_android to compatible version
c=c.replace(/google_maps_flutter_android:.*$/m,'google_maps_flutter_android: ^2.14.13');
fs.writeFileSync('pubspec.yaml',c,'utf8');
console.log('Fixed google_maps version');
console.log(fs.readFileSync('pubspec.yaml','utf8').split('\n').filter(l=>l.includes('google_maps')));