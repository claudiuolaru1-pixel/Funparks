const fs=require('fs');
const path='lib/screens/park_detail_screen.dart';
let c=fs.readFileSync(path,'utf8');

const oldSearch = `                            final query = Uri.encodeComponent(hotel.name);
                            final url = Uri.parse(
                              'https://www.booking.com/searchresults.html?aid=4347407&ss=\$query&checkin=&checkout=&group_adults=2&no_rooms=1&label=funparks-app',`;

const newSearch = `                            final city = park.city ?? '';
                            final query = Uri.encodeComponent('\${hotel.name} \$city'.trim());
                            final url = Uri.parse(
                              'https://www.booking.com/searchresults.html?aid=4347407&ss=\$query&checkin=&checkout=&group_adults=2&no_rooms=1&label=funparks-app',`;

if(c.includes(oldSearch)){
  c=c.replace(oldSearch, newSearch);
  fs.writeFileSync(path,c,'utf8');
  console.log('Booking URL fixed with city');
} else {
  console.log('Pattern not found - trying CRLF');
  const oldCRLF=oldSearch.replace(/\n/g,'\r\n');
  if(c.includes(oldCRLF)){
    c=c.replace(oldCRLF, newSearch);
    fs.writeFileSync(path,c,'utf8');
    console.log('Fixed with CRLF');
  } else {
    console.log('ERROR: not found');
  }
}