// tool/validate_json_assets.dart
//
// Validates JSON assets and prints a friendly error with line/column + context.
// Run:
//   dart run tool/validate_json_assets.dart
//
// You can edit the list in _jsonFiles() to include all your JSON assets.

import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final files = _jsonFiles();

  if (files.isEmpty) {
    stdout.writeln('No JSON files configured to validate.');
    exitCode = 0;
    return;
  }

  var okCount = 0;
  var failCount = 0;

  stdout.writeln('Validating ${files.length} JSON file(s)...\n');

  for (final path in files) {
    final f = File(path);
    if (!f.existsSync()) {
      failCount++;
      stdout.writeln('❌ MISSING: $path');
      continue;
    }

    final content = f.readAsStringSync();

    try {
      jsonDecode(content);
      okCount++;
      stdout.writeln('✅ OK: $path');
    } on FormatException catch (e) {
      failCount++;
      stdout.writeln('\n❌ INVALID JSON: $path');
      stdout.writeln('   ${e.message}');

      final offset = e.offset;
      if (offset != null && offset >= 0 && offset <= content.length) {
        final lc = _lineColumnFromOffset(content, offset);
        stdout.writeln('   line: ${lc.$1}, column: ${lc.$2} (offset: $offset)');
        _printContextFromOffset(content, offset, contextLines: 4);
      } else {
        stdout.writeln('   (No offset information available)');
      }

      stdout.writeln('');
    } catch (e) {
      failCount++;
      stdout.writeln('\n❌ ERROR reading/parsing: $path');
      stdout.writeln('   $e\n');
    }
  }

  stdout.writeln('\nDone. OK=$okCount, FAIL=$failCount');
  exitCode = (failCount == 0) ? 0 : 2;
}

/// List JSON files you want to validate.
/// Add more here as you grow the project.
List<String> _jsonFiles() {
  return <String>[
    'assets/data/parks.json',
    'assets/data/portaventura/attractions.json',
    'assets/data/portaventura/food.json',
    'assets/data/portaventura/hotels.json',
    'assets/i18n/portaventura.json',
  ];
}

/// Returns (line, column) 1-based.
(int, int) _lineColumnFromOffset(String s, int offset) {
  var line = 1;
  var col = 1;

  // Clamp offset just in case.
  if (offset < 0) offset = 0;
  if (offset > s.length) offset = s.length;

  for (var i = 0; i < offset; i++) {
    final ch = s.codeUnitAt(i);
    if (ch == 10) {
      // '\n'
      line++;
      col = 1;
    } else {
      col++;
    }
  }
  return (line, col);
}

void _printContextFromOffset(String content, int offset,
    {int contextLines = 3}) {
  final lines = const LineSplitter().convert(content);

  // Convert offset->line index by counting '\n' before offset.
  var lineIndex = 0;
  for (var i = 0; i < offset && i < content.length; i++) {
    if (content.codeUnitAt(i) == 10) lineIndex++;
  }

  final start = (lineIndex - contextLines).clamp(0, lines.length - 1);
  final end = (lineIndex + contextLines).clamp(0, lines.length - 1);

  stdout.writeln('   --- context ---');
  for (var i = start; i <= end; i++) {
    final prefix = (i == lineIndex) ? '>>' : '  ';
    final number = (i + 1).toString().padLeft(4);
    stdout.writeln('   $prefix $number | ${lines[i]}');
  }
  stdout.writeln('   --------------');
}
