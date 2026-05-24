import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodel/language_view_model.dart';

class ApiListPage extends StatefulWidget {
  const ApiListPage({super.key});

  @override
  State<ApiListPage> createState() => _ApiListPageState();
}

class _ApiListPageState extends State<ApiListPage> {
  void _copyToClipboard(String text, String label, LanguageViewModel langVm) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                langVm.translate('$label disalin ke papan klip!', '$label copied to clipboard!'),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final langVm = context.watch<LanguageViewModel>();

    final List<Map<String, dynamic>> apis = [
      {
        'name': 'MyQuran API',
        'url': 'https://api.myquran.com',
        'icon': Icons.access_time_rounded,
        'description': langVm.translate(
          'Layanan API Jadwal Shalat terbaik di Indonesia yang terkalibrasi secara astronomis. Digunakan untuk pencarian koordinat kota/kabupaten serta pengambilan jadwal shalat bulanan presisi sesuai lokasi pengguna.',
          'The best Prayer Times API service in Indonesia, astronomically calibrated. Used to search for city/district coordinates and retrieve precise monthly prayer schedules according to the user\'s location.',
        ),
        'endpoints': [
          langVm.translate('GET /v2/sholat/kota/cari/{nama} - Mencari ID kota berdasarkan nama', 'GET /v2/sholat/kota/cari/{nama} - Search city ID by name'),
          langVm.translate('GET /v2/sholat/jadwal/{cityId}/{tahun}/{bulan} - Mengambil jadwal shalat bulanan', 'GET /v2/sholat/jadwal/{cityId}/{tahun}/{bulan} - Retrieve monthly prayer schedule'),
        ],
        'status': langVm.translate('Aktif', 'Active'),
        'isExpanded': false,
      },
      {
        'name': 'equran.id API',
        'url': 'https://equran.id',
        'icon': Icons.menu_book_rounded,
        'description': langVm.translate(
          'Digunakan untuk menyuplai seluruh data Al-Quran digital meliputi daftar surat, detail surat (ayat-ayat), audio murottal per ayat, serta terjemahan bahasa Indonesia dan transliterasi latin.',
          'Used to supply all digital Al-Quran data including list of surahs, surah details (verses), audio recitation per verse, as well as Indonesian translations and Latin transliteration.',
        ),
        'endpoints': [
          langVm.translate('GET /api/v2/surat - Mengambil daftar seluruh surat', 'GET /api/v2/surat - Retrieve list of all surahs'),
          langVm.translate('GET /api/v2/surat/{nomor} - Mengambil detail surat beserta ayatnya (v2)', 'GET /api/v2/surat/{nomor} - Retrieve surah details and its verses (v2)'),
          langVm.translate('GET /api/surat/{nomor} - Fallback detail surat (v1)', 'GET /api/surat/{nomor} - Fallback surah details (v1)'),
        ],
        'status': langVm.translate('Aktif', 'Active'),
        'isExpanded': false,
      },
      {
        'name': 'Ahmad Ramadhan Doa API',
        'url': 'https://doa-doa-api-ahmadramadhan.fly.dev',
        'icon': Icons.favorite_border_rounded,
        'description': langVm.translate(
          'Menyediakan kumpulan doa harian islami yang lengkap dengan teks Arab, transliterasi latin, terjemahan Indonesia, serta sumber sanad/riwayat doa.',
          'Provides a complete collection of daily Islamic prayers with Arabic text, Latin transliteration, Indonesian translation, and the chain of narrations/history of prayers.',
        ),
        'endpoints': [
          langVm.translate('GET /api - Mengambil seluruh daftar doa harian lengkap', 'GET /api - Retrieve full list of daily prayers'),
        ],
        'status': langVm.translate('Aktif', 'Active'),
        'isExpanded': false,
      },
      {
        'name': 'Asmaul Husna API',
        'url': 'https://asmaul-husna-api.vercel.app',
        'icon': Icons.brightness_5_rounded,
        'description': langVm.translate(
          'Penyedia data 99 Nama Baik Allah (Asmaul Husna) lengkap dengan penulisan Arab yang indah, ejaan latin, dan penjelasan makna mendalam dari setiap nama.',
          'Provider of 99 Beautiful Names of Allah (Asmaul Husna) complete with beautiful Arabic script, Latin spelling, and in-depth explanation of the meaning of each name.',
        ),
        'endpoints': [
          langVm.translate('GET /api/all - Mengambil 99 nama Asmaul Husna lengkap', 'GET /api/all - Retrieve 99 complete names of Asmaul Husna'),
        ],
        'status': langVm.translate('Aktif', 'Active'),
        'isExpanded': false,
      },
      {
        'name': 'Gading Hadith API',
        'url': 'https://api.hadith.gading.dev',
        'icon': Icons.bookmark_border_rounded,
        'description': langVm.translate(
          'API hadis terlengkap yang menyediakan kompilasi sanad dan matan hadis dari 9 kitab perawi hadis utama (Kutubut Tis\'ah) seperti Bukhari, Muslim, Abu Daud, dll.',
          'The most complete hadith API that provides compilations of sanad and matan hadith from 9 major hadith narrator books (Kutubut Tis\'ah) such as Bukhari, Muslim, Abu Daud, etc.',
        ),
        'endpoints': [
          langVm.translate('GET /books - Mengambil daftar kitab hadis beserta jumlah hadis', 'GET /books - Retrieve list of hadith books and hadith counts'),
          langVm.translate('GET /books/{bookId}?range={start}-{end} - Mengambil hadis dengan batasan range', 'GET /books/{bookId}?range={start}-{end} - Retrieve hadiths with range constraints'),
          langVm.translate('GET /books/{bookId}/{number} - Mengambil satu detail hadis spesifik', 'GET /books/{bookId}/{number} - Retrieve a specific hadith details'),
        ],
        'status': langVm.translate('Aktif', 'Active'),
        'isExpanded': false,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(langVm.translate('Daftar API', 'API Directory')),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          // Header Card
          Card.filled(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.cloud_sync_rounded,
                          color: theme.colorScheme.primary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              langVm.translate('Sumber Integrasi API', 'API Integration Sources'),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              langVm.translate('API Pihak Ketiga & Data Terbuka', 'Third-Party APIs & Open Data'),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    langVm.translate(
                      'Aplikasi Muslim beroperasi sepenuhnya secara dinamis dan real-time menggunakan layanan API pihak ketiga berikut untuk menyajikan data keagamaan yang valid dan akurat.',
                      'The Muslim application operates completely dynamically and in real-time using the following third-party API services to present valid and accurate religious data.',
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              langVm.translate('Daftar API yang Digunakan', 'List of APIs Used'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // API List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: apis.length,
            itemBuilder: (context, index) {
              final api = apis[index];
              final isExpanded = api['isExpanded'] as bool;
              final double bottomMargin = (index == apis.length - 1) ? 0.0 : 4.0;

              final BorderRadius borderRadius;
              if (apis.length == 1) {
                borderRadius = BorderRadius.circular(16.0);
              } else if (index == 0) {
                borderRadius = const BorderRadius.vertical(top: Radius.circular(16.0));
              } else if (index == apis.length - 1) {
                borderRadius = const BorderRadius.vertical(bottom: Radius.circular(16.0));
              } else {
                borderRadius = BorderRadius.zero;
              }

              return Padding(
                padding: EdgeInsets.only(bottom: bottomMargin),
                child: Card.filled(
                  margin: EdgeInsets.zero,
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: borderRadius,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Theme(
                    data: theme.copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      key: PageStorageKey<String>(api['name'] as String),
                      initiallyExpanded: isExpanded,
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.secondaryContainer,
                        child: Icon(
                          api['icon'] as IconData,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              api['name'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              api['status'] as String,
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        api['url'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20.0,
                            right: 20.0,
                            bottom: 20.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(height: 1),
                              const SizedBox(height: 16),
                              Text(
                                langVm.translate('Deskripsi Layanan:', 'Service Description:'),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                api['description'] as String,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Text(
                                    langVm.translate('Endpoints & Penggunaan:', 'Endpoints & Usage:'),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                    ),
                                    onPressed: () => _copyToClipboard(
                                      api['url'] as String,
                                      api['name'] as String,
                                      langVm,
                                    ),
                                    icon: const Icon(Icons.copy_rounded, size: 14),
                                    label: Text(
                                      langVm.translate('Salin URL', 'Copy URL'),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ...List.generate(
                                (api['endpoints'] as List<String>).length,
                                (i) {
                                  final endpoint = (api['endpoints'] as List<String>)[i];
                                  return Container(
                                    width: double.maxFinite,
                                    margin: const EdgeInsets.only(bottom: 6.0),
                                    padding: const EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(
                                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                                      ),
                                    ),
                                    child: Text(
                                      endpoint,
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 11.5,
                                        color: theme.colorScheme.onSurfaceVariant,
                                        height: 1.3,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
