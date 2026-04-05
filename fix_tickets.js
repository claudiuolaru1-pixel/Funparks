const fs=require('fs');
function readJson(path){let raw=fs.readFileSync(path,'utf8');if(raw.charCodeAt(0)===0xFEFF)raw=raw.slice(1);return JSON.parse(raw);}

const fixes = {
  'gold_reef_city':        'https://themeparktickets.goldreefcity.co.za',
  'parque_warner_madrid':  'https://www.parquewarner.com/en/tickets',
  'mirabilandia':          'https://www.mirabilandia.it/en/biglietti-abbonamenti/single-ticket/select-visitors',
  'puydufou':              'https://reservation.puydufou.com/en/offers',
  'legoland_deutschland':  'https://www.legoland.de/en/tickets/most-popular-tickets/day-tickets/',
  'moviepark':             'https://www.movieparkgermany.de/en/eintrittskarten/single-ticket/select-visitors',
  'siampark':              'https://siampark.net/ticketsonline/en/paso0',
  'tivoli':                'https://shop.tivoli.dk/en/billetter-og-tivolikort',
  'phantasialand':         'https://shop.phantasialand.de/en/products/theme-park-tickets/2026-05'
};

// Fix parks_index.json
const index = readJson('assets/data/parks/parks_index.json');
let fixedIndex = 0;
index.forEach(p => {
  if(fixes[p.id]){p.ticketsUrl = fixes[p.id]; fixedIndex++;}
});
fs.writeFileSync('assets/data/parks/parks_index.json', JSON.stringify(index,null,4),'utf8');
console.log('parks_index.json fixed:', fixedIndex, 'parks');

// Fix parks.json
const parks = readJson('assets/data/parks.json');
let fixedParks = 0;
parks.forEach(p => {
  if(fixes[p.id]){p.ticketsUrl = fixes[p.id]; fixedParks++;}
});
fs.writeFileSync('assets/data/parks.json', JSON.stringify(parks,null,4),'utf8');
console.log('parks.json fixed:', fixedParks, 'parks');