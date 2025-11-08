import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fish_detection_v2/services/firebase_service.dart';
import 'package:fish_detection_v2/services/image_service.dart';
import 'package:fish_detection_v2/widgets/error_dialog.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
class HistoryDetailScreen extends StatefulWidget {
  final String userId;
  final String historyId;

  const HistoryDetailScreen({
    super.key,
    required this.userId,
    required this.historyId,
  });

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {

  bool _isProcessingAction = false;
  String? _imageUrl;
  String _shareText = 'Hasil deteksi ikan.';

  Future<void> _deleteHistory(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus History'),
          content: const Text('Apakah Anda yakin ingin menghapus item ini?'),
          actions: <Widget>[
            TextButton(child: const Text('Batal'), onPressed: () => Navigator.of(context).pop(false)),
            TextButton(child: const Text('Hapus'), onPressed: () => Navigator.of(context).pop(true)),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await FirebaseService.deleteHistory(userId: widget.userId, historyId: widget.historyId);
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('History berhasil dihapus.')));
      } catch (e) {
        if (!mounted) return;
        showErrorDialog(context, 'Gagal menghapus:\n\n${e.toString()}');
      }
    }
  }

  Future<void> _downloadHistoryImage() async {
    if (_imageUrl == null) return;
    setState(() { _isProcessingAction = true; });
    try {
      final success = await ImageService.downloadUrlToGallery(_imageUrl!);
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

Future<void> _shareHistoryImage() async {
  if (_imageUrl == null) return;
  setState(() { _isProcessingAction = true; });
  try {
   
    final directory = await getTemporaryDirectory();
    final imagePath = '${directory.path}/image_to_share_history.png';
    
    await Dio().download(_imageUrl!, imagePath);

    final file = File(imagePath);
    if (!await file.exists()) throw Exception("File temporer gagal di-download.");

    await Share.shareXFiles([XFile(imagePath)], text: _shareText);

  } catch (e) {
    if (!mounted) return;
    showErrorDialog(context, 'Gagal membagikan gambar:\n\n${e.toString()}');
  } finally {
    if (mounted) setState(() { _isProcessingAction = false; });
  }
}
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail History'),
        actions: [
          if (_isProcessingAction)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3)),
            )
          else
            IconButton(
              icon: const Icon(Icons.download_outlined),
              onPressed: _imageUrl != null ? _downloadHistoryImage : null,
              tooltip: 'Download Gambar',
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteHistory(context),
            tooltip: 'Hapus History',
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseService.getHistoryDetail(widget.userId, widget.historyId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Data tidak ditemukan.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final Map<String, dynamic> recap = data['recapitulation'] ?? {};

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _imageUrl == null) {
              setState(() {
                _imageUrl = data['processed_image_url'];
                final String recapText = recap.entries.map((e) => '${e.key}: ${e.value}').join(', ');
                _shareText = 'Hasil deteksi ikan: $recapText. Dideteksi dengan Aplikasi FishDetection.';
              });
            }
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (data['processed_image_url'] != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(data['processed_image_url']),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withOpacity(0.5),
                          child: IconButton(
                            icon: const Icon(Icons.share, color: Colors.white),
                            onPressed: _isProcessingAction || _imageUrl == null ? null : _shareHistoryImage,
                            tooltip: 'Bagikan Hasil',
                          ),
                        ),
                      )
                    ],
                  ),
                const SizedBox(height: 20),
                DataTable(
                  columns: const [
                    DataColumn(label: Text('Jenis Ikan')),
                    DataColumn(label: Text('Jumlah')),
                  ],
                  rows: recap.entries.map((entry) {
                    return DataRow(cells: [
                      DataCell(Text(entry.key)),
                      DataCell(Text(entry.value.toString())),
                    ]);
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}