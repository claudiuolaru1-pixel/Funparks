const fs=require('fs');
let code=fs.readFileSync('lib/screens/home_map_screen.dart','utf8');
code=code.replace(/\r\n/g,'\n');

// Check all staggered animation references
let i=0;
while(true){
  const found=code.indexOf('Animation',i);
  if(found===-1) break;
  const snippet=code.substring(found,found+60);
  if(snippet.includes('stagger')||snippet.includes('Stagger')||snippet.includes('Limiter')||snippet.includes('SlideAnim')||snippet.includes('FadeIn')){
    console.log('at',found,':',JSON.stringify(snippet));
  }
  i=found+1;
}

// Also check the shimmer/loading display
const sIdx=code.indexOf('ShimmerParkList');
console.log('\nShimmerParkList:',JSON.stringify(code.substring(sIdx-50,sIdx+100)));