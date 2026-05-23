import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../model/shalat_schedule_response.dart';
import '../viewmodel/shalat_view_model.dart';
import 'kiblat_page.dart';
import 'asmaul_husna_page.dart';
import 'tasbih_page.dart';
import 'ramadhan_page.dart';
import 'hadis_page.dart';


import 'shalat_detail_page.dart';
import 'muslim_drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'quran_detail_page.dart';
import '../repository/quran_repository.dart';
import '../model/surah_detail.dart';
import 'dart:math';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ScrollController _scrollController;
  bool _isScrolled = false;
  Timer? _timer;

  bool _isLoadingQuote = true;
  Ayat? _randomAyat;
  int _quoteSurahNum = 94;
  String _quoteSurahName = 'Al-Insyirah';

  // Inline static fallback quote if offline/error (no helper file!)
  static final Ayat _fallbackAyat = Ayat(
    nomorAyat: 5,
    teksArab: "فَإِنَّ مَعَ الْعُسْرِ يُسْرًا", // Note: arab text
    teksLatin: "Fa inna ma'al-'usri yusrā",
    teksIndonesia: "Karena sesungguhnya sesudah kesulitan itu ada kemudahan.",
  );

  @override
  void initState() {
    super.initState();
    _fetchRandomQuote();
    _scrollController = ScrollController()
      ..addListener(() {
        final scrolled = _scrollController.offset > 0;
        if (scrolled != _isScrolled) {
          setState(() {
            _isScrolled = scrolled;
          });
        }
      });

    // Jalankan timer untuk mengupdate waktu mundur setiap detik
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });

    // Trigger fetch jadwal jika belum termuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ShalatViewModel>();
      if (vm.schedules.isEmpty && !vm.isLoading && !vm.isLoadingLocation) {
        vm.updateLocationAndFetchSchedule();
      }
    });
  }

  Future<void> _fetchRandomQuote() async {
    if (!mounted) return;
    setState(() {
      _isLoadingQuote = true;
    });

    try {
      // Pick a random surah number from 1 to 114
      final randomSurah = Random().nextInt(114) + 1;
      final quranRepo = QuranRepository();
      final surahDetail = await quranRepo.getSurahDetail(randomSurah);
      
      if (surahDetail.ayat.isNotEmpty && mounted) {
        final randomAyatIndex = Random().nextInt(surahDetail.ayat.length);
        setState(() {
          _randomAyat = surahDetail.ayat[randomAyatIndex];
          _quoteSurahNum = surahDetail.nomor;
          _quoteSurahName = surahDetail.namaLatin;
          _isLoadingQuote = false;
        });
        return;
      }
    } catch (_) {
      // Catch exceptions and fall back to local default quote
    }

    if (mounted) {
      setState(() {
        _randomAyat = _fallbackAyat;
        _quoteSurahNum = 94;
        _quoteSurahName = 'Al-Insyirah';
        _isLoadingQuote = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.watch<ShalatViewModel>();

    // Temukan shalat terdekat
    Map<String, String>? upcomingShalat;
    Duration? timeRemaining;
    ShalatDaySchedule? targetSchedule;
    ShalatDaySchedule? todaySchedule;
    ShalatDaySchedule? tomorrowSchedule;

    if (vm.schedules.isNotEmpty) {
      final now = DateTime.now();
      final todayDate = DateTime(now.year, now.month, now.day);
      final tomorrowDate = todayDate.add(const Duration(days: 1));


      for (final s in vm.schedules) {
        try {
          final parts = s.tanggal.split(', ');
          if (parts.length >= 2) {
            final dateParts = parts[1].split('/');
            if (dateParts.length >= 3) {
              final day = int.parse(dateParts[0]);
              final month = int.parse(dateParts[1]);
              final year = int.parse(dateParts[2]);
              final sDate = DateTime(year, month, day);
              if (sDate.isAtSameMomentAs(todayDate)) {
                todaySchedule = s;
              } else if (sDate.isAtSameMomentAs(tomorrowDate)) {
                tomorrowSchedule = s;
              }
            }
          }
        } catch (_) {}
      }

      // Deteksi waktu Isya hari ini
      DateTime? todayIsyaTime;
      if (todaySchedule != null) {
        try {
          final timeParts = todaySchedule.isya.split(':');
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);
          todayIsyaTime = DateTime(now.year, now.month, now.day, hour, minute);
        } catch (_) {}
      }

      final bool isAfterTodayIsya = todayIsyaTime != null && (now.isAfter(todayIsyaTime) || now.isAtSameMomentAs(todayIsyaTime));

      // Tentukan jadwal mana yang aktif untuk pencarian shalat mendatang
      final activeSchedule = isAfterTodayIsya ? tomorrowSchedule : todaySchedule;
      final activeDate = isAfterTodayIsya ? tomorrowDate : todayDate;

      if (activeSchedule != null) {
        targetSchedule = activeSchedule;
        final shalatItems = [
          {'name': 'Subuh', 'time': activeSchedule.subuh},
          {'name': 'Dzuhur', 'time': activeSchedule.dzuhur},
          {'name': 'Ashar', 'time': activeSchedule.ashar},
          {'name': 'Maghrib', 'time': activeSchedule.maghrib},
          {'name': 'Isya', 'time': activeSchedule.isya},
        ];

        List<Map<String, dynamic>> candidates = [];
        for (final item in shalatItems) {
          try {
            final timeStr = item['time']!;
            final timeParts = timeStr.split(':');
            final hour = int.parse(timeParts[0]);
            final minute = int.parse(timeParts[1]);
            final targetTime = DateTime(activeDate.year, activeDate.month, activeDate.day, hour, minute);

            if (targetTime.isAfter(now)) {
              candidates.add({
                'item': item,
                'dateTime': targetTime,
              });
            } else {
              // Kandidat hari berikutnya
              final tomorrowTime = targetTime.add(const Duration(days: 1));
              candidates.add({
                'item': {
                  'name': '${item['name']} (Besok)',
                  'time': item['time'],
                },
                'dateTime': tomorrowTime,
              });
            }
          } catch (_) {}
        }

        if (candidates.isNotEmpty) {
          candidates.sort((a, b) => (a['dateTime'] as DateTime).compareTo(b['dateTime'] as DateTime));
          final nextCandidate = candidates.first;
          upcomingShalat = Map<String, String>.from(nextCandidate['item'] as Map);
          timeRemaining = (nextCandidate['dateTime'] as DateTime).difference(now);
        }
      }
    }
    
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
        title: const Text('Muslim'),
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
      body: RefreshIndicator(
        onRefresh: () => context.read<ShalatViewModel>().updateLocationAndFetchSchedule(forceGPS: true),
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (vm.isLoading || vm.isLoadingLocation) ...[
              _buildLoadingCard(theme: theme),
            ] else if (upcomingShalat != null && timeRemaining != null && targetSchedule != null) ...[
              _buildUpcomingPrayerCard(
                context: context,
                theme: theme,
                cityName: vm.cityName,
                upcomingShalat: upcomingShalat,
                timeRemaining: timeRemaining,
                schedule: targetSchedule,
              ),
            ],

            
            // Catatan Ramadhan Card
            Card.filled(
              margin: EdgeInsets.zero,
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RamadhanPage(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary.withValues(alpha: 0.15),
                        ),
                        child: Icon(
                          Icons.event_note_rounded,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Catatan Ramadhan',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Pantau ibadah shalat, ceramah, dan infaq harian Anda.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Section Fitur Tambahan
            Padding(
              padding: EdgeInsets.zero,
              child: Text(
                'Fitur Tambahan',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Shortcuts Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Qibla Direction Shortcut
                  Expanded(
                    child: _buildShortcutItem(
                      context: context,
                      icon: Icons.explore,
                      label: 'Arah Kiblat',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const KiblatPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Asmaul Husna Shortcut
                  Expanded(
                    child: _buildShortcutItem(
                      context: context,
                      icon: Icons.brightness_5_rounded,
                      label: 'Asmaul Husna',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AsmaulHusnaPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Tasbih Shortcut
                  Expanded(
                    child: _buildShortcutItem(
                      context: context,
                      icon: Icons.fingerprint_rounded,
                      label: 'Tasbih',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TasbihPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Hadis Shortcut
                  Expanded(
                    child: _buildShortcutItem(
                      context: context,
                      icon: Icons.menu_book_rounded,
                      label: 'Hadis',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HadisPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),


            const SizedBox(height: 32),
            _buildQuoteCard(
              context: context,
              theme: theme,
              todaySchedule: todaySchedule,
              tomorrowSchedule: tomorrowSchedule,
            ),
          ],

        ),
      ),
    ),
    );
  }



  Widget _buildQuoteCard({
    required BuildContext context,
    required ThemeData theme,
    required ShalatDaySchedule? todaySchedule,
    required ShalatDaySchedule? tomorrowSchedule,
  }) {
    if (_isLoadingQuote) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    final ayat = _randomAyat ?? _fallbackAyat;
    final surahNum = _quoteSurahNum;
    final surahName = _quoteSurahName;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: theme.colorScheme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuranDetailPage(
                  nomorSurah: surahNum,
                  namaLatin: surahName,
                  initialAyahNumber: ayat.nomorAyat,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  ayat.teksArab,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.scheherazadeNew(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.8,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  ayat.teksLatin,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '"${ayat.teksIndonesia}"',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'QS. $surahName [$surahNum]: ${ayat.nomorAyat}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildUpcomingPrayerCard({

    required BuildContext context,
    required ThemeData theme,
    required String cityName,
    required Map<String, String> upcomingShalat,
    required Duration timeRemaining,
    required ShalatDaySchedule schedule,
  }) {
    final name = upcomingShalat['name']!;
    final cleanName = name.replaceAll(' (Besok)', '');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: theme.colorScheme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShalatDetailPage(schedule: schedule),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            height: 240,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _getShalatIcon(cleanName),
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  cleanName,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _formatDuration(timeRemaining),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    fontFamily: 'monospace',
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard({required ThemeData theme}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        height: 240,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Memuat Jadwal Terdekat',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Menyelaraskan koordinat GPS real-time...',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getShalatIcon(String name) {
    switch (name.toLowerCase()) {
      case 'subuh':
        return CupertinoIcons.sunrise;
      case 'dzuhur':
        return Icons.wb_sunny_rounded;
      case 'ashar':
        return Icons.wb_sunny_outlined;
      case 'maghrib':
        return CupertinoIcons.sunset;
      case 'isya':
        return Icons.nights_stay_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  Widget _buildShortcutItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Card.filled(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                padding: const EdgeInsets.all(8),
                alignment: Alignment.center,
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  child: Icon(
                    icon,
                    size: 24,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}



