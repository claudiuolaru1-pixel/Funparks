const fs=require('fs');
let code=fs.readFileSync('lib/screens/home_map_screen.dart','utf8');
code=code.replace(/\r\n/g,'\n');

// Check error display
const errIdx=code.indexOf('_error');
let i=0;
let count=0;
while(count<8){
  const found=code.indexOf('_error',i);
  if(found===-1) break;
  console.log('_error at',found,':',JSON.stringify(code.substring(found-20,found+80)));
  i=found+1;
  count++;
}

// Check _hasActiveFilters
const haf=code.indexOf('_hasActiveFilters');
console.log('\n_hasActiveFilters:',JSON.stringify(code.substring(haf,haf+200)));