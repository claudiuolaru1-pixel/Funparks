const fs=require('fs');
let c=fs.readFileSync('ios/Runner/Info.plist','utf8');

// Add privacy strings before </dict>
const privacyStrings=`
<key>NSMicrophoneUsageDescription</key>
<string>Funparks uses the microphone for voice search to help you find theme parks and attractions hands-free.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>Funparks uses speech recognition to let you search for parks and attractions using your voice.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Funparks uses your location to show nearby theme parks and calculate distances.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Funparks uses your location to show nearby theme parks and calculate distances.</string>
<key>NSCameraUsageDescription</key>
<string>Funparks uses the camera for QR code scanning at park entrances.</string>
`;

if(!c.includes('NSMicrophoneUsageDescription')){
  c=c.replace('</dict>\n</plist>',privacyStrings+'</dict>\n</plist>');
  fs.writeFileSync('ios/Runner/Info.plist',c,'utf8');
  console.log('Added privacy strings');
} else {
  console.log('Privacy strings already present');
}