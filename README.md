# Muslim App

Muslim App adalah aplikasi berbasis Flutter yang dirancang sebagai pendamping lengkap untuk ibadah sehari-hari. Aplikasi ini dibangun dengan penekanan pada kinerja tinggi, arsitektur bersih, implementasi keamanan tingkat lanjut, kemampuan sinkronisasi cloud, serta interaksi asisten berbasis kecerdasan buatan (AI).

## Fitur Utama

- **Tanya Muslim AI**: Asisten AI interaktif berbasis model Gemini 3.1 Flash Lite untuk menjawab pertanyaan keislaman secara kontekstual, terintegrasi dengan batasan keamanan ketat (maksimal 2000 karakter per pesan dan 50 pesan per sesi).
- **Al-Quran Digital**: Teks Al-Quran lengkap dengan terjemahan bahasa Indonesia, mode membaca per halaman atau per ayat, ukuran teks dinamis, dan penanda bacaan terakhir (bookmark) yang tersinkronisasi.
- **Jadwal Shalat**: Informasi jadwal shalat harian yang akurat berbasis koordinat geografis pengguna dengan metode perhitungan regional yang dapat disesuaikan.
- **Arah Kiblat**: Pelacakan arah kiblat menggunakan sensor kompas perangkat untuk penentuan arah secara presisi.
- **Catatan Ibadah**: Pencatatan riwayat ibadah harian yang mencakup shalat fardhu (dengan transisi hari dinamis berbasis batas waktu Subuh), catatan ceramah, dan catatan infaq harian.
- **Kumpulan Hadits**: Database hadits sahih dari perawi terkemuka yang dilengkapi dengan fitur pencarian.
- **Doa Harian**: Kumpulan doa sehari-hari lengkap dengan transliterasi, terjemahan, dan penyimpanan doa favorit.
- **Asmaul Husna**: Daftar 99 Nama Allah beserta arti dan transliterasi interaktif.
- **Tasbih Digital**: Penghitung zikir dengan dukungan umpan balik haptik.
- **Sinkronisasi Cloud**: Sinkronisasi data dinamis (progres tadarus, riwayat shalat, ceramah, dan infaq) secara real-time ke Cloud Firestore.

## Arsitektur Sistem

Aplikasi ini menggunakan pola arsitektur **MVVM (Model-View-ViewModel)** untuk pemisahan fungsionalitas yang terstruktur:

- **Model**: Mengelola representasi struktur data respons API, database lokal, serta skema sinkronisasi Firestore.
- **View**: Membangun antarmuka pengguna yang responsif, dinamis, dan bersih menggunakan sistem tema terintegrasi.
- **ViewModel**: Mengatur status aplikasi (state management) menggunakan paket **Provider**, memisahkan logika bisnis sepenuhnya dari lapisan antarmuka.

## Lapisan Keamanan

Aplikasi dan infrastruktur pendukungnya menerapkan standar keamanan industri untuk lingkungan produksi:

- **Enkripsi Penyimpanan Lokal**: Penggunaan penyimpanan terenkripsi (encrypted storage) menggunakan paket `flutter_secure_storage` untuk melindungi data sensitif pengguna di sisi klien.
- **Pembatasan API Key Gemini**: API Key dilindungi melalui konfigurasi eksternal (`lib/gemini_config.dart`) yang dikecualikan dari pelacakan Git (`.gitignore`). Akses kunci dibatasi di Google Cloud Console hanya untuk aplikasi Android ber-package `id.muslimapp.app` dengan batas kuota harian ketat.
- **Proxy Cloud Function Aman**: Implementasi endpoint proxy pada Firebase Functions (V2) untuk interaksi dengan Gemini API, mengimplementasikan:
  - Autentikasi ketat berbasis Firebase ID Token.
  - Pembatasan CORS untuk mencegah pemanggilan ilegal dari domain asing.
  - Pembatasan ukuran payload request (maksimal 100KB).
  - Rate limiting dinamis berbasis sliding window di level server (maksimal 30 request per menit per UID) untuk memitigasi serangan DDoS/abuse.
- **Klien HTTP Aman (SafeHttpClient)**: Klien HTTP kustom yang mengimplementasikan:
  - Batas waktu koneksi (timeout) maksimal 10 detik.
  - Proteksi Out-Of-Memory (OOM) dengan pemutusan koneksi otomatis jika ukuran data transfer melebihi 5MB.
  - Penanganan TLS exception secara aman.
  - Logika retry otomatis dengan mekanisme exponential backoff untuk koneksi tidak stabil.
- **SSL Pinning**: Proteksi terhadap serangan Man-in-the-Middle (MitM) melalui mekanisme SSL Pinning tingkat sistem yang dideklarasikan pada konfigurasi keamanan jaringan Android (`network_security_config.xml`).
- **Validasi Firestore**: Kebijakan keamanan aturan Firestore (`firestore.rules`) yang membatasi hak akses baca-tulis hanya kepada pemilik dokumen terautentikasi dan membatasi ukuran penulisan dokumen maksimal 1MB per dokumen.

## Spesifikasi Teknologi

- **Framework**: Flutter SDK
- **Bahasa**: Dart (Klien) & JavaScript/Node.js (Backend Cloud Functions)
- **Manajemen Status**: Provider
- **Penyimpanan**: SharedPreferences, Flutter Secure Storage
- **Layanan Cloud**: Firebase Authentication, Cloud Firestore, Firebase Cloud Functions
- **Layanan AI**: Generative Language API (Gemini 3.1 Flash Lite)

## Panduan Instalasi dan Pengujian

### Prasyarat
- Flutter SDK (versi stabil terbaru)
- Android Studio / Xcode
- Java Development Kit (JDK)
- Node.js & Firebase CLI (untuk pengelolaan backend)

### Instalasi Klien
1. Klon repositori:
   ```bash
   git clone https://github.com/wibisanabama/muslim-app.git
   cd muslim-app
   ```
2. Ambil dependensi pub:
   ```bash
   flutter pub get
   ```
3. Buat berkas `lib/gemini_config.dart` secara lokal untuk menyimpan API Key Gemini Anda:
   ```dart
   class GeminiConfig {
     static const String apiKey = 'KUNCI_API_GEMINI_ANDA';
   }
   ```
4. Jalankan aplikasi:
   ```bash
   flutter run
   ```

### Persiapan Rilis Android
1. Hasilkan berkas keystore penandatanganan:
   ```bash
   keytool -genkey -v -keystore android/app/upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Buat berkas `android/key.properties` untuk kredensial:
   ```properties
   storePassword=kata_sandi_keystore_anda
   keyPassword=kata_sandi_kunci_anda
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```

### Pengelolaan SSL Pinning
Untuk memperbarui pin SHA-256 SPKI secara berkala:
1. Dapatkan pin SPKI aktif melalui OpenSSL:
   ```bash
   openssl s_client -connect api.equran.id:443 -servername api.equran.id -showcerts < /dev/null | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
   ```
2. Perbarui pin baru pada tag `<pin>` primer di `android/app/src/main/res/xml/network_security_config.xml` dengan memindahkan pin sebelumnya sebagai backup.

### Standardisasi dan Kualitas Kode
Pastikan format dan analisis statis kode tetap mematuhi aturan standar sebelum melakukan commit:
```bash
dart format .
flutter analyze
```
