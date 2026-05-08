const fs=require('fs');
const raw=fs.readFileSync('assets/data/parks/gardaland/attractions.json','utf8');
const a=JSON.parse(raw.charCodeAt(0)===0xFEFF?raw.slice(1):raw);

const extra={
  oblivion_the_black_hole:{category:'thrill',topPick:true,rating:4.7,liveWaitMinutes:45,speedKmh:100,heightM:35,inversions:0,openedYear:2015,minHeightCm:140,temporarilyClosed:false,description:'A vertical drop coaster that plunges riders into a dark underground tunnel at high speed.'},
  raptor:{category:'thrill',topPick:true,rating:4.6,liveWaitMinutes:50,speedKmh:100,heightM:40,inversions:1,openedYear:2011,minHeightCm:140,temporarilyClosed:false,description:'A thrilling wing coaster where riders sit on the edge of the track with nothing above or below.'},
  blue_tornado:{category:'thrill',topPick:true,rating:4.5,liveWaitMinutes:40,speedKmh:95,heightM:30,inversions:6,openedYear:1996,minHeightCm:140,temporarilyClosed:false,description:'An inverted coaster with six inversions, delivering non-stop thrills through loops and corkscrews.'},
  sequoia_adventure:{category:'water',topPick:false,rating:4.3,liveWaitMinutes:35,speedKmh:null,heightM:null,inversions:null,openedYear:1998,minHeightCm:120,temporarilyClosed:false,description:'A classic log flume ride through a forest setting with a big splashdown finale.'},
  magic_mountain:{category:'thrill',topPick:false,rating:4.2,liveWaitMinutes:30,speedKmh:90,heightM:33,inversions:0,openedYear:1989,minHeightCm:130,temporarilyClosed:false,description:'A classic roller coaster and one of the park icons, offering speed and airtime.'},
  ortobruco_tour:{category:'family',topPick:false,rating:3.8,liveWaitMinutes:15,speedKmh:null,heightM:null,inversions:null,openedYear:2005,minHeightCm:null,temporarilyClosed:false,description:'A gentle tractor-themed ride through vegetable gardens, perfect for young children.'},
  fuga_da_atlantide:{category:'water',topPick:true,rating:4.4,liveWaitMinutes:40,speedKmh:null,heightM:null,inversions:null,openedYear:2001,minHeightCm:110,temporarilyClosed:false,description:'An immersive boat ride through the lost city of Atlantis ending in a massive water drop.'},
  kung_fu_panda:{category:'family',topPick:false,rating:4.0,liveWaitMinutes:20,speedKmh:null,heightM:null,inversions:null,openedYear:2016,minHeightCm:null,temporarilyClosed:false,description:'A 4D adventure with Po and friends from the Kung Fu Panda films.'},
  legoland_water:{category:'family',topPick:false,rating:3.7,liveWaitMinutes:10,speedKmh:null,heightM:null,inversions:null,openedYear:2010,minHeightCm:null,temporarilyClosed:false,description:'A colorful LEGO-themed water playground with splash zones for kids.'},
  fantasy_kingdom:{category:'family',topPick:false,rating:3.9,liveWaitMinutes:15,speedKmh:null,heightM:null,inversions:null,openedYear:2000,minHeightCm:null,temporarilyClosed:false,description:'A magical fantasy-themed area with gentle rides and entertainment for the whole family.'},
};

const updated=a.map(x=>Object.assign({},x,extra[x.id]||{}));
fs.writeFileSync('assets/data/parks/gardaland/attractions.json',JSON.stringify(updated,null,2),'utf8');
console.log('Done. Top picks:',updated.filter(x=>x.topPick).length);