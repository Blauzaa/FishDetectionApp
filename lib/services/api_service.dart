import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final String _baseUrl = dotenv.env['API_BASE_URL']!;

  static Future<Map<String, dynamic>> processImage({
    required File imageFile,
    required double confidenceThreshold,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(bytes);

      final request = http.Request('POST', Uri.parse(_baseUrl));
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'image': base64Image,
        'confidence_threshold': confidenceThreshold,
      });

      final streamedResponse = await request.send().timeout(const Duration(seconds: 90));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Gagal memproses gambar. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error saat menghubungi API: $e');
    }
  }
}