class ImageUrlService {
  static const bool _useRemote = true;
  static const String _baseUrl =
      'https://firebasestorage.googleapis.com/v0/b/funparks-779c6.firebasestorage.app/o';

  static String resolve(String assetPath) {
    if (!_useRemote) return assetPath;
    if (assetPath.startsWith('http')) return assetPath;
    final stripped = assetPath.replaceFirst('assets/', '');
    final encoded = stripped.replaceAll('/', '%2F');
    return _baseUrl + '/' + encoded + '?alt=media';
  }
}