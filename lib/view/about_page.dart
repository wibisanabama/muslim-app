import 'package:flutter/material.dart';
import 'auth_dialogs.dart';

class AboutPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const AboutPage({super.key, required this.scaffoldKey});

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

    final additionalFeatures = [
      {
        'title': 'Arah Kiblat',
        'subtitle':
            'Menemukan arah kiblat secara akurat menggunakan sensor perangkat.',
        'icon': Icons.explore,
      },
      {
        'title': 'Asmaul Husna',
        'subtitle':
            '99 Nama Allah lengkap dengan teks Arab, latin, dan maknanya dari live API.',
        'icon': Icons.brightness_5_rounded,
      },
      {
        'title': 'Tasbih Digital',
        'subtitle':
            'Penghitung tasbih digital dengan antarmuka yang bersih untuk berdzikir.',
        'icon': Icons.fingerprint_rounded,
      },
      {
        'title': 'Hadis Nabawi',
        'subtitle':
            'Kumpulan hadis dari 9 kitab hadis utama dengan pencarian dinamis.',
        'icon': Icons.menu_book_rounded,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => widget.scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Tentang Aplikasi'),
        centerTitle: true,
        backgroundColor: _isScrolled
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          ProfileMonogram(scaffoldKey: widget.scaffoldKey),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),

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

            Center(
              child: Text(
                'Versi 1.0.0',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 32),

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
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

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
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.25,
                  ),
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

            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
              child: Text(
                'Fitur Tambahan',
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
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.25,
                  ),
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

            Card.filled(
              margin: EdgeInsets.zero,
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Informasi Keamanan & Data',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Aplikasi Muslim Modern dirancang dengan memprioritaskan keamanan, privasi data pengguna, dan fungsionalitas luring yang tangguh (offline-first).',
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                    ),
                    const Divider(height: 24),
                    Text(
                      'Cara Data Anda Dikelola secara Lokal:',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSecurityInfoItem(
                      theme: theme,
                      number: '1',
                      title: 'Log Nominal Infaq Terenkripsi',
                      description:
                          'Disimpan secara terenkripsi penuh menggunakan standar AES-256 pada kompartemen aman sistem (Keychain untuk iOS & Android KeyStore via FlutterSecureStorage).',
                    ),
                    const SizedBox(height: 12),
                    _buildSecurityInfoItem(
                      theme: theme,
                      number: '2',
                      title: 'Cache Lokasi & GPS Dinamis',
                      description:
                          'Hanya menyimpan nama kota pencarian shalat dan koordinat arah kiblat lokal yang dihitung secara dinamis. Koordinat GPS mentah Anda tidak pernah disimpan secara permanen demi privasi lokasi Anda.',
                    ),
                    const SizedBox(height: 12),
                    _buildSecurityInfoItem(
                      theme: theme,
                      number: '3',
                      title: 'Log Ibadah & Jurnal',
                      description:
                          'Jurnal ibadah shalat dan catatan ceramah disimpan secara terisolasi pada SharedPreferences lokal yang ter-sandbox di perangkat Anda.',
                    ),
                    const SizedBox(height: 12),
                    _buildSecurityInfoItem(
                      theme: theme,
                      number: '4',
                      title: 'Integritas Konten Offline',
                      description:
                          'Membaca data Al-Quran, Asmaul Husna, dan Doa terpopuler secara 100% luring untuk menghemat kuota. Integritas data diverifikasi secara mandiri di tingkat lokal.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            const Center(
              child: Text(
                '© 2026 Tim Muslim',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityInfoItem({
    required ThemeData theme,
    required String number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: Colors.white.withValues(alpha: 0.15),
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}