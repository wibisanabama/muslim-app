import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  late final ScrollController _scrollController;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        final scrolled = _scrollController.offset > 0;
        if (scrolled != _isScrolled) {
          setState(() {
            _isScrolled = scrolled;
          });
        }
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final features = [
      {
        'title': 'Jadwal Shalat',
        'subtitle': 'Jadwal shalat bulanan yang akurat sesuai lokasi.',
        'icon': Icons.access_time_rounded,
      },
      {
        'title': 'Al-Quran',
        'subtitle': 'Daftar surat lengkap dengan teks Arab dan latin.',
        'icon': Icons.menu_book_rounded,
      },
      {
        'title': 'Doa Harian',
        'subtitle': 'Kumpulan doa harian dengan fallback offline otomatis.',
        'icon': Icons.favorite_border_rounded,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        title: const Text('Tentang Aplikasi'),
        centerTitle: true,
        backgroundColor: _isScrolled
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              radius: 18,
              child: const Text(
                'A',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
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
            Card.filled(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
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
            const SizedBox(height: 24),
            // Fitur Utama
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
              child: Text(
                'Fitur Utama',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: features.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: theme.colorScheme.surface,
                thickness: 1.5,
              ),
              itemBuilder: (context, index) {
                final feature = features[index];
                final isFirst = index == 0;
                final isLast = index == features.length - 1;

                final borderRadius = BorderRadius.only(
                  topLeft: Radius.circular(isFirst ? 16 : 0),
                  topRight: Radius.circular(isFirst ? 16 : 0),
                  bottomLeft: Radius.circular(isLast ? 16 : 0),
                  bottomRight: Radius.circular(isLast ? 16 : 0),
                );

                return Material(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
                  borderRadius: borderRadius,
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.secondaryContainer,
                        child: Icon(
                          feature['icon'] as IconData,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      title: Text(
                        feature['title'] as String,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        feature['subtitle'] as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                );
              },
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
