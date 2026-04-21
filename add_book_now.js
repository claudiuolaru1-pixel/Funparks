const fs=require('fs');
const path='lib/screens/park_detail_screen.dart';
let c=fs.readFileSync(path,'utf8');

// Add Book Now button after the breakfast pill row inside each room card
const oldRow = `                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '\${r.pricePerNight.toStringAsFixed(0)} / night',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                          if (r.breakfastIncluded)
                            const _HotelActionPill(
                                icon: Icons.free_breakfast,
                                text: 'Breakfast'),
                        ],
                      ),`;

const newRow = `                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '\${r.pricePerNight.toStringAsFixed(0)} / night',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                          if (r.breakfastIncluded)
                            const _HotelActionPill(
                                icon: Icons.free_breakfast,
                                text: 'Breakfast'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF003580),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.hotel, size: 18),
                          label: const Text('Book Now',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                          onPressed: () async {
                            final query = Uri.encodeComponent(hotel.name);
                            final url = Uri.parse(
                              'https://www.booking.com/searchresults.html?aid=4347407&ss=\$query&checkin=&checkout=&group_adults=2&no_rooms=1&label=funparks-app',
                            );
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          },
                        ),
                      ),`;

if(c.includes(oldRow)){
  c=c.replace(oldRow, newRow);
  fs.writeFileSync(path,c,'utf8');
  console.log('Book Now button added to hotel room cards');
} else {
  console.log('Pattern not found - checking line endings');
  // Try with \r\n
  const oldRowCRLF = oldRow.replace(/\n/g,'\r\n');
  if(c.includes(oldRowCRLF)){
    c=c.replace(oldRowCRLF, newRow);
    fs.writeFileSync(path,c,'utf8');
    console.log('Book Now button added (CRLF)');
  } else {
    console.log('ERROR: could not find pattern');
  }
}