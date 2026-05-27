# Muslim App

Muslim App adalah aplikasi pendamping ibadah sehari-hari berbasis Flutter yang dirancang dengan penekanan pada kinerja tinggi, arsitektur bersih, sinkronisasi data cloud real-time, interaksi asisten cerdas (AI), serta penerapan standar keamanan tingkat produksi secara menyeluruh.

## Fitur Utama

- **Tanya Muslim AI**: Asisten kecerdasan buatan interaktif yang ditenagai oleh model Gemini 3.1 Flash Lite untuk menjawab pertanyaan seputar keislaman secara kontekstual. Fitur ini dilengkapi pembatasan input maksimal 2000 karakter per pesan, pembatasan 50 pesan per sesi percakapan, dan penonaktifan tombol kirim serta input keyboard selama pemuatan respons berlangsung untuk mencegah spamming.
- **Al-Quran Digital**: Teks Al-Quran lengkap dengan terjemahan bahasa Indonesia, mode membaca per halaman atau per ayat, ukuran teks dinamis, dan penanda bacaan terakhir (bookmark) yang tersinkronisasi.
- **Jadwal Shalat**: Informasi jadwal shalat harian yang akurat berbasis koordinat geografis pengguna dengan metode perhitungan regional yang dapat disesuaikan.
- **Arah Kiblat**: Pelacakan arah kiblat menggunakan sensor kompas internal perangkat secara dinamis dan presisi.
- **Catatan Ibadah**: Dashboard pencatatan aktivitas ibadah harian yang mencakup shalat fardhu (dengan transisi hari dinamis berbasis batas waktu shalat Subuh), catatan ceramah, dan catatan infaq harian.
- **Kumpulan Hadits**: Database hadits sahih dari perawi terkemuka yang dilengkapi dengan fitur pencarian.
- **Doa Harian**: Database doa sehari-hari lengkap dengan transliterasi, terjemahan, dan penyimpanan doa favorit.
- **Asmaul Husna**: Pembacaan interaktif 99 Nama Allah beserta arti dan transliterasi.
- **Tasbih Digital**: Penghitung zikir elektronik dengan dukungan umpan balik haptik (getaran).
- **Sinkronisasi Cloud Otomatis**: Sinkronisasi data dinamis (progres tadarus, riwayat shalat, ceramah, dan infaq) secara real-time ke Cloud Firestore yang otomatis aktif saat login dan terhapus secara sinkron saat logout.

## Arsitektur Sistem

Aplikasi ini mengimplementasikan pola arsitektur **MVVM (Model-View-ViewModel)** untuk menjaga pemisahan fungsionalitas secara terstruktur:

- **Model**: Menangani representasi data respons API, database lokal, serta skema integrasi dokumen Firestore.
- **View**: Menyajikan antarmuka pengguna yang dinamis, bersih, dan responsif menggunakan sistem tema material terintegrasi.
- **ViewModel**: Mengelola status aplikasi (state management) menggunakan paket **Provider**, memisahkan logika bisnis sepenuhnya dari lapisan antarmuka pengguna.

## Spesifikasi Teknologi

### Klien (Flutter)
- **Framework**: Flutter SDK (minimum SDK ^3.12.0)
- **Manajemen Status**: Provider
- **Penyimpanan Lokal**: SharedPreferences (untuk pengaturan/bookmarks) & Flutter Secure Storage (untuk enkripsi data sensitif klien)
- **Sensor Perangkat**: Geolocator (GPS), Geocoding (penerjemah koordinat), Flutter Compass (sensor kompas)
- **Presentasi Konten**: Flutter Markdown Plus (perenderan respons AI dengan format teks kaya)

### Backend & Layanan Cloud
- **Firebase Authentication**: Manajemen siklus autentikasi pengguna dengan integrasi Google Sign-In.
- **Cloud Firestore**: Database NoSQL real-time untuk penyimpanan data aktivitas ibadah pengguna.
- **Firebase Functions (V2)**: Backend Node.js server-side untuk menjebatani permintaan ke Generative Language API.
- **Gemini API**: Model Gemini 3.1 Flash Lite untuk pemrosesan asisten kecerdasan buatan.

## Lapisan Keamanan

### 1. Enkripsi Data Lokal
Informasi sensitif pengguna di sisi klien dilindungi menggunakan enkripsi berbasis perangkat keras melalui paket `flutter_secure_storage` untuk memitigasi risiko ekstraksi data secara ilegal dari media penyimpanan fisik perangkat.

### 2. Pengamanan API Key Gemini
API Key Gemini dipindahkan sepenuhnya dari kode sumber utama ke berkas konfigurasi lokal `lib/gemini_config.dart` yang tercantum dalam `.gitignore` untuk mencegah kebocoran kunci ke repositori publik. Di Google Cloud Console, API Key dibatasi hanya untuk package `id.muslimapp.app` dengan pembatasan akses khusus ke Generative Language API saja serta limitasi kuota harian.

### 3. Proxy Cloud Function (Node.js/V2)
Semua panggilan asisten AI dialihkan melalui Firebase Functions (V2) yang bertindak sebagai proxy penengah dengan menerapkan:
- **Autentikasi Firebase ID Token**: Memverifikasi token pengguna sebelum meneruskan permintaan ke Gemini API.
- **Restriksi CORS**: Menonaktifkan akses lintas domain (`cors: false`) untuk mencegah eksekusi fungsi dari domain eksternal.
- **Validasi Ukuran Payload**: Membatasi ukuran request body maksimal 100KB per permintaan untuk memitigasi serangan denial of service.
- **Rate Limiting Server-Side**: Membatasi request maksimal 30 permintaan per menit per pengguna terautentikasi berbasis memori internal untuk mencegah otomatisasi eksploitasi API.
- **Enforcement Prompt**: Instruksi sistem (*systemInstruction*) dikunci di level server untuk menjamin respons AI tetap fokus pada koridor keislaman ahlussunnah wal jama'ah dan tidak dapat dimanipulasi dari sisi klien.

### 4. Klien HTTP Aman (SafeHttpClient)
Semua permintaan eksternal ke domain API publik dienkapsulasi menggunakan `SafeHttpClient` kustom untuk menjamin stabilitas:
- **Batas Waktu Jaringan (Timeout)**: Membatasi durasi respons maksimal 10 detik.
- **Proteksi Out-Of-Memory (OOM)**: Membatasi ukuran aliran data transfer masuk maksimal 5MB, koneksi akan diputus secara paksa seketika jika melebihi batas.
- **TLS & Socket Exception Translator**: Mengonversi exception jabat tangan HTTPS (SSL handshake) dan kegagalan host menjadi pesan yang informatif bagi pengguna.
- **Retry Otomatis**: Melakukan upaya koneksi ulang hingga 3 kali menggunakan jeda waktu *exponential backoff* pada kegagalan koneksi transien.

### 5. SSL Pinning
Untuk melindungi aplikasi dari serangan Man-in-the-Middle (MitM), pin SHA-256 SPKI dari sertifikat SSL untuk domain API utama ditanamkan langsung pada berkas konfigurasi keamanan jaringan Android (`network_security_config.xml`).

### 6. Firestore Security Rules
Aturan keamanan database (`firestore.rules`) dikonfigurasi secara ketat untuk:
- Mengizinkan hak akses baca dan tulis hanya kepada pemilik dokumen terautentikasi (`request.auth.uid == userId`).
- Membatasi ukuran dokumen maksimal 1MB per dokumen (`request.resource.size < 1000000`) untuk mencegah eksploitasi kuota penyimpanan basis data.

## Memulai Proyek

### Instalasi Klien
1. Klon repositori ini:
   ```bash
   git clone https://github.com/wibisanabama/muslim-app.git
   cd muslim-app
   ```
2. Ambil seluruh dependensi proyek:
   ```bash
   flutter pub get
   ```
3. Buat berkas konfigurasi `lib/gemini_config.dart` secara lokal:
   ```dart
   class GeminiConfig {
     static const String apiKey = 'KUNCI_API_GEMINI_ANDA';
   }
   ```
4. Jalankan aplikasi dalam mode debug:
   ```bash
   flutter run
   ```

### Persiapan Rilis Android

#### 1. Pembuatan Keystore
Jalankan perintah berikut pada terminal Anda untuk menghasilkan berkas keystore penandatanganan rilis (`upload-keystore.jks`):
```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

#### 2. Konfigurasi Kredensial Lokal
Buat berkas lokal `android/key.properties` (secara otomatis diabaikan oleh Git):
```properties
storePassword=kata_sandi_keystore_anda
keyPassword=kata_sandi_kunci_anda
keyAlias=upload
storeFile=upload-keystore.jks
```

### Pengelolaan SSL Pinning
Untuk merotasi atau memperbarui pin SSL SPKI SHA-256 secara berkala:
1. Dapatkan pin publik SPKI aktif dari domain tujuan:
   ```bash
   openssl s_client -connect api.equran.id:443 -servername api.equran.id -showcerts < /dev/null | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
   ```
2. Tempatkan pin baru pada entri `<pin>` primer di `android/app/src/main/res/xml/network_security_config.xml`, pindahkan pin sebelumnya menjadi entri sekunder (backup).

## Standardisasi Kode

Proyek ini menjaga kepatuhan linter secara ketat. Sebelum melakukan komitmen perubahan kode, pastikan kode telah diformat dan diverifikasi bebas issue menggunakan perintah berikut:
```bash
dart format .
flutter analyze
```
