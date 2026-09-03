# Muslim App

Aplikasi Flutter untuk membaca Al-Quran, melihat jadwal shalat, mencatat ibadah, dan mengakses asisten AI seputar Islam.

## Fitur

- Al-Quran dengan terjemahan Indonesia dan penanda bacaan terakhir.
- Jadwal shalat berdasarkan kota, dengan deteksi lokasi GPS atau pemilihan manual.
- Arah kiblat menggunakan lokasi dan sensor kompas.
- Doa harian, doa favorit, Asmaul Husna, serta pencarian dan penyimpanan hadits.
- Tasbih digital dengan umpan balik getaran.
- Catatan shalat, ceramah, dan infaq.
- Tanya jawab keislaman melalui Gemini API.
- Login Google, penyimpanan data pengguna di Firestore, serta tema terang dan gelap.

## Teknologi

- Flutter dan Dart.
- Provider untuk pengelolaan state.
- Firebase Authentication dan Cloud Firestore.
- SharedPreferences dan Flutter Secure Storage untuk penyimpanan lokal.
- MyQuran untuk jadwal shalat, EQuran untuk data Quran daring, dan Hadith Gading untuk hadits.

Quran, doa, dan Asmaul Husna mengutamakan data JSON lokal. Sinkronisasi Firestore dilakukan saat login dan perubahan data, bukan melalui listener real-time.

## Persyaratan

- Flutter dengan Dart SDK `>=3.12.0 <4.0.0`.
- Android SDK Platform 36 dan toolchain Android yang kompatibel dengan Flutter.
- Perangkat Android atau emulator. Fitur kiblat memerlukan sensor kompas.
- Project Firebase dengan Google Sign-In dan Cloud Firestore yang telah dikonfigurasi.
- API key Gemini untuk fitur AI.

Petunjuk berikut ditujukan untuk Android. Folder iOS tersedia, tetapi konfigurasi Firebase yang tercatat di repositori hanya mencakup Android.

## Instalasi

### 1. Unduh repositori

```bash
git clone https://github.com/wibisanabama/muslim-app.git
cd muslim-app
flutter pub get
```

### 2. Konfigurasi Firebase

Daftarkan aplikasi Android dengan package `id.muslimapp.app` pada project Firebase yang digunakan. Aktifkan penyedia login Google dan daftarkan sidik jari sertifikat penandatanganan aplikasi.

Siapkan file berikut dari konfigurasi project Firebase yang sama:

- `android/app/google-services.json` dari Firebase Console.
- `lib/firebase_options.dart` melalui FlutterFire CLI, dengan kelas `DefaultFirebaseOptions`.

Kedua file tersebut diabaikan oleh Git. Siapkan database Firestore dan aturan aksesnya sebelum menggunakan sinkronisasi akun. Konfigurasi deployment berada di `.firebaserc`, `firebase.json`, dan `firestore.rules`; sesuaikan dengan project Firebase yang digunakan.

### 3. Konfigurasi Gemini

Buat `lib/gemini_config.dart`:

```dart
class GeminiConfig {
  static const String apiKey = 'API_KEY_GEMINI_ANDA';
}
```

File ini diabaikan oleh Git. Implementasi chat saat ini mengakses Gemini langsung dari aplikasi. API key yang disertakan dalam aplikasi tetap dapat diekstrak dari hasil build.

Folder `functions/` berisi proxy Firebase Functions untuk Gemini, tetapi belum digunakan oleh klien Flutter.

### 4. Jalankan aplikasi

```bash
flutter run
```

Login menggunakan akun Google. Koneksi internet diperlukan untuk autentikasi, sinkronisasi, jadwal shalat, hadits, dan chat AI.

## Build Android

```bash
flutter build apk --release
```

APK dihasilkan di `build/app/outputs/flutter-apk/app-release.apk`.

Untuk penandatanganan rilis, siapkan keystore dan `android/key.properties` dengan properti `storePassword`, `keyPassword`, `keyAlias`, dan `storeFile`. Path `storeFile` relatif terhadap `android/app/`. Tanpa konfigurasi keystore, build release menggunakan debug key dan tidak ditujukan untuk publikasi.

## Struktur Proyek

- `lib/view/`: halaman dan komponen antarmuka.
- `lib/viewmodel/`: state dan logika aplikasi.
- `lib/repository/`: akses API, autentikasi, dan penyimpanan data.
- `lib/model/`: model data.
- `lib/constants/`: alamat API.
- `lib/utils/`: logging dan pemformatan error.
- `assets/`: data JSON dan ikon.
- `android/` dan `ios/`: konfigurasi platform.
- `functions/`: kode proxy Gemini berbasis Firebase Functions.

## Pemeriksaan Kode

```bash
dart format --output=none --set-exit-if-changed lib
flutter analyze
```
