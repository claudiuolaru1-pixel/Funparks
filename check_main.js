const fs=require('fs');
let c=fs.readFileSync('lib/main.dart','utf8');

// Find and replace Firebase init
const lines=c.split('\n');
for(let i=0;i<lines.length;i++){
  if(lines[i].includes('Firebase.initializeApp')||lines[i].includes('Firebase.apps.isEmpty')||lines[i].includes('firebase_options')){
    console.log(i+1,lines[i].trim());
  }
}