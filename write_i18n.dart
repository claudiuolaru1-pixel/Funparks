import 'dart:io';
import 'dart:convert';
void main() {
  final path = r'C:\Users\claud\OneDrive\Desktop\funparks_ids_set_to_com_funparks_app\assets\i18n\tokyo_disneyland.json';
  final f = File(path);
  // Read the existing mirabilandia.json as a template check
  print('Dart is working! Path: $path');
  print('File exists: ${f.existsSync()}');
}