const fs=require('fs');
const path='lib/screens/park_detail_screen.dart';
const lines=fs.readFileSync(path,'utf8').split('\n');

// Find the Tours & Experiences button and replace with region-aware version
// Also fix the Skip the Line button with region-aware links
// Also fix missing closing bracket after Get Your Tickets Now

let fixed=0;

// Step 1: Fix missing ], and ) after Get Your Tickets Now row (line ~1261)
for(let i=1255;i<1270;i++){
  if(lines[i] && lines[i].includes('backgroundColor: Colors.deepOrange),')){
    // Check if next lines are missing the closing of the Row
    if(lines[i+1] && !lines[i+1].includes('],')){
      lines.splice(i+2,0,'          ],','        ),');
      console.log('Fixed missing brackets at line',i);
      fixed++;
      break;
    }
  }
}

// Step 2: Replace Skip the Line button with region-aware version
for(let i=1240;i<1260;i++){
  if(lines[i] && lines[i].includes("label: const Text('Skip the Line')")){
    // Find start of this OutlinedButton block
    let start=i;
    while(start>0 && !lines[start].includes('OutlinedButton.icon(')){start--;}
    start--; // Include Expanded(
    // Find end
    let end=i+2; // ),  ),
    lines.splice(start, end-start+1,
      "            Expanded(",
      "              child: OutlinedButton.icon(",
      "                onPressed: () async {",
      "                  final country = park.country.toLowerCase();",
      "                  final query = Uri.encodeComponent('${park.city ?? ''} ${park.name}'.trim());",
      "                  Uri url;",
      "                  if (country.contains('japan') || country.contains('china') || country.contains('korea') || country.contains('hong kong') || country.contains('singapore') || country.contains('thailand') || country.contains('taiwan') || country.contains('indonesia') || country.contains('malaysia') || country.contains('philippines')) {",
      "                    url = Uri.parse('https://affiliate.klook.com/redirect?aid=119449&aff_adid=&k_site=https%3A%2F%2Fwww.klook.com%2Fsearch%2F%3Fquery%3D\$query');",
      "                  } else if (country.contains('usa') || country.contains('united states') || country.contains('canada') || country.contains('australia') || country.contains('mexico')) {",
      "                    url = Uri.parse('https://www.viator.com/search/\$query?pid=P00298240&mcid=42383&medium=link');",
      "                  } else {",
      "                    url = Uri.parse('https://www.getyourguide.com/s/?q=\$query&partner_id=GVNQTTL');",
      "                  }",
      "                  await launchUrl(url, mode: LaunchMode.externalApplication);",
      "                },",
      "                icon: const Icon(Icons.bolt),",
      "                label: const Text('Skip the Line'),",
      "              ),",
      "            ),"
    );
    console.log('Skip the Line button updated with region-aware links');
    fixed++;
    break;
  }
}

// Step 3: Replace Tours & Experiences button with region-aware version
for(let i=1260;i<1310;i++){
  if(lines[i] && lines[i].includes("label: const Text('Tours & Experiences')")){
    let start=i;
    while(start>0 && !lines[start].includes('OutlinedButton.icon(')){start--;}
    start--;
    let end=i+2;
    lines.splice(start, end-start+1,
      "            Expanded(",
      "              child: OutlinedButton.icon(",
      "                onPressed: () async {",
      "                  final country = park.country.toLowerCase();",
      "                  final query = Uri.encodeComponent('${park.city ?? ''} ${park.name} tours'.trim());",
      "                  Uri url;",
      "                  if (country.contains('japan') || country.contains('china') || country.contains('korea') || country.contains('hong kong') || country.contains('singapore') || country.contains('thailand') || country.contains('taiwan') || country.contains('indonesia') || country.contains('malaysia') || country.contains('philippines')) {",
      "                    url = Uri.parse('https://affiliate.klook.com/redirect?aid=119449&aff_adid=&k_site=https%3A%2F%2Fwww.klook.com%2Fsearch%2F%3Fquery%3D\$query');",
      "                  } else if (country.contains('usa') || country.contains('united states') || country.contains('canada') || country.contains('australia') || country.contains('mexico')) {",
      "                    url = Uri.parse('https://www.viator.com/search/\$query?pid=P00298240&mcid=42383&medium=link');",
      "                  } else {",
      "                    url = Uri.parse('https://www.getyourguide.com/s/?q=\$query&partner_id=GVNQTTL');",
      "                  }",
      "                  await launchUrl(url, mode: LaunchMode.externalApplication);",
      "                },",
      "                icon: const Icon(Icons.explore),",
      "                label: const Text('Tours & Experiences'),",
      "              ),",
      "            ),"
    );
    console.log('Tours & Experiences button updated with region-aware links');
    fixed++;
    break;
  }
}

fs.writeFileSync(path,lines.join('\n'),'utf8');
console.log('Total fixes:',fixed);