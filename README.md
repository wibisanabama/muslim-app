# Muslim App

Muslim App adalah aplikasi Flutter berkinerja tinggi, aman, dan memiliki estetika visual premium yang dirancang sebagai pendamping lengkap untuk ibadah sehari-hari. Dibangun dengan arsitektur bersih dan implementasi keamanan yang ketat, aplikasi ini menawarkan kemampuan luring (offline) yang tangguh serta interaksi pengguna yang mulus.

## Fitur Utama

- **Al-Quran Digital**: Al-Quran lengkap dengan terjemahan bahasa Indonesia, mode membaca per halaman atau per ayat, ukuran teks dinamis, dan akses cepat ke penanda ayat (bookmark).
- **Jadwal Shalat**: Jadwal shalat harian yang akurat berdasarkan data koordinat wilayah dengan berbagai metode perhitungan dan penyesuaian regional.
- **Arah Kiblat**: Pelacakan arah kiblat berbasis kompas yang akurat untuk menemukan arah kiblat di mana pun secara global.
- **Catatan Ramadhan**: Pencatatan aktivitas harian dan pelacakan target pribadi selama bulan suci Ramadhan.
- **Kumpulan Hadits**: Kumpulan hadits sahih dari berbagai perawi terkemuka dengan fitur pencarian yang mudah.
- **Doa Harian**: Database doa sehari-hari pilihan lengkap dengan terjemahan, transliterasi, dan bookmark kustom.
- **Asmaul Husna**: Pembacaan interaktif 99 Nama Allah beserta arti dan transliterasinya.
- **Tasbih Digital**: Penghitung zikir yang bersih dan intuitif dengan opsi umpan balik haptik (getaran).
- **Pengaturan & Gaya Dinamis**: Pilihan tema gelap dan terang yang elegan, transisi tata letak dinamis, dan fitur hapus data lokasi untuk privasi pengguna.

## Arsitektur

Proyek ini dibangun menggunakan pola arsitektur **MVVM (Model-View-ViewModel)** untuk menjaga pemisahan fungsi yang jelas:

- **Model**: Menangani struktur data respons API dan database lokal dengan aman.
- **View**: Membangun antarmuka pengguna yang indah, responsif, dan premium menggunakan sistem tema terintegrasi.
- **ViewModel**: Mengelola status (state management) secara bersih menggunakan paket **Provider**, memisahkan logika bisnis sepenuhnya dari lapisan presentasi.

## Keamanan Sistem

Codebase ini menerapkan praktik keamanan yang sangat ketat untuk rilis produksi:

- **Klien HTTP Aman (SafeHttpClient)**: Dibangun di atas paket HTTP bawaan untuk menegakkan:
  - **Batas Waktu Jaringan (Timeout)**: Membatasi durasi respons maksimal 10 detik untuk semua permintaan.
  - **Perlindungan Memori (OOM Protection)**: Memantau ukuran aliran data respons secara real-time dan langsung membatalkan koneksi jika total ukuran respons melebihi batas default (misalnya 5MB).
  - **Penerjemahan Exception TLS/Socket**: Penanganan exception jabat tangan HTTPS (SSL handshake) dan koneksi socket ke pesan yang ramah pengguna.
  - **Upaya Ulang dengan Exponential Backoff**: Melakukan retry otomatis hingga 3 kali pada transient connection error.
- **Network Security Configuration**: SSL Pinning sistem tingkat lanjut yang dikonfigurasi pada `network_security_config.xml` untuk domain API utama.
- **Pembersihan Log Rilis**: Penonaktifan seluruh operasional console logging secara otomatis pada mode rilis untuk mencegah kebocoran informasi sensitif.

## Teknologi Utama

- **SDK**: Flutter (Dart)
- **State Management**: Provider
- **Penyimpanan Lokal**: SharedPreferences / fallback ke aset lokal
- **Klien HTTP**: Custom BaseClient wrapper

## Memulai Proyek

### Prasyarat

Pastikan Anda telah memasang perangkat lunak berikut di mesin lokal Anda:
- Flutter SDK (versi 3.44.0 atau versi stabil terbaru)
- Android Studio / Xcode
- Java Development Kit (JDK)

### Instalasi

1. Klon repositori ini:
   ```bash
   git clone https://github.com/wibisanabama/muslim-app.git
   cd muslim-app
   ```

2. Ambil seluruh dependensi proyek:
   ```bash
   flutter pub get
   ```

3. Jalankan aplikasi dalam mode debug:
   ```bash
   flutter run
   ```

### Persiapan Rilis Android

#### Pembuatan Keystore

Untuk menghasilkan keystore penandatanganan rilis (`upload-keystore.jks`), jalankan perintah berikut di terminal Anda:
```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Buat berkas lokal `android/key.properties` (yang diabaikan oleh Git) dan tentukan kredensial keystore:
```properties
storePassword=kata_sandi_keystore_anda
keyPassword=kata_sandi_kunci_anda
keyAlias=upload
storeFile=upload-keystore.jks
```

*Catatan: Berkas android/key.properties dan android/app/upload-keystore.jks secara otomatis diabaikan oleh Git untuk mencegah kebocoran kunci rahasia.*

## Pengelolaan SSL Pinning

Aplikasi ini menggunakan kebijakan keamanan jabat tangan HTTPS yang ketat melalui Network Security Config dengan mekanisme SSL Pinning pada domain-domain API utama.

### Ekstraksi Pin SSL secara Manual

Untuk mendapatkan pin SPKI SHA-256 leaf dan intermediate dari chain aktif secara manual, Anda dapat menggunakan perintah openssl berikut:
```bash
openssl s_client -connect api.equran.id:443 -servername api.equran.id -showcerts < /dev/null | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
```

### Langkah Rotasi Sebelum Rilis
1. Verifikasi pin SPKI SHA-256 server tujuan menggunakan perintah openssl di atas.
2. Perbarui berkas `android/app/src/main/res/xml/network_security_config.xml`:
   - Tempatkan pin baru sebagai entri `<pin>` primer.
   - Pindahkan pin yang lama menjadi entri sekunder (backup) dalam tag `<pin-set>` untuk domain bersangkutan.
   - Perbarui atribut `expiration` sesuai dengan tanggal kedaluwarsa cert leaf aktual (berikan minimal 60 hari margin).
3. Validasi aplikasi secara lokal dan pastikan handshake SSL berhasil serta tidak terjadi gangguan koneksi sebelum mendistribusikan berkas APK rilis ke Play Store.

## Kualitas Kode dan Analisis

Repositori ini menjaga standar penulisan kode yang ketat. Untuk memverifikasi format dan analisis statis kode:

```bash
dart format .
flutter analyze
```
