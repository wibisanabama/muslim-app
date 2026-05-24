import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodel/quran_view_model.dart';
import 'quran_detail_page.dart';
import 'muslim_drawer.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(context.read<QuranViewModel>().fetchSurahs());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _normalizeString(String str) {
    return str.toLowerCase().replaceAll(RegExp(r"[^a-z0-9]"), "");
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<QuranViewModel>();
    final theme = Theme.of(context);

    final filteredSurahs = vm.surahs.where((s) {
      final normQuery = _normalizeString(_searchQuery);
      if (normQuery.isEmpty) return true;

      final normNamaLatin = _normalizeString(s.namaLatin);
      final normNama = s.nama.toLowerCase();
      final normQueryArabic = _searchQuery.toLowerCase();

      return normNamaLatin.contains(normQuery) ||
          normNama.contains(normQueryArabic);
    }).toList();

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
        backgroundColor: _isScrolled
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: Container(
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(24),
          ),
          child: TextField(
            controller: _searchController,
            textAlignVertical: TextAlignVertical.center,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Cari surah...',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer.withValues(
                  alpha: 0.6,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              isDense: true,
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 16.0),
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
        onRefresh: () => context.read<QuranViewModel>().fetchSurahs(),
        child: Builder(
          builder: (context) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (vm.error != null) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Gagal memuat data:\n${vm.error}',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: () => context
                                    .read<QuranViewModel>()
                                    .fetchSurahs(),
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }

            if (vm.surahs.isEmpty) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(child: const Text('Data kosong')),
                    ),
                  );
                },
              );
            }

            if (filteredSurahs.isEmpty) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: theme.colorScheme.secondary.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Surah "$_searchQuery" tidak ditemukan',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }

            final mainList = ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: filteredSurahs.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: theme.colorScheme.surface,
                thickness: 1.5,
              ),
              itemBuilder: (context, i) {
                final s = filteredSurahs[i];
                final isFirst = i == 0;
                final isLast = i == filteredSurahs.length - 1;

                final borderRadius = BorderRadius.only(
                  topLeft: Radius.circular(isFirst ? 16 : 0),
                  topRight: Radius.circular(isFirst ? 16 : 0),
                  bottomLeft: Radius.circular(isLast ? 16 : 0),
                  bottomRight: Radius.circular(isLast ? 16 : 0),
                );

                final String place = s.tempatTurun == 'Mekah'
                    ? 'Mekah'
                    : 'Madinah';
                final String versesTag = 'Ayat';

                return Material(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.25,
                  ),
                  borderRadius: borderRadius,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuranDetailPage(
                            nomorSurah: s.nomor,
                            namaLatin: s.namaLatin,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              s.nomor.toString(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.namaLatin,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$place • ${s.jumlahAyat} $versesTag',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Text(
                            s.nama,
                            style: GoogleFonts.scheherazadeNew(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.8),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );

            if (_searchQuery.isNotEmpty) {
              return mainList;
            }

            final hasLastRead = vm.lastReadSurah != null;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card.filled(
                  margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: hasLastRead
                        ? () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuranDetailPage(
                                  nomorSurah: vm.lastReadSurah!,
                                  namaLatin: vm.lastReadSurahName ?? '',
                                  initialAyahNumber: vm.lastReadAyah,
                                ),
                              ),
                            );
                          }
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.18,
                              ),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.bookmark_added_rounded,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            hasLastRead
                                ? 'Surah ${vm.lastReadSurahName}, Ayat ${vm.lastReadAyah}'
                                : 'Belum ada riwayat baca',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(child: mainList),
              ],
            );
          },
        ),
      ),
    );
  }
}
