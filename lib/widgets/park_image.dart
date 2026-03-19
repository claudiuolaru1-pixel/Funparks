import 'package:flutter/material.dart';
import '../services/image_url_service.dart';

/// Smart image widget that resolves asset paths to network URLs when
/// Firebase Storage is enabled, otherwise loads from local assets.
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
      return Image.network(
        resolved,
        fit: fit,
        width: width,
        height: height,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: Colors.black12,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (_, __, ___) => _placeholder(),
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