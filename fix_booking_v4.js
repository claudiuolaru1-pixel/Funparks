const fs=require('fs');
const path='lib/screens/park_detail_screen.dart';
const lines=fs.readFileSync(path,'utf8').split('\n');

// Find the _HotelDetailScreen class specifically (around line 3191)
let classLine=-1;
for(let i=3185;i<3205;i++){
  if(lines[i] && lines[i].includes('class _HotelDetailScreen extends StatefulWidget')){
    classLine=i;
    break;
  }
}
console.log('Class at line:',classLine);

// Find i18n line inside this class
let i18nLine=-1;
for(let i=classLine;i<classLine+10;i++){
  if(lines[i] && lines[i].includes('final I18nContent i18n;')){
    i18nLine=i;
    break;
  }
}
console.log('i18n line:',i18nLine);

// Insert parkCity field after i18n line
lines.splice(i18nLine+1,0,'  final String parkCity;');

// Find and fix constructor (now shifted by 1)
for(let i=classLine;i<classLine+12;i++){
  if(lines[i] && lines[i].includes('required this.i18n});')){
    lines[i]=lines[i].replace('required this.i18n});',"required this.i18n, this.parkCity = ''});");
    console.log('Constructor fixed at line:',i);
    break;
  }
  if(lines[i] && lines[i].includes('required this.i18n}')){
    lines[i]=lines[i].replace('required this.i18n}',"required this.i18n, this.parkCity = ''}");
    console.log('Constructor fixed at line:',i);
    break;
  }
}

fs.writeFileSync(path,lines.join('\n'),'utf8');
console.log('Done');