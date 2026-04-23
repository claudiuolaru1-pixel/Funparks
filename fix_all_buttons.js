const fs=require('fs');
const path='lib/screens/park_detail_screen.dart';
const lines=fs.readFileSync(path,'utf8').split('\n');
let changes=0;

// 1. Add "Tours & Experiences" button after the Get Your Tickets Now row
for(let i=0;i<lines.length;i++){
  if(lines[i].includes("style: FilledButton.styleFrom(backgroundColor: Colors.deepOrange),")){
    // Check if Tours button already added
    if(!lines[i+3] || !lines[i+3].includes('Tours')){
      lines.splice(i+3, 0,
        "        const SizedBox(height: 10),",
        "        Row(",
        "          children: [",
        "            Expanded(",
        "              child: OutlinedButton.icon(",
        "                onPressed: () async {",
        "                  final query = Uri.encodeComponent((park.city ?? '') + ' ' + park.name);",
        "                  final url = Uri.parse('https://www.getyourguide.com/s/?q=\$query&partner_id=GYGPID');",
        "                  await launchUrl(url, mode: LaunchMode.externalApplication);",
        "                },",
        "                icon: const Icon(Icons.explore),",
        "                label: const Text('Tours & Experiences'),",
        "              ),",
        "            ),",
        "          ],",
        "        ),"
      );
      console.log('Added Tours & Experiences button at line',i);
      changes++;
      break;
    }
  }
}

// 2. Add "Find Hotels Near This Park" button in HotelsTab after the sort menu
for(let i=0;i<lines.length;i++){
  if(lines[i].includes('const SizedBox(height: 10),') &&
     lines[i+1] && lines[i+1].includes('if (list.isEmpty)')){
    if(!lines[i-1] || !lines[i-1].includes('Find Hotels')){
      lines.splice(i, 0,
        "          SizedBox(",
        "            width: double.infinity,",
        "            child: ElevatedButton.icon(",
        "              style: ElevatedButton.styleFrom(",
        "                backgroundColor: const Color(0xFF003580),",
        "                foregroundColor: Colors.white,",
        "                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),",
        "                padding: const EdgeInsets.symmetric(vertical: 12),",
        "              ),",
        "              icon: const Icon(Icons.hotel, size: 18),",
        "              label: const Text('Find Hotels Near This Park',",
        "                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),",
        "              onPressed: () async {",
        "                final url = Uri.parse(",
        "                  'https://www.booking.com/searchresults.html?aid=4347407&latitude=\${widget.park.lat}&longitude=\${widget.park.lng}&radius=10&label=funparks-app&group_adults=2&no_rooms=1',",
        "                );",
        "                await launchUrl(url, mode: LaunchMode.externalApplication);",
        "              },",
        "            ),",
        "          ),",
        "          const SizedBox(height: 10),"
      );
      console.log('Added Find Hotels button at line',i);
      changes++;
      break;
    }
  }
}

// 3. Remove individual Book Now button from room cards
const bookNowStart = "                      const SizedBox(height: 10),\n                      SizedBox(\n                        width: double.infinity,\n                        child: ElevatedButton.icon(\n                          style: ElevatedButton.styleFrom(\n                            backgroundColor: const Color(0xFF003580),\n                            foregroundColor: Colors.white,\n                            shape: RoundedRectangleBorder(\n                              borderRadius: BorderRadius.circular(10),\n                            ),\n                            padding: const EdgeInsets.symmetric(vertical: 12),\n                          ),\n                          icon: const Icon(Icons.hotel, size: 18),\n                          label: const Text('Book Now',\n                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),\n                          onPressed: () async {\n                            final searchQuery = parkCity.isNotEmpty ? '$parkCity ${hotel.name}' : hotel.name;\n                            final url = Uri.parse(\n                              'https://www.booking.com/searchresults.html?aid=4347407&ss=${Uri.encodeComponent(searchQuery)}&checkin=&checkout=&group_adults=2&no_rooms=1&label=funparks-app',\n                            );\n                            await launchUrl(url, mode: LaunchMode.externalApplication);\n                          },\n                        ),\n                      ),";

const content = lines.join('\n');
if(content.includes("label: const Text('Book Now',")){
  // Find and remove Book Now block line by line
  let inBookNow=false;
  let bookNowDepth=0;
  const filtered=[];
  for(let i=0;i<lines.length;i++){
    if(!inBookNow && lines[i].includes("label: const Text('Book Now',")){
      // Remove backwards from SizedBox
      while(filtered.length && !filtered[filtered.length-1].includes('const SizedBox(height: 10),')){
        filtered.pop();
      }
      if(filtered.length && filtered[filtered.length-1].includes('const SizedBox(height: 10),')){
        filtered.pop();
      }
      inBookNow=true;
      bookNowDepth=0;
      continue;
    }
    if(inBookNow){
      if(lines[i].includes('),') && bookNowDepth===0){
        inBookNow=false;
        changes++;
        console.log('Removed Book Now button near line',i);
        continue;
      }
      continue;
    }
    filtered.push(lines[i]);
  }
  if(changes>0){
    fs.writeFileSync(path,filtered.join('\n'),'utf8');
    console.log('Total changes:',changes);
    process.exit(0);
  }
}

fs.writeFileSync(path,lines.join('\n'),'utf8');
console.log('Total changes:',changes);