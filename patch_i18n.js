const fs=require('fs');
const path=require('path');

function readJson(p){
  let r=fs.readFileSync(p,'utf8');
  if(r.charCodeAt(0)===0xFEFF)r=r.slice(1);
  return JSON.parse(r);
}

const base=process.cwd();
const i18nDir=path.join(base,'assets/i18n');
const dataDir=path.join(base,'assets/data/parks');

// Load translations we generated
const epAdd=readJson('europapark_additions.json');
const sfRooms=readJson('sf_room_translations.json');

// ─── 1. EUROPA PARK: add food + hotels ───────────────────────────────────────
const epPath=path.join(i18nDir,'europapark.json');
const ep=readJson(epPath);
ep.food=epAdd.food;
ep.hotels=epAdd.hotels;
fs.writeFileSync(epPath,JSON.stringify(ep,null,2),'utf8');
console.log('Europa Park: added food + hotels translations');

// ─── 2. SIX FLAGS: add rooms to all 5 parks ──────────────────────────────────
const sfParks=[
  'six_flags_great_adventure',
  'six_flags_great_america',
  'six_flags_over_georgia',
  'six_flags_fiesta_texas',
  'six_flags_over_texas',
];

sfParks.forEach(parkId=>{
  const i18nPath=path.join(i18nDir,parkId+'.json');
  const dataPath=path.join(dataDir,parkId,'hotels.json');
  
  if(!fs.existsSync(i18nPath)||!fs.existsSync(dataPath)){
    console.log('Missing files for',parkId);
    return;
  }
  
  const i18n=readJson(i18nPath);
  const hotelsData=readJson(dataPath);
  
  // For each hotel in the data file, add rooms translations to i18n
  hotelsData.forEach(hotel=>{
    const hId=hotel.id;
    if(!i18n.hotels[hId]){
      i18n.hotels[hId]={desc:{en:hotel.description||''}};
    }
    if(!i18n.hotels[hId].rooms){
      i18n.hotels[hId].rooms={};
    }
    
    hotel.rooms.forEach(room=>{
      const rKey=room.key;
      if(!i18n.hotels[hId].rooms[rKey]){
        // Look up translation by key
        const nameT=sfRooms.names[rKey]||{en:room.name};
        const descT=sfRooms.descs[rKey]||{en:room.description||''};
        i18n.hotels[hId].rooms[rKey]={
          name:nameT,
          desc:descT
        };
      }
    });
  });
  
  fs.writeFileSync(i18nPath,JSON.stringify(i18n,null,2),'utf8');
  console.log(parkId+': rooms translations added');
});

// ─── 3. ALTON TOWERS: check food translations ─────────────────────────────────
const atPath=path.join(i18nDir,'altontowers.json');
const at=readJson(atPath);
const atFoodData=readJson(path.join(dataDir,'altontowers','food.json'));

// Check which food items are missing desc
atFoodData.forEach(f=>{
  if(!at.food[f.id]){
    at.food[f.id]={desc:{en:f.description||f.name}};
    console.log('Alton Towers: added food translation for',f.id);
  }
});
fs.writeFileSync(atPath,JSON.stringify(at,null,2),'utf8');

console.log('\nAll done!');
