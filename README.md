# Fish Detection App (v2) - Thesis Project

## 📌 Deskripsi Proyek
Aplikasi ini adalah bagian dari proyek skripsi yang bertujuan untuk mendeteksi jenis ikan menggunakan teknologi Deep Learning. Aplikasi mobile ini dibangun menggunakan **Flutter** dan berfungsi sebagai antarmuka pengguna untuk mengambil atau mengunggah gambar ikan, yang kemudian diproses oleh server API untuk identifikasi spesies.

Proyek ini dirancang agar mudah dikembangkan atau digunakan kembali oleh peneliti atau mahasiswa selanjutnya yang ingin melanjutkan topik penelitian ini.

## 📂 Struktur Folder
Berikut adalah penjelasan singkat mengenai struktur folder utama dalam proyek ini:

*   **`lib/`**: Direktori utama kode sumber aplikasi Flutter.
    *   **`main.dart`**: Titik masuk (entry point) aplikasi.
    *   **`screens/`**: Berisi halaman-halaman antarmuka pengguna (UI), seperti `home_screen.dart`, `input_screen.dart`, `history_screen.dart`, dll.
    *   **`services/`**: Berisi logika bisnis dan komunikasi dengan layanan eksternal (API, Firebase, Cloudinary).
        *   `api_service.dart`: Menangani komunikasi HTTP ke server backend (Python).
        *   `auth_service.dart`: Menangani otentikasi pengguna (Firebase Auth).
        *   `cloudinary_service.dart`: Menangani unggah gambar ke Cloudinary.
    *   **`widgets/`**: Berisi komponen UI yang dapat digunakan kembali (reusable widgets).
*   **`assets/`**: Menyimpan aset statis seperti gambar atau ikon.
*   **`.env`**: File konfigurasi untuk menyimpan variabel lingkungan sensitif (tidak disertakan dalam repo, perlu dibuat manual).

## 🛠️ Teknologi yang Digunakan
*   **Frontend**: Flutter (Dart)
*   **Backend (API)**: Python (Flask/FastAPI - lihat repo API)
*   **Database & Auth**: Firebase (Firestore & Authentication)
*   **Cloud Storage**: Cloudinary (untuk penyimpanan gambar)
*   **HTTP Client**: `http` & `dio`

## 🔗 Repositori Terkait
Proyek ini terdiri dari tiga bagian utama yang saling terhubung. Pastikan Anda memeriksa repositori lainnya untuk pemahaman sistem secara keseluruhan:

1.  **Training (Model)**: [FishDetectionTrain](https://github.com/Blauzaa/FishDetectionTrain)
    *   Berisi kode untuk melatih model Deep Learning (misalnya YOLO, CNN, dll) untuk deteksi ikan.
2.  **API (Backend)**: [FishDetectionAPI](https://github.com/Blauzaa/FishDetectionAPI)
    *   Berisi kode server backend yang menghubungkan model hasil training dengan aplikasi mobile.
3.  **App (Mobile)**: [FishDetectionApp](https://github.com/Blauzaa/FishDetectionApp)
    *   Repositori ini, aplikasi mobile untuk pengguna akhir.

## 🚀 Persiapan Lingkungan (Environment Setup)

Sebelum menjalankan aplikasi, pastikan Anda telah menginstal:
1.  **Flutter SDK**: [Panduan Instalasi](https://docs.flutter.dev/get-started/install)
2.  **VS Code** atau **Android Studio** dengan ekstensi Flutter/Dart.
3.  **Git**.

### Langkah Instalasi
1.  **Clone Repositori ini**:
    ```bash
    git clone https://github.com/Blauzaa/FishDetectionApp.git
    cd FishDetectionApp
    ```

2.  **Instal Dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Konfigurasi Environment Variable**:
    Buat file bernama `.env` di direktori root proyek (sejajar dengan `pubspec.yaml`). Tambahkan konfigurasi berikut:
    ```env
    API_BASE_URL=http://<IP_ADDRESS_SERVER_ANDA>:5000/predict
    ```
    *   Ganti `<IP_ADDRESS_SERVER_ANDA>` dengan alamat IP tempat server API berjalan. Jika menjalankan lokal di emulator Android, biasanya gunakan `10.0.2.2`.

4.  **Konfigurasi Firebase**:
    *   Pastikan file `google-services.json` (Android) dan `GoogleService-Info.plist` (iOS) sudah ada di tempat yang sesuai jika Anda menghubungkan ke proyek Firebase baru.
    *   Jika menggunakan konfigurasi yang sudah ada, pastikan `firebase_options.dart` sudah sesuai.

## 📱 Cara Menggunakan (Usage)

Untuk menjalankan aplikasi dalam mode debug:

```bash
flutter run
```

Pastikan emulator sudah berjalan atau perangkat fisik sudah terhubung.

## 👤 Kontak / Penulis
Proyek ini dikembangkan sebagai tugas akhir skripsi. Jika ada pertanyaan, silakan hubungi pengembang melalui GitHub atau kontak yang tersedia.
