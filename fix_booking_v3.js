const fs=require('fs');
const path='lib/screens/park_detail_screen.dart';
let c=fs.readFileSync(path,'utf8');

// Fix 1: Add parkCity field to _HotelDetailScreen widget definition
const old1 = `class _HotelDetailScreen extends StatefulWidget {
  final Hotel hotel;
  final I18nContent i18n;
  const _HotelDetailScreen(
      {required this.hotel, required this.i18n});`;
const new1 = `class _HotelDetailScreen extends StatefulWidget {
  final Hotel hotel;
  final I18nContent i18n;
  final String parkCity;
  const _HotelDetailScreen(
      {required this.hotel, required this.i18n, this.parkCity = ''});`;

// Fix 2: Pass park.city when instantiating
const old2 = `                        builder: (_) => _HotelDetailScreen(
                              hotel: h, i18n: widget.i18n)));`;
const new2 = `                        builder: (_) => _HotelDetailScreen(
                              hotel: h, i18n: widget.i18n, parkCity: widget.park.city ?? '')));`;

let changed=0;

// Try normal newlines first, then CRLF
[old1,old2].forEach((old,idx)=>{
  const rep = idx===0 ? new1 : new2;
  if(c.includes(old)){
    c=c.replace(old,rep);
    console.log('Fixed step '+(idx+1));
    changed++;
  } else {
    const crlf=old.replace(/\n/g,'\r\n');
    if(c.includes(crlf)){
      c=c.replace(crlf,rep);
      console.log('Fixed step '+(idx+1)+' (CRLF)');
      changed++;
    } else {
      console.log('Step '+(idx+1)+' not found');
    }
  }
});

if(changed>0){
  fs.writeFileSync(path,c,'utf8');
  console.log('Saved. Changes:',changed);
}