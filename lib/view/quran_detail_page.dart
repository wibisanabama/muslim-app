import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodel/quran_view_model.dart';

class QuranDetailPage extends StatefulWidget {
  final int nomorSurah;
  final String namaLatin;
  final int? initialAyahNumber;

  const QuranDetailPage({
    super.key,
    required this.nomorSurah,
    required this.namaLatin,
    this.initialAyahNumber,
  });

  @override
  State<QuranDetailPage> createState() => _QuranDetailPageState();
}

class _QuranDetailPageState extends State<QuranDetailPage> {
  late ScrollController _scrollController;
  late final QuranViewModel _quranVM;
  bool _isScrolled = false;
  bool _hasScrolledToInitial = false;
  bool _isScrollScheduled = false;
  final Map<int, GlobalKey> _ayahKeys = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScrollListener);
    
    _quranVM = context.read<QuranViewModel>();
    _quranVM.addListener(_scrollToInitialAyahListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _quranVM.fetchSurahDetail(widget.nomorSurah);
    });
  }

  void _onScrollListener() {
    final scrolled = _scrollController.offset > 0;
    if (scrolled != _isScrolled) {
      setState(() {
        _isScrolled = scrolled;
      });
    }
  }

  double _estimateAyahHeight(dynamic a) {
    final arabLines = (a.teksArab.length / 30.0).ceil();
    final arabHeight = arabLines * 64.0; // 32 * 2.0 = 64

    final latinLines = (a.teksLatin.length / 50.0).ceil();
    final latinHeight = latinLines * 20.0;

    final indoLines = (a.teksIndonesia.length / 60.0).ceil();
    final indoHeight = indoLines * 20.0;

    const staticHeight = 32.0 + 36.0 + 28.0 + 1.5; // padding + spacings + divider
    return arabHeight + latinHeight + indoHeight + staticHeight;
  }

  double _calculateEstimatedOffset(List<dynamic> ayatList, int targetAyahNumber) {
    double offset = 12.0; // padding top
    for (int i = 0; i < targetAyahNumber - 1; i++) {
      if (i < ayatList.length) {
        offset += _estimateAyahHeight(ayatList[i]);
      }
    }
    return offset;
  }

  void _scrollToInitialAyahListener() {
    if (widget.initialAyahNumber != null &&
        !_isScrollScheduled &&
        !_quranVM.isDetailLoading &&
        _quranVM.surahDetail != null &&
        _quranVM.surahDetail!.nomor == widget.nomorSurah) {
      _isScrollScheduled = true;

      final detail = _quranVM.surahDetail!;
      final estimatedOffset = _calculateEstimatedOffset(detail.ayat, widget.initialAyahNumber!);

      // Dispose controller lama dan buat baru dengan offset awal
      _scrollController.dispose();
      _scrollController = ScrollController(initialScrollOffset: estimatedOffset)
        ..addListener(_onScrollListener);

      // Setelah render frame pertama di offset awal, lakukan alignment presisi
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _doPreciseScroll();
      });
    }
  }

  void _doPreciseScroll() {
    if (!_scrollController.hasClients) return;

    final targetAyah = widget.initialAyahNumber!;
    final key = _ayahKeys[targetAyah];

    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: Duration.zero,
        alignment: 0.0,
      );
    }
    setState(() {
      _hasScrolledToInitial = true;
    });
  }

  @override
  void dispose() {
    _quranVM.removeListener(_scrollToInitialAyahListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<QuranViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.namaLatin),
        centerTitle: false,
        backgroundColor: _isScrolled
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Builder(
        builder: (context) {
          if (vm.isDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.detailError != null) {
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
                              'Gagal memuat detail surat:\n${vm.detailError}',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: () => context
                                  .read<QuranViewModel>()
                                  .fetchSurahDetail(widget.nomorSurah),
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

          final detail = vm.surahDetail;
          if (detail == null) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: const Center(
                      child: Text('Data detail tidak ditemukan'),
                    ),
                  ),
                );
              },
            );
          }

          final content = ListView.separated(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            // ignore: deprecated_member_use
            cacheExtent: 5000.0, // Large cache to guarantee target key registration
            itemCount: detail.ayat.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: theme.colorScheme.surface,
              thickness: 1.5,
            ),
            itemBuilder: (context, index) {
              final a = detail.ayat[index];
              final isFirst = index == 0;
              final isLast = index == detail.ayat.length - 1;

              final borderRadius = BorderRadius.only(
                topLeft: Radius.circular(isFirst ? 16 : 0),
                topRight: Radius.circular(isFirst ? 16 : 0),
                bottomLeft: Radius.circular(isLast ? 16 : 0),
                bottomRight: Radius.circular(isLast ? 16 : 0),
              );

              final key = _ayahKeys.putIfAbsent(a.nomorAyat, () => GlobalKey());
              final isBookmarked = (vm.lastReadSurah == widget.nomorSurah && vm.lastReadAyah == a.nomorAyat);

              return Material(
                key: key,
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
                borderRadius: borderRadius,
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            child: Text(
                              a.nomorAyat.toString(),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                              color: isBookmarked
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                            onPressed: () {
                              if (isBookmarked) {
                                context.read<QuranViewModel>().clearLastRead();
                              } else {
                                context.read<QuranViewModel>().saveLastRead(
                                      widget.nomorSurah,
                                      widget.namaLatin,
                                      a.nomorAyat,
                                    );
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        a.teksArab,
                        textAlign: TextAlign.right,
                        style: GoogleFonts.scheherazadeNew(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          height: 2.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        a.teksLatin,
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        a.teksIndonesia,
                        style: const TextStyle(
                            fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );

          // PENTING: Selalu gunakan Stack ketika initialAyahNumber != null,
          // agar widget tree STABIL saat overlay dihapus. Jika tree berubah
          // dari Stack>ListView menjadi ListView, Flutter akan re-create
          // ListView dan mereset scroll position ke 0.
          if (widget.initialAyahNumber != null) {
            final showOverlay = !_hasScrolledToInitial;
            return Stack(
              children: [
                content,
                if (showOverlay)
                  Positioned.fill(
                    child: Container(
                      color: theme.scaffoldBackgroundColor,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
              ],
            );
          }

          return content;
        },
      ),
    );
  }
}
