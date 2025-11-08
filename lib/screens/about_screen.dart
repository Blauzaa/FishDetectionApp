import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});


  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {

      debugPrint('Tidak bisa membuka: $url');
    }
  }


  Widget _buildInteractiveInfo(
    BuildContext context, {
    required String label,
    required String value,
    required String type, 
  }) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () async {
        if (type == 'phone') {

          final cleanPhoneNumber = value.replaceAll(RegExp(r'[^0-9+]'), '');
          final whatsappUrl = "https://wa.me/$cleanPhoneNumber";
          final telUrl = "tel:$cleanPhoneNumber";

          try {
             if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
               await _launchUrl(whatsappUrl);
             } else {
               await _launchUrl(telUrl); 
             }
          } catch (e) {
             debugPrint("Error launching URL: $e");
          }

        } else if (type == 'email') {
          await _launchUrl("mailto:$value");
        }
      },
      onLongPress: () async {
        await Clipboard.setData(ClipboardData(text: value));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label disalin ke clipboard')),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade700)),
            const SizedBox(height: 4),
            Text(
              value,
              style: textTheme.bodyLarge?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                decorationColor: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Divider(color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }


  Widget _buildInfoField(BuildContext context, {required String label, required String value}) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final TextTheme textTheme = Theme.of(context).textTheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade700)),
          const SizedBox(height: 4),
          Text(value, style: textTheme.bodyLarge?.copyWith(color: primaryColor, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Divider(color: Colors.grey.shade300),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang Aplikasi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoField(context, label: 'Nama Aplikasi', value: 'FishSnap'), // Nama disesuaikan
            _buildInfoField(context, label: 'Versi', value: '1.0.0'),
            _buildInfoField(
              context,
              label: 'Deskripsi',
              value:
                  'FishSnap adalah aplikasi untuk mendeteksi, mengklasifikasi, dan menghitung jumlah ikan hias di dalam akuarium secara otomatis menggunakan teknologi Computer Vision.',
            ),
            
            const SizedBox(height: 16),

            _buildInfoField(context, label: 'Dikembangkan Oleh', value: 'Steven'),

            _buildInteractiveInfo(
              context,
              label: 'Kontak',
              value: '+62812345678901', 
              type: 'phone',
            ),

            _buildInteractiveInfo(
              context,
              label: 'Email',
              value: 'stevenstven21@gmail.com',
              type: 'email',
            ),

            _buildInfoField(context, label: 'Lisensi', value: '© 2025 Steven. All rights reserved.'),
          ],
        ),
      ),
    );
  }
}