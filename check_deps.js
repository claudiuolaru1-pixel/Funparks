const fs=require('fs');
let c=fs.readFileSync('pubspec.yaml','utf8');
// Check current geolocator version
const lines=c.split('\n').filter(l=>l.includes('geolocator'));
console.log('Current geolocator:',lines);