const fs=require('fs');

// 1. Add cached_network_image to pubspec.yaml
const pubspec = fs.readFileSync('pubspec.yaml','utf8');
if(!pubspec.includes('cached_network_image')){
  const updated = pubspec.replace(
    'audioplayers: ^6.1.0',
    'audioplayers: ^6.1.0\n  cached_network_image: ^3.4.1'
  );
  fs.writeFileSync('pubspec.yaml', updated, 'utf8');
  console.log('pubspec updated');
} else {
  console.log('cached_network_image already in pubspec');
}

// 2. Replace ParkImage widget to use cached images
const parkImage = `import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/image_url_service.dart';

class ParkImage extends StatelessWidget {
  final String image;
  final BoxFit fit;
  final double? width;
  final double? height;
  final int? cacheWidth;

  const ParkImage({
    super.key,
    required this.image,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.cacheWidth,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = ImageUrlService.resolve(image);
    final isNetwork = resolved.startsWith('http');

    if (isNetwork) {
      return CachedNetworkImage(
        imageUrl: resolved,
        fit: fit,
        width: width,
        height: height,
        placeholder: (context, url) => Container(
          color: Colors.black12,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (_, __, ___) => _placeholder(),
      );
    }

    return Image.asset(
      resolved,
      fit: fit,
      width: width,
      height: height,
      cacheWidth: cacheWidth,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() => Container(
        color: Colors.black12,
        child: const Center(
          child: Icon(Icons.image_not_supported, color: Colors.white54, size: 32),
        ),
      );
}
`;
fs.writeFileSync('lib/widgets/park_image.dart', parkImage, 'utf8');
console.log('ParkImage widget updated with caching');