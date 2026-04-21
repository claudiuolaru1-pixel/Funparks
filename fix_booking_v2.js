const fs=require('fs');
const path='lib/screens/park_detail_screen.dart';
let c=fs.readFileSync(path,'utf8');

// Step 1: Fix the broken URL (has space before checkin and uses park.city which doesn't exist)
const badUrl = `'https://www.booking.com/searchresults.html?aid=4347407&ss=\${Uri.encodeComponent("\${hotel.name} \${park.city ?? ''}")}& checkin=&checkout=&group_adults=2&no_rooms=1&label=funparks-app',`;
const fixedUrl = `'https://www.booking.com/searchresults.html?aid=4347407&ss=\${Uri.encodeComponent(hotel.name)}&checkin=&checkout=&group_adults=2&no_rooms=1&label=funparks-app',`;

if(c.includes(badUrl)){
  c=c.replace(badUrl, fixedUrl);
  console.log('Step 1: fixed bad URL');
} else {
  console.log('Step 1: bad URL not found');
}

// Step 2: Add parkCity parameter to _HotelDetailScreen widget
const oldWidget = `class _HotelDetailScreen extends StatefulWidget {
  final Hotel hotel;
  final I18nContent i18n;
  const _HotelDetailScreen(
      {required this.hotel, required this.i18n});`;

const newWidget = `class _HotelDetailScreen extends StatefulWidget {
  final Hotel hotel;
  final I18nContent i18n;
  final String parkCity;
  const _HotelDetailScreen(
      {required this.hotel, required this.i18n, this.parkCity = ''});`;

if(c.includes(oldWidget)){
  c=c.replace(oldWidget, newWidget);
  console.log('Step 2: added parkCity param');
} else {
  const oldCRLF=oldWidget.replace(/\n/g,'\r\n');
  if(c.includes(oldCRLF)){
    c=c.replace(oldCRLF, newWidget);
    console.log('Step 2: added parkCity param (CRLF)');
  } else {
    console.log('Step 2: not found');
  }
}

// Step 3: Use parkCity in the state
const oldState = `  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final hotel = widget.hotel;
    final i18n = widget.i18n;`;

const newState = `  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final hotel = widget.hotel;
    final i18n = widget.i18n;
    final parkCity = widget.parkCity;`;

if(c.includes(oldState)){
  c=c.replace(oldState, newState);
  console.log('Step 3: added parkCity to state');
} else {
  const oldCRLF=oldState.replace(/\n/g,'\r\n');
  if(c.includes(oldCRLF)){
    c=c.replace(oldCRLF, newState);
    console.log('Step 3: added parkCity to state (CRLF)');
  } else {
    console.log('Step 3: not found');
  }
}

// Step 4: Use parkCity in the URL
const oldSimpleUrl = `                            final url = Uri.parse(
                              'https://www.booking.com/searchresults.html?aid=4347407&ss=\${Uri.encodeComponent(hotel.name)}&checkin=&checkout=&group_adults=2&no_rooms=1&label=funparks-app',`;

const newCityUrl = `                            final searchQuery = parkCity.isNotEmpty ? '\${hotel.name} \$parkCity' : hotel.name;
                            final url = Uri.parse(
                              'https://www.booking.com/searchresults.html?aid=4347407&ss=\${Uri.encodeComponent(searchQuery)}&checkin=&checkout=&group_adults=2&no_rooms=1&label=funparks-app',`;

if(c.includes(oldSimpleUrl)){
  c=c.replace(oldSimpleUrl, newCityUrl);
  console.log('Step 4: URL now includes city');
} else {
  const oldCRLF=oldSimpleUrl.replace(/\n/g,'\r\n');
  if(c.includes(oldCRLF)){
    c=c.replace(oldCRLF, newCityUrl);
    console.log('Step 4: URL includes city (CRLF)');
  } else {
    console.log('Step 4: not found');
  }
}

fs.writeFileSync(path,c,'utf8');
console.log('Done');