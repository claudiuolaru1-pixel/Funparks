// lib/screens/validate_json_assets.dart
import 'dart:convert';
import 'dart:io';

void main() {
  // Change this if your JSON lives elsewhere.
  const rootDir = 'assets';

  final dir = Directory(rootDir);
  if (!dir.existsSync()) {
    stderr.writeln('❌ Directory not found: $rootDir');
    exitCode = 2;
    return;
  }

  final jsonFiles = <File>[];
  for (final entity in dir.listSync(recursive: true, followLinks: false)) {
    if (entity is File && entity.path.toLowerCase().endsWith('.json')) {
      jsonFiles.add(entity);
    }
  }

  if (jsonFiles.isEmpty) {
    stdout.writeln('⚠️ No .json files found under $rootDir/');
    return;
  }

  stdout.writeln('Found ${jsonFiles.length} JSON files. Validating...\n');

  var failed = 0;

  for (final f in jsonFiles) {
    final path = f.path.replaceAll('\\', '/');

    try {
      final raw = f.readAsStringSync();

      // Strip UTF-8 BOM if present (sometimes breaks parsing)
      final text = raw.startsWith('\uFEFF') ? raw.substring(1) : raw;

      jsonDecode(text);
      stdout.writeln('✅ OK  $path');
    } on FormatException catch (e) {
      failed++;
      stdout.writeln('\n❌ FAIL $path');
      stdout.writeln('   ${e.message}');
      _printContextNearOffset(f, e.offset ?? 0, contextChars: 220);
    } catch (e) {
      failed++;
      stdout.writeln('\n❌ FAIL $path');
      stdout.writeln('   $e');
    }
  }

  stdout.writeln('\nDone. Failed: $failed');

  if (failed > 0) {
    exitCode = 1;
  }
}

void _printContextNearOffset(File f, int offset, {int contextChars = 200}) {
  try {
    final raw = f.readAsStringSync();
    final text = raw.startsWith('\uFEFF') ? raw.substring(1) : raw;

    final start = (offset - contextChars).clamp(0, text.length);
    final end = (offset + contextChars).clamp(0, text.length);

    final snippet = text.substring(start, end);
    stdout.writeln('   --- context (near offset $offset) ---');
    stdout.writeln(snippet);
    stdout.writeln('   ------------------------------\n');
  } catch (_) {
    // ignore
  }
}
