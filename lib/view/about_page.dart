import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            // Logo Aplikasi
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.menu_book,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Nama Aplikasi
            Center(
              child: Text(
                'Muslim',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Versi
            Center(
              child: Text(
                'Versi 1.0.0',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Deskripsi Aplikasi
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tentang Muslim',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Muslim adalah aplikasi penunjang ibadah harian umat Muslim yang dirancang dengan antarmuka yang bersih, responsif, dan mudah digunakan. Aplikasi ini dibangun sepenuhnya menggunakan arsitektur MVVM (Model-View-ViewModel) yang modular dan andal.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Fitur Utama
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        'Fitur Utama',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.secondaryContainer,
                        child: Icon(
                          Icons.access_time,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      title: const Text('Jadwal Shalat'),
                      subtitle: const Text('Jadwal shalat bulanan yang akurat sesuai lokasi.'),
                    ),
                    const Divider(indent: 72),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.secondaryContainer,
                        child: Icon(
                          Icons.menu_book,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      title: const Text('Al-Quran'),
                      subtitle: const Text('Daftar surat lengkap dengan teks Arab dan latin.'),
                    ),
                    const Divider(indent: 72),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.secondaryContainer,
                        child: Icon(
                          Icons.favorite_border,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      title: const Text('Doa Harian'),
                      subtitle: const Text('Kumpulan doa harian dengan fallback offline otomatis.'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Footer
            Center(
              child: Text(
                '© 2026 Muslim Team',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
