import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fish_detection_v2/services/auth_service.dart';
import 'package:fish_detection_v2/services/firebase_service.dart';
import 'package:fish_detection_v2/services/cloudinary_service.dart';
import 'package:fish_detection_v2/services/image_service.dart';
import 'package:fish_detection_v2/widgets/error_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
class OutputScreen extends StatefulWidget {
  final File originalImageFile;
  final Map<String, dynamic> apiResult;

  const OutputScreen({
    super.key,
    required this.originalImageFile,
    required this.apiResult,
  });

  @override
  State<OutputScreen> createState() => _OutputScreenState();
}

class _OutputScreenState extends State<OutputScreen> {

  bool _isSaving = false;
  bool _isProcessingAction = false;
  final GlobalKey _imageKey = GlobalKey();


  Future<Uint8List> _renderWidgetToBytes() async {
    RenderRepaintBoundary boundary = _imageKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) throw Exception("Gagal merender gambar");
    return byteData.buffer.asUint8List();
  }

  Widget _buildRecapTable() {
    final List boxesData = widget.apiResult['boxes'] ?? [];
    final Map<String, dynamic> recap = widget.apiResult['recapitulation'] ?? {};
    final totalDetected = widget.apiResult['total_detected'] ?? 0;

    if (totalDetected == 0) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: Text('Tidak ada ikan yang terdeteksi.')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // Use stretch for full width
      children: [
        // BAGIAN 1: DETAIL SETIAP BOUNDING BOX DALAM BENTUK TABEL
        const Text(
          'Detail Deteksi:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        DataTable(
          columnSpacing: 20, // Adjust spacing between columns
          columns: const [
            DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Jenis Ikan', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Keyakinan', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: boxesData.asMap().entries.map((entry) {
            final int index = entry.key;
            final data = entry.value;
            final String label = data['label'];
            final double score = data['score'];
            final String confidence = '${(score * 100).toStringAsFixed(0)}%';

            return DataRow(cells: [
              DataCell(Text('${index + 1}')), // Column for the number
              DataCell(Text(label)),          // Column for the fish type
              DataCell(Text(confidence)),     // Column for the confidence score
            ]);
          }).toList(),
        ),

        const SizedBox(height: 24), // Spasi pemisah

        // BAGIAN 2: TOTAL REKAPITULASI (seperti sebelumnya)
        const Text(
          'Total Keseluruhan:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        DataTable(
          columns: const [
            DataColumn(label: Text('Jenis Ikan', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Jumlah Total', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: recap.entries.map((entry) {
            return DataRow(cells: [
              DataCell(Text(entry.key)),
              DataCell(Text(entry.value.toString())),
            ]);
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _saveHistory() async {
    setState(() { _isSaving = true; });
    try {
      final processedImageBytes = await _renderWidgetToBytes();
      final userId = AuthService.getCurrentUserId();
      if (userId == null) throw Exception("User tidak login");

      final originalImageUrl = await CloudinaryService.uploadFile(widget.originalImageFile);
      final processedImageFileName = 'processed_${DateTime.now().millisecondsSinceEpoch}.png';
      final processedImageUrl = await CloudinaryService.uploadBytes(processedImageBytes, processedImageFileName);

      await FirebaseService.saveHistory(
        userId: userId,
        originalImageUrl: originalImageUrl,
        processedImageUrl: processedImageUrl,
        recapitulation: Map<String, int>.from(widget.apiResult['recapitulation']),
        totalDetected: widget.apiResult['total_detected'],
      );
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('History berhasil disimpan!')));
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      showErrorDialog(context, 'Gagal menyimpan history:\n\n${e.toString()}');
    } finally {
      if (mounted) setState(() { _isSaving = false; });
    }
  }

  Future<void> _downloadImage() async {
    setState(() { _isProcessingAction = true; });
    try {
      final imageBytes = await _renderWidgetToBytes();
      final success = await ImageService.saveBytesToGallery(imageBytes);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gambar berhasil disimpan ke galeri!')));
      } else {
        throw Exception("Gagal menyimpan gambar.");
      }
    } catch (e) {
      if (!mounted) return;
      showErrorDialog(context, 'Gagal mengunduh gambar:\n\n${e.toString()}');
    } finally {
      if (mounted) setState(() { _isProcessingAction = false; });
    }
  }
Future<void> _shareImage() async {
  setState(() { _isProcessingAction = true; });
  try {
    final imageBytes = await _renderWidgetToBytes();
    final Map<String, dynamic> recap = widget.apiResult['recapitulation'] ?? {};
    final String recapText = recap.entries.map((e) => '${e.key}: ${e.value}').join(', ');
    final String shareText = 'Hasil deteksi ikan: $recapText. Dideteksi dengan Aplikasi FishDetection.';
    

    final directory = await getTemporaryDirectory();
    final imagePath = '${directory.path}/image_to_share_output.png';
    final file = File(imagePath);
    await file.writeAsBytes(imageBytes);

    if (!await file.exists()) throw Exception("File temporer gagal dibuat.");

    await Share.shareXFiles([XFile(imagePath)], text: shareText);

  } catch (e) {
    if (!mounted) return;
    showErrorDialog(context, 'Gagal membagikan gambar:\n\n${e.toString()}');
  } finally {
    if (mounted) setState(() { _isProcessingAction = false; });
  }
}
  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Output Deteksi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Gambar Hasil Deteksi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            RepaintBoundary(key: _imageKey, child: _buildImageWithBoxes()),
            const SizedBox(height: 24),
            Text('Rekapitulasi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryColor)),
            const SizedBox(height: 10),
            _buildRecapTable(),
            const SizedBox(height: 30),
            if (_isSaving || _isProcessingAction)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton.icon(
                    onPressed: _downloadImage,
                    icon: const Icon(Icons.download_outlined),
                    label: const Text('Download Gambar'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryColor),
                      foregroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _saveHistory,
                          icon: const Icon(Icons.save),
                          label: const Text('Simpan'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _shareImage,
                          icon: const Icon(Icons.share),
                          label: const Text('Bagikan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
Widget _buildImageWithBoxes() {
    final List boxesData = widget.apiResult['boxes'] ?? [];
    final Map<String, dynamic> originalSize = widget.apiResult['original_image_size'];
    final double originalWidth = originalSize['width'].toDouble();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double scaleX = constraints.maxWidth / originalWidth;
        final double scaleY = constraints.maxWidth / originalWidth;

        return Stack(
          children: [
            Image.file(widget.originalImageFile),
            // UBAH .map MENJADI .asMap().entries.map UNTUK MENDAPATKAN INDEX
            ...boxesData.asMap().entries.map((entry) { 
              final int index = entry.key;   // Ini adalah nomor urut (mulai dari 0)
              final data = entry.value;    // Ini adalah data kotak seperti sebelumnya

              final List<dynamic> box = data['box'];
              // Kita tidak butuh label dan score di sini lagi, tapi tetap bisa diambil jika perlu
              // final String label = data['label'];
              // final double score = data['score'];

              final double left = box[0] * scaleX;
              final double top = box[1] * scaleY;
              final double width = (box[2] - box[0]) * scaleX;
              final double height = (box[3] - box[1]) * scaleY;

              // TAMPILKAN NOMOR URUT (index + 1)
              return Positioned(
                left: left,
                top: top,
                width: width,
                height: height,
                child: Container(
                  decoration: BoxDecoration(border: Border.all(color: Colors.yellow, width: 2)), // Ganti warna agar beda
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      color: Colors.yellow.withOpacity(0.8),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text(
                        '${index + 1}', // Tampilkan nomor urut (1, 2, 3, ...)
                        style: const TextStyle(
                          color: Colors.black, 
                          fontSize: 12, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}