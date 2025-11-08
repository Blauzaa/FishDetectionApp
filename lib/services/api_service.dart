import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://192.168.18.118:8080/predict';

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