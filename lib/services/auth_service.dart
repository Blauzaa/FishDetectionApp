import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> signInAnonymously() async {
    try {
      if (_auth.currentUser == null) {
        print('Belum ada user, mencoba login anonim...');
        await _auth.signInAnonymously();
        print("Login anonim berhasil dengan UID: ${_auth.currentUser?.uid}");
      } else {
        print('Sesi dipulihkan untuk UID: ${_auth.currentUser?.uid}');
      }
    } catch (e) {
      print("Gagal sign in secara anonim: $e");
    }
  }

  static String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
}