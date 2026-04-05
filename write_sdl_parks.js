const fs=require('fs');

const sdlEntry = {
  "id": "shanghai_disneyland",
  "thumbnailAsset": "assets/images/shanghai_disneyland/park_thumbnail.png",
  "tailAsset": "",
  "name": "Shanghai Disneyland",
  "type": "Theme Park",
  "entryPrice": { "child": 399, "adult": 599 },
  "currency": "CNY",
  "openingHours": "09:00 - 21:00",
  "lng": 121.6571,
  "country": "China",
  "city": "Shanghai",
  "ticketsUrl": "https://www.shanghaidisneyresort.com/en/tickets/",
  "queueTimesId": 0
};

const sdlIndex = {
  "id": "shanghai_disneyland",
  "name": "Shanghai Disneyland",
  "country": "China",
  "city": "Shanghai",
  "lat": 31.1437,
  "lng": 121.6571,
  "thumbnailAsset": "assets/images/shanghai_disneyland/park_thumbnail.png",
  "currency": "CNY",
  "ticketsUrl": "https://www.shanghaidisneyresort.com/en/tickets/",
  "website": "https://www.shanghaidisneyresort.com/en/",
  "queueTimesId": 0
};

// Strip BOM and parse
function readJson(path) {
  let raw = fs.readFileSync(path, 'utf8');
  if (raw.charCodeAt(0) === 0xFEFF) raw = raw.slice(1);
  return JSON.parse(raw);
}

const parks = readJson('assets/data/parks.json');
if (!parks.find(p => p.id === 'shanghai_disneyland')) {
  parks.push(sdlEntry);
  fs.writeFileSync('assets/data/parks.json', JSON.stringify(parks, null, 4), 'utf8');
  console.log('parks.json updated, total:', parks.length);
} else {
  console.log('parks.json already has shanghai_disneyland');
}

const index = readJson('assets/data/parks/parks_index.json');
if (!index.find(p => p.id === 'shanghai_disneyland')) {
  index.push(sdlIndex);
  fs.writeFileSync('assets/data/parks/parks_index.json', JSON.stringify(index, null, 4), 'utf8');
  console.log('parks_index.json updated, total:', index.length);
} else {
  console.log('parks_index.json already has shanghai_disneyland');
}