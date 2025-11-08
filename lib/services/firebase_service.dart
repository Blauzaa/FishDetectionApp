

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final _firestore = FirebaseFirestore.instance;


  static Future<void> saveHistory({
    required String userId,
    required String originalImageUrl, // Terima URL sebagai String
    required String processedImageUrl, // Terima URL sebagai String
    required Map<String, int> recapitulation,
    required int totalDetected,
  }) async {
    final historyCollection = _firestore.collection('histories').doc(userId).collection('items');
    
    await historyCollection.add({
      'timestamp': FieldValue.serverTimestamp(),
      'original_image_url': originalImageUrl, // Simpan URL dari Cloudinary
      'processed_image_url': processedImageUrl, // Simpan URL dari Cloudinary
      'recapitulation': recapitulation,
      'total_detected': totalDetected,
    });
  }


  static Future<void> deleteHistory({required String userId, required String historyId}) async {

    await _firestore
        .collection('histories')
        .doc(userId)
        .collection('items')
        .doc(historyId)
        .delete();
  }


  static Stream<QuerySnapshot> getHistoryStream(String userId) {
    return _firestore
        .collection('histories')
        .doc(userId)
        .collection('items')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  static Future<DocumentSnapshot> getHistoryDetail(String userId, String historyId) {
     return _firestore
        .collection('histories')
        .doc(userId)
        .collection('items')
        .doc(historyId)
        .get();
  }
}