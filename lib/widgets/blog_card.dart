import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class BlogCard extends StatefulWidget {
  const BlogCard({super.key});
  @override
  State<BlogCard> createState() => _BlogCardState();
}

class _BlogCardState extends State<BlogCard> {
  Map<String, dynamic>? _post;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await http.get(
        Uri.parse('https://funparks.app/blog-posts.json'),
      ).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        if (list.isNotEmpty && mounted) {
          setState(() { _post = list[0] as Map<String, dynamic>; _loading = false; });
          return;
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox(height: 80, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    if (_post == null) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          final slug = _post!['slug'] as String? ?? '';
          final url = Uri.parse('https://funparks.app/blog/$slug');
          await launchUrl(url, mode: LaunchMode.externalApplication);
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF1a1a2e), Color(0xFF2d1b69)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.1),
                ),
                child: const Center(child: Text('🎢', style: TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: const Color(0xFFFF6B2B).withOpacity(0.2),
                      ),
                      child: Text(
                        (_post!['category'] as String? ?? 'Blog').toUpperCase(),
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFFFF6B2B), letterSpacing: 0.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _post!['title'] as String? ?? '',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white, height: 1.3),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _post!['excerpt'] as String? ?? '',
                      style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5), height: 1.4),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
