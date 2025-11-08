import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fish_detection_v2/services/api_service.dart'; 
import 'output_screen.dart';
import 'package:fish_detection_v2/widgets/error_dialog.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  double _confidenceThreshold = 0.3;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      showErrorDialog(context, 'Gagal memilih gambar:\n\n${e.toString()}');
    }
  }

  Future<void> _processImage() async {
    if (_imageFile == null) return;
    setState(() { _isLoading = true; });

    try {
      final result = await ApiService.processImage(
        imageFile: _imageFile!,
        confidenceThreshold: _confidenceThreshold,
      );
      
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => OutputScreen(
          originalImageFile: _imageFile!,
          apiResult: result,
        ),
      ));
    } catch (e) {
      if (!mounted) return;
      showErrorDialog(context, 'Gagal memproses gambar:\n\n${e.toString().replaceAll("Exception: ", "")}');
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

void _showThresholdInfoDialog(BuildContext context) {
  final theme = Theme.of(context);
  showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: theme.colorScheme.surface,

        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            Icon(Icons.info_outline, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                'Apa itu Confidence Threshold?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),

        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                'Threshold adalah batas keyakinan yang digunakan model sebelum menampilkan hasil deteksi.',
              ),
              SizedBox(height: 10),
              Text(
                'Semakin mendekati angka 1.0, model hanya akan menampilkan hasil yang benar-benar diyakini, lebih akurat tapi lebih sedikit.',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Text(
                'Semakin mendekati angka 0.1, model akan menampilkan lebih banyak hasil, tapi bisa saja ada yang tidak tepat.',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
            child: const Text('Mengerti'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            LayoutBuilder(
              builder: (context, constraints) {
               
                Widget buildResponsiveButton({
                  required VoidCallback onPressed,
                  required IconData icon,
                  required String label,
                }) {
                  return ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            label,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis, 
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (constraints.maxWidth < 320) { 
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildResponsiveButton(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: Icons.photo_library_outlined,
                        label: 'Pilih Gambar',
                      ),
                      const SizedBox(height: 12),
                      buildResponsiveButton(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: Icons.camera_alt_outlined,
                        label: 'Kamera',
                      ),
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      Expanded(
                        child: buildResponsiveButton(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: Icons.photo_library_outlined,
                          label: 'Pilih Gambar',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: buildResponsiveButton(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: Icons.camera_alt_outlined,
                          label: 'Kamera',
                        ),
                      ),
                    ],
                  );
                }
              },
            ),

            
            const SizedBox(height: 24),
            

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _imageFile == null
                    ? const Center(child: Text('Belum ada gambar dipilih.'))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_imageFile!, fit: BoxFit.contain),
                      ),
              ),
            ),
            const SizedBox(height: 24),

 
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Confidence Threshold: ${_confidenceThreshold.toStringAsFixed(2)}'),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.help_outline, color: Colors.grey[600]),
                      onPressed: () => _showThresholdInfoDialog(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Apa ini?',
                    ),
                  ],
                ),
                Slider(
                  value: _confidenceThreshold,
                  min: 0.1,
                  max: 0.9,
                  divisions: 8,
                  label: _confidenceThreshold.toStringAsFixed(2),
                  onChanged: (double value) {
                    setState(() {
                      _confidenceThreshold = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),


            Visibility(
              visible: !_isLoading,
              replacement: const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              child: ElevatedButton(
                onPressed: _imageFile != null ? _processImage : null,
                child: const Text('Proses'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}