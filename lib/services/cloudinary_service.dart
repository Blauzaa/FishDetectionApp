import 'dart:io';
import 'dart:typed_data';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {

  static const String _cloudName = 'dpd1sayye';
  static const String _uploadPreset = 'fishdetection';

  static final CloudinaryPublic _cloudinary = CloudinaryPublic(
    _cloudName,
    _uploadPreset,
    cache: false,
  );

  // Fungsi untuk mengupload File (gambar asli)
  static Future<String> uploadFile(File file) async {
    try {
      final CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(file.path, resourceType: CloudinaryResourceType.Image),
      );
      return response.secureUrl; // Ini adalah URL yang akan disimpan
    } on CloudinaryException catch (e) {
      print('Error uploading file: ${e.message}');
      throw Exception('Gagal mengunggah gambar asli.');
    }
  }

  // Fungsi untuk mengupload Bytes (gambar hasil proses)
  static Future<String> uploadBytes(Uint8List bytes, String fileName) async {
    try {
      final CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(bytes,
            identifier: fileName, resourceType: CloudinaryResourceType.Image),
      );
      return response.secureUrl;
    } on CloudinaryException catch (e) {
      print('Error uploading bytes: ${e.message}');
      throw Exception('Gagal mengunggah gambar hasil proses.');
    }
  }
}