import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/language_view_model.dart';
import 'muslim_drawer.dart';

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
    final langVm = context.watch<LanguageViewModel>();

    final features = [
      {
        'title': langVm.translate('Jadwal Shalat', 'Prayer Schedule'),
        'subtitle': langVm.translate('Jadwal shalat bulanan yang akurat sesuai lokasi.', 'Accurate monthly prayer schedule based on your location.'),
        'icon': Icons.access_time_rounded,
      },
      {
        'title': langVm.translate('Al-Quran', 'Al-Quran'),
        'subtitle': langVm.translate('Daftar surat lengkap dengan teks Arab dan latin.', 'Complete list of surahs with Arabic and Latin text.'),
        'icon': Icons.menu_book_rounded,
      },
      {
        'title': langVm.translate('Doa Harian', 'Daily Prayers'),
        'subtitle': langVm.translate('Kumpulan doa harian dengan fallback offline otomatis.', 'Collection of daily prayers with automatic offline fallback.'),
        'icon': Icons.favorite_border_rounded,
      },
    ];

    final additionalFeatures = [
      {
        'title': langVm.translate('Arah Kiblat', 'Qibla Direction'),
        'subtitle': langVm.translate('Menemukan arah kiblat secara akurat menggunakan sensor perangkat.', 'Find Qibla direction accurately using device sensors.'),
        'icon': Icons.explore,
      },
      {
        'title': langVm.translate('Asmaul Husna', 'Asmaul Husna'),
        'subtitle': langVm.translate('99 Nama Allah lengkap dengan teks Arab, latin, dan maknanya dari live API.', '99 Beautiful Names of Allah with Arabic, Latin, and meaning from live API.'),
        'icon': Icons.brightness_5_rounded,
      },
      {
        'title': langVm.translate('Tasbih Digital', 'Digital Tasbih'),
        'subtitle': langVm.translate('Penghitung tasbih digital dengan antarmuka yang bersih untuk berdzikir.', 'Digital tasbih counter with clean interface for dhikr.'),
        'icon': Icons.fingerprint_rounded,
      },
      {
        'title': langVm.translate('Hadis Nabawi', 'Hadith Nabawi'),
        'subtitle': langVm.translate('Kumpulan hadis dari 9 kitab hadis utama dengan pencarian dinamis.', 'Collection of hadiths from 9 major hadith books with dynamic search.'),
        'icon': Icons.menu_book_rounded,
      },
    ];

    return Scaffold(
      drawer: const MuslimDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text(langVm.translate('Tentang Aplikasi', 'About Application')),
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
                langVm.translate('Versi 1.0.0', 'Version 1.0.0'),
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
                      langVm.translate('Tentang Muslim', 'About Muslim'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      langVm.translate(
                        'Muslim adalah aplikasi penunjang ibadah harian umat Muslim yang dirancang dengan antarmuka yang bersih, responsif, dan mudah digunakan. Aplikasi ini dibangun sepenuhnya menggunakan arsitektur MVVM (Model-View-ViewModel) yang modular dan andal.',
                        'Muslim is a daily worship support application for Muslims designed with a clean, responsive, and easy-to-use interface. This application is built entirely using the modular and reliable MVVM (Model-View-ViewModel) architecture.',
                      ),
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
                langVm.translate('Fitur Utama', 'Main Features'),
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
            const SizedBox(height: 24),
            // Fitur Tambahan
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
              child: Text(
                langVm.translate('Fitur Tambahan', 'Additional Features'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: additionalFeatures.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: theme.colorScheme.surface,
                thickness: 1.5,
              ),
              itemBuilder: (context, index) {
                final feature = additionalFeatures[index];
                final isFirst = index == 0;
                final isLast = index == additionalFeatures.length - 1;

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
                langVm.translate('© 2026 Tim Muslim', '© 2026 Muslim Team'),
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
