const fs = require('fs');

function readJson(path) {
  let raw = fs.readFileSync(path, 'utf8');
  if (raw.charCodeAt(0) === 0xFEFF) raw = raw.slice(1);
  return JSON.parse(raw);
}

const index = readJson('assets/data/parks/parks_index.json');

// Fix tokyo_disneyland entry
const tokyo = index.find(p => p.id === 'tokyo_disneyland');
if (tokyo) {
  tokyo.thumbnail = "assets/images/tokyo_disneyland/park_thumbnail.png";
  tokyo.type = "Theme Park";
  tokyo.detailAsset = "";
  tokyo.openingHours = "09:00 - 21:00";
  tokyo.entryPrices = { adult: 9400, child: 5300 };
  delete tokyo.thumbnailAsset;
  console.log('tokyo_disneyland fixed');
}

// Fix or add shanghai_disneyland entry
const sdlIdx = index.findIndex(p => p.id === 'shanghai_disneyland');
const sdl = {
  id: "shanghai_disneyland",
  name: "Shanghai Disneyland",
  city: "Shanghai",
  country: "China",
  type: "Theme Park",
  lat: 31.1437,
  lng: 121.6571,
  thumbnail: "assets/images/shanghai_disneyland/park_thumbnail.png",
  website: "https://www.shanghaidisneyresort.com/en/",
  ticketsUrl: "https://www.shanghaidisneyresort.com/en/tickets/",
  detailAsset: "",
  openingHours: "09:00 - 21:00",
  entryPrices: { adult: 599, child: 399 },
  currency: "CNY",
  queueTimesId: 0
};
if (sdlIdx >= 0) { index[sdlIdx] = sdl; } else { index.push(sdl); }
console.log('shanghai_disneyland fixed');

fs.writeFileSync('assets/data/parks/parks_index.json', JSON.stringify(index, null, 4), 'utf8');
console.log('Done, total entries:', index.length);