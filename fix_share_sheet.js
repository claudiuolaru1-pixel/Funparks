const fs=require('fs');
let c=fs.readFileSync('lib/screens/park_detail_screen.dart','utf8');

// Add image_picker import if not present
if(!c.includes('image_picker')){
  c=c.replace(
    "import 'package:share_plus/share_plus.dart';",
    "import 'package:share_plus/share_plus.dart';\nimport 'package:image_picker/image_picker.dart';"
  );
}

// Replace simple park share with sheet call
c=c.replace(
  "onPressed: () => Share.share('${park.name} - Theme Park Guide\\nDiscover attractions, food, hotels and more on Funparks!')",
  "onPressed: () => _showParkShareSheet(context, park)"
);

// Add _showParkShareSheet method before the closing of _ParkDetailScreenState
// Find a good insertion point - before "class _AttractionDetailScreenState"
const method = `
  void _showParkShareSheet(BuildContext context, Park park) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Share park info'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await Share.share('\${park.name} - Theme Park Guide\\nDiscover attractions, food, hotels and more on Funparks!');
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Share a photo from your visit'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    await Share.shareXFiles([image], text: '\${park.name} - Funparks');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam_outlined),
                title: const Text('Share a video from your visit'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final XFile? video = await ImagePicker().pickVideo(source: ImageSource.gallery);
                  if (video != null) {
                    await Share.shareXFiles([video], text: '\${park.name} - Funparks');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
`;

c=c.replace(
  'class _AttractionDetailScreenState',
  method + '\nclass _AttractionDetailScreenState'
);

fs.writeFileSync('lib/screens/park_detail_screen.dart',c,'utf8');
console.log('Share sheet added:', c.includes('_showParkShareSheet'));
console.log('image_picker imported:', c.includes('image_picker'));