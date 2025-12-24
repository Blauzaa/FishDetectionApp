import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class ImageService {
  static final Dio _dio = Dio();
  static const MethodChannel _mediaScannerChannel =
      MethodChannel('media_scanner_channel');

  // ---  Minta izin akses penyimpanan ---
  static Future<bool> _requestPermission() async {
    PermissionStatus status;
    if (Platform.isAndroid) {
      status = await Permission.photos.request();
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
    } else {
      status = await Permission.photos.request();
    }
    if (kDebugMode) {
      print("Status izin: $status");
    }
    return status.isGranted || status.isLimited;
  }

  // ---  Simpan bytes ke galeri ---
  static Future<bool> saveBytesToGallery(Uint8List imageBytes) async {
    try {
      final bool hasPermission = await _requestPermission();
      if (!hasPermission) {
        throw Exception("Izin untuk mengakses galeri ditolak oleh pengguna.");
      }

      // Folder tujuan di galeri
      const String folderPath = '/storage/emulated/0/Pictures/FishDetection';
      final dir = Directory(folderPath);
      if (!(await dir.exists())) {
        await dir.create(recursive: true);
      }

      // Nama file unik
      final String fileName =
          'detection_${DateTime.now().millisecondsSinceEpoch}.png';
      final String fullPath = '$folderPath/$fileName';
      final file = File(fullPath);
      await file.writeAsBytes(imageBytes);

      // Trigger MediaScanner agar muncul di galeri
      await _mediaScannerChannel.invokeMethod('scanFile', {'path': fullPath});

      if (kDebugMode) {
        print('✅ Gambar berhasil disimpan: $fullPath');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saat menyimpan gambar: $e');
      }
      return false;
    }
  }

  // ---  Download dari URL dan langsung simpan ke galeri ---
  static Future<bool> downloadUrlToGallery(String url) async {
    try {
      final Response response = await _dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final Uint8List imageBytes = Uint8List.fromList(response.data);
      return await saveBytesToGallery(imageBytes);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saat download dari URL: $e');
      }
      return false;
    }
  }

  // ---  Bagikan gambar dari bytes ---
  static Future<void> shareBytes(Uint8List imageBytes, String text) async {
    try {
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/image_to_share.png';
      final file = File(imagePath);
      await file.writeAsBytes(imageBytes);

      if (!await file.exists()) {
        throw Exception("File temporer gagal dibuat.");
      }

      await Share.shareXFiles([XFile(imagePath)], text: text);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error di shareBytes: $e');
      }
      throw Exception('Gagal membagikan gambar.');
    }
  }

  // ---  Bagikan gambar dari URL ---
  static Future<void> shareUrl(String url, String text) async {
    try {
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/image_to_share.png';
      await Dio().download(url, imagePath);

      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception("File temporer gagal di-download.");
      }

      await Share.shareXFiles([XFile(imagePath)], text: text);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error di shareUrl: $e');
      }
      throw Exception('Gagal membagikan gambar.');
    }
  }
}
