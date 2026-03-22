import 'dart:convert';
import 'package:http/http.dart' as http;

class AiAssistantService {
  static const String _functionUrl =
      'https://askparkassistant-jkbo5jibja-uc.a.run.app';

  static Future<String> ask({
    required String question,
    required String parkName,
    required String parkWebsite,
    List<Map<String, dynamic>>? attractions,
    List<Map<String, dynamic>>? restaurants,
    List<Map<String, dynamic>>? hotels,
  }) async {
    final parkData = {
      'attractions': attractions ?? [],
      'restaurants': restaurants ?? [],
      'hotels': hotels ?? [],
    };

    final response = await http.post(
      Uri.parse(_functionUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'question': question,
        'parkName': parkName,
        'parkWebsite': parkWebsite,
        'parkData': parkData,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['answer'] ?? 'No response received.';
    } else {
      throw Exception('Failed to get AI response: ${response.statusCode}');
    }
  }
}