import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fish_detection_v2/services/auth_service.dart';
import 'package:fish_detection_v2/services/firebase_service.dart';
import 'package:fish_detection_v2/screens/history_detail_screen.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = AuthService.getCurrentUserId();
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('History')),
        body: const Center(child: Text('Gagal mendapatkan ID pengguna.')),
      );
    }

return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseService.getHistoryStream(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada history.'));
          }

          final historyDocs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: historyDocs.length,
            itemBuilder: (context, index) {
              final doc = historyDocs[index];
              final data = doc.data() as Map<String, dynamic>;
              final Timestamp timestamp = data['timestamp'];
              final String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(timestamp.toDate());
              final Map<String, dynamic> recap = data['recapitulation'] ?? {};
              final String recapText = recap.entries.map((e) => '${e.key}: ${e.value}').join(', ');
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                clipBehavior: Clip.antiAlias, 
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: data['processed_image_url'] != null
                      ? Image.network(
                          data['processed_image_url'],
                          width: 60, height: 60, fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) => 
                            progress == null ? child : const SizedBox(width: 60, height: 60, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                          errorBuilder: (context, error, stack) =>
                            const SizedBox(width: 60, height: 60, child: Icon(Icons.error)),
                        )
                      : Container(width: 60, height: 60, color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported)),
                  ),
                  title: Text(
                    'Tanggal: $formattedDate',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: Text(
                    'Ikan: ${recapText.isEmpty ? "Tidak ada" : recapText}\nJumlah: ${data['total_detected']} Ikan',
                    style: TextStyle(color: Colors.grey.shade800, height: 1.4),
                  ),
                  onTap: () {
                     Navigator.of(context).push(MaterialPageRoute(builder: (_) => HistoryDetailScreen(userId: userId!, historyId: doc.id)));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}