import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/hadis_model.dart';
import '../repository/hadis_repository.dart';

// Book Model
class HadisBook {
  final String id;
  final String name;
  final int available;

  const HadisBook({
    required this.id,
    required this.name,
    required this.available,
  });
}

// 9 Canonical Hadith Books metadata
const List<HadisBook> hadisBooks = [
  HadisBook(id: "bukhari", name: "HR. Bukhari", available: 6638),
  HadisBook(id: "muslim", name: "HR. Muslim", available: 4930),
  HadisBook(id: "tirmidzi", name: "HR. Tirmidzi", available: 3625),
  HadisBook(id: "abu-daud", name: "HR. Abu Daud", available: 4419),
  HadisBook(id: "nasai", name: "HR. Nasai", available: 5364),
  HadisBook(id: "ibnu-majah", name: "HR. Ibnu Majah", available: 4285),
  HadisBook(id: "malik", name: "HR. Malik", available: 1587),
  HadisBook(id: "ahmad", name: "HR. Ahmad", available: 4305),
  HadisBook(id: "darimi", name: "HR. Darimi", available: 2949),
];

class HadisPage extends StatefulWidget {
  const HadisPage({super.key});

  @override
  State<HadisPage> createState() => _HadisPageState();
}

class _HadisPageState extends State<HadisPage> {
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
    final theme = Theme.of(context);

    // Filter books locally based on search
    final filteredBooks = hadisBooks.where((book) {
      final normQuery = _normalizeString(_searchQuery);
      if (normQuery.isEmpty) return true;
      return _normalizeString(book.name).contains(normQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: _isScrolled
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: Container(
          height: 48,
          margin: const EdgeInsets.only(right: 16.0),
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
              hintText: 'Cari Kitab Hadis...',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.6),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      ),
      body: Builder(
        builder: (context) {
          if (filteredBooks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 48,
                    color: theme.colorScheme.secondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Kitab "$_searchQuery" tidak ditemukan',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: filteredBooks.length,
            itemBuilder: (context, index) {
              final book = filteredBooks[index];
              final double bottomMargin = (index == filteredBooks.length - 1) ? 0.0 : 2.0;
              final BorderRadius borderRadius;
              if (filteredBooks.length == 1) {
                borderRadius = BorderRadius.circular(24.0);
              } else if (index == 0) {
                borderRadius = const BorderRadius.vertical(top: Radius.circular(24.0));
              } else if (index == filteredBooks.length - 1) {
                borderRadius = const BorderRadius.vertical(bottom: Radius.circular(24.0));
              } else {
                borderRadius = BorderRadius.zero;
              }

              return Padding(
                padding: EdgeInsets.only(bottom: bottomMargin),
                child: Card.filled(
                  margin: EdgeInsets.zero,
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
                  shape: RoundedRectangleBorder(
                    borderRadius: borderRadius,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HadisListPage(
                            bookId: book.id,
                            bookName: book.name,
                            totalAvailable: book.available,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                      child: Row(
                        children: [
                          // Rounded Book Icon Container
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.menu_book_rounded,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tersedia ${book.available} Hadis',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: theme.colorScheme.primary.withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class HadisListPage extends StatefulWidget {
  final String bookId;
  final String bookName;
  final int totalAvailable;

  const HadisListPage({
    super.key,
    required this.bookId,
    required this.bookName,
    required this.totalAvailable,
  });

  @override
  State<HadisListPage> createState() => _HadisListPageState();
}

class _HadisListPageState extends State<HadisListPage> {
  final List<Hadis> _hadiths = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _numberController = TextEditingController();
  final HadisRepository _repository = HadisRepository();

  int _currentStart = 1;
  final int _batchSize = 50;
  bool _isLoading = false;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _fetchNextBatch();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _fetchNextBatch();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _fetchNextBatch() async {
    if (_isLoading || _isOffline) return;
    if (_currentStart > widget.totalAvailable) return;

    setState(() {
      _isLoading = true;
    });

    int end = _currentStart + _batchSize - 1;
    if (end > widget.totalAvailable) {
      end = widget.totalAvailable;
    }

    try {
      final newHadiths = await _repository.getHadisRange(widget.bookId, _currentStart, end);
      
      // Mapped fallback detection: if it returns exactly 12 items, it is the local curated offline fallback
      if (newHadiths.length == 12 && newHadiths.first.translation.contains("Penjelasan & Kandungan:")) {
        setState(() {
          _isOffline = true;
          _hadiths.addAll(newHadiths);
        });
      } else {
        setState(() {
          _hadiths.addAll(newHadiths);
          _currentStart = end + 1;
        });
      }
    } catch (e) {
      // Graceful fallback to offline mode
      final fallback = _repository.getLocalFallback();
      setState(() {
        _isOffline = true;
        _hadiths.addAll(fallback);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchHadisByNumber() async {
    final query = _numberController.text.trim();
    if (query.isEmpty) return;

    final parsed = int.tryParse(query);
    if (parsed == null || parsed < 1 || parsed > widget.totalAvailable) {
      _showSnackbar("Silakan masukkan nomor hadis antara 1 dan ${widget.totalAvailable}");
      return;
    }



    // Show dynamic blocking loading indicator overlay dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final singleHadis = await _repository.getSingleHadis(widget.bookId, parsed);
      if (mounted) {
        Navigator.pop(context); // Pop loading dialog
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HadisDetailPage(
              hadis: singleHadis,
              bookName: widget.bookName,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Pop loading dialog
        _showSnackbar("Hadis nomor $parsed tidak ditemukan atau Anda sedang offline.");
      }
    }
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bookName),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          // Jump to Hadith Number input header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _numberController,
                      keyboardType: TextInputType.number,
                      textAlignVertical: TextAlignVertical.center,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _searchHadisByNumber(),
                      decoration: InputDecoration(
                        hintText: 'Cari nomor hadis (1-${widget.totalAvailable})...',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        isDense: true,
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _searchHadisByNumber,
                  icon: const Icon(Icons.search_rounded),
                  style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    backgroundColor: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          // Offline Warning Banner
          if (_isOffline)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.offline_bolt_rounded, color: theme.colorScheme.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Anda sedang offline. Menampilkan 12 Hadis pilihan.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Hadith List
          Expanded(
            child: _hadiths.isEmpty && _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _hadiths.length + (_isLoading && !_isOffline ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _hadiths.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final item = _hadiths[index];
                      final double bottomMargin = (index == _hadiths.length - 1) ? 0.0 : 2.0;
                      final BorderRadius borderRadius;
                      if (_hadiths.length == 1) {
                        borderRadius = BorderRadius.circular(24.0);
                      } else if (index == 0) {
                        borderRadius = const BorderRadius.vertical(top: Radius.circular(24.0));
                      } else if (index == _hadiths.length - 1) {
                        borderRadius = const BorderRadius.vertical(bottom: Radius.circular(24.0));
                      } else {
                        borderRadius = BorderRadius.zero;
                      }

                      return Padding(
                        padding: EdgeInsets.only(bottom: bottomMargin),
                        child: Card.filled(
                          margin: EdgeInsets.zero,
                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
                          shape: RoundedRectangleBorder(
                            borderRadius: borderRadius,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HadisDetailPage(
                                    hadis: item,
                                    bookName: widget.bookName,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Number Circle Badge
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      item.number.toString(),
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Translation preview snippet
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Quick snippet of Arabic text
                                        Text(
                                          item.arabic,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.scheherazadeNew(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            height: 1.2,
                                            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          item.translation,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                            height: 1.4,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: theme.colorScheme.primary.withValues(alpha: 0.7),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class HadisDetailPage extends StatelessWidget {
  final Hadis hadis;
  final String bookName;

  const HadisDetailPage({
    super.key,
    required this.hadis,
    required this.bookName,
  });

  void _copyToClipboard(BuildContext context) {
    final textToCopy = "$bookName - Hadis Ke-${hadis.number}\n\n${hadis.arabic}\n\n${hadis.translation}";
    Clipboard.setData(ClipboardData(text: textToCopy));
    
    // Premium custom Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Colors.white),
            SizedBox(width: 12),
            Text('Hadis berhasil disalin ke papan klip!'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Hadis'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: 'Salin Hadis',
            onPressed: () => _copyToClipboard(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card: Book Name & Hadith Number
            Card.filled(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Hadis Ke-${hadis.number}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      bookName,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Teks Arab
            Text(
              hadis.arabic,
              textAlign: TextAlign.center,
              style: GoogleFonts.scheherazadeNew(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                height: 1.8,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 28),

            // Divider
            Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.2)),
            const SizedBox(height: 28),

            // Terjemah Indonesia & Syarah (if fallback)
            Text(
              hadis.translation,
              textAlign: TextAlign.left,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
