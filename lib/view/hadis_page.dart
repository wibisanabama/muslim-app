import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/hadis_model.dart';
import '../repository/hadis_repository.dart';

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
  int _globalSavedCount = 0;

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
    unawaited(_loadGlobalSavedCount());
  }

  Future<void> _loadGlobalSavedCount() async {
    final prefs = await SharedPreferences.getInstance();
    int total = 0;
    for (final book in hadisBooks) {
      final saved = prefs.getStringList('saved_hadis_${book.id}') ?? [];
      total += saved.length;
    }
    if (mounted) {
      setState(() {
        _globalSavedCount = total;
      });
    }
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
        titleSpacing: 8.0,
        title: Container(
          height: 48,
          margin: const EdgeInsets.only(right: 8.0),
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
              hintText: 'Cari kitab hadis...',
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

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_searchQuery.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Card.filled(
                    margin: EdgeInsets.zero,
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SavedHadisPage(),
                          ),
                        );
                        await _loadGlobalSavedCount();
                      },
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
                              _globalSavedCount > 0
                                  ? '$_globalSavedCount Hadis Disimpan'
                                  : 'Belum ada hadis yang disimpan',
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
                ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredBooks.length,
                  itemBuilder: (context, index) {
                    final book = filteredBooks[index];
                    final double bottomMargin =
                        (index == filteredBooks.length - 1) ? 0.0 : 2.0;
                    final BorderRadius borderRadius;
                    if (filteredBooks.length == 1) {
                      borderRadius = BorderRadius.circular(24.0);
                    } else if (index == 0) {
                      borderRadius = const BorderRadius.vertical(
                        top: Radius.circular(24.0),
                      );
                    } else if (index == filteredBooks.length - 1) {
                      borderRadius = const BorderRadius.vertical(
                        bottom: Radius.circular(24.0),
                      );
                    } else {
                      borderRadius = BorderRadius.zero;
                    }

                    return Padding(
                      padding: EdgeInsets.only(bottom: bottomMargin),
                      child: Card.filled(
                        margin: EdgeInsets.zero,
                        color: theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.25,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: borderRadius,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HadisListPage(
                                  bookId: book.id,
                                  bookName: book.name,
                                  totalAvailable: book.available,
                                ),
                              ),
                            );
                            await _loadGlobalSavedCount();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 20.0,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book.name,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Tersedia ${book.available} Hadis',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.7,
                                  ),
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

  String _searchQuery = '';
  final Map<int, Hadis> _searchedHadiths = {};
  final Set<int> _fetchingNumbers = {};
  String? _searchError;

  int _currentStart = 1;
  final int _batchSize = 50;
  bool _isLoading = false;
  bool _isError = false;
  bool _isScrolled = false;
  List<int> _savedHadisNumbers = [];

  @override
  void initState() {
    super.initState();
    unawaited(_fetchNextBatch());
    unawaited(_loadSavedHadis());
    _scrollController.addListener(() {
      final scrolled = _scrollController.offset > 0;
      if (scrolled != _isScrolled) {
        setState(() {
          _isScrolled = scrolled;
        });
      }
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        unawaited(_fetchNextBatch());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedHadis() async {
    final prefs = await SharedPreferences.getInstance();
    final savedList = prefs.getStringList('saved_hadis_${widget.bookId}') ?? [];
    setState(() {
      _savedHadisNumbers = savedList
          .map((e) => int.tryParse(e) ?? 0)
          .where((e) => e != 0)
          .toList();
    });
  }

  Future<void> _fetchNextBatch() async {
    if (_isLoading) return;
    if (_currentStart > widget.totalAvailable) return;

    setState(() {
      _isLoading = true;
      _isError = false;
    });

    int end = _currentStart + _batchSize - 1;
    if (end > widget.totalAvailable) {
      end = widget.totalAvailable;
    }

    try {
      final newHadiths = await _repository.getHadisRange(
        widget.bookId,
        _currentStart,
        end,
      );
      setState(() {
        _hadiths.addAll(newHadiths);
        _currentStart = end + 1;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isError = _hadiths.isEmpty;
        _isLoading = false;
      });
    }
  }

  Future<void> _searchHadisByNumber() async {
    final query = _numberController.text.trim();
    if (query.isEmpty) return;

    final parsed = int.tryParse(query);
    if (parsed == null || parsed < 1 || parsed > widget.totalAvailable) {
      return;
    }

    await _openHadisByNumber(parsed);
  }

  Future<void> _openHadisByNumber(int number) async {
    final theme = Theme.of(context);

    Hadis? foundHadis;
    final inMemory = _hadiths.where((h) => h.number == number).toList();
    if (inMemory.isNotEmpty) {
      foundHadis = inMemory.first;
    } else {
      foundHadis = _searchedHadiths[number];
    }

    if (foundHadis != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HadisDetailPage(
            hadis: foundHadis!,
            bookId: widget.bookId,
            bookName: widget.bookName,
          ),
        ),
      );
      await _loadSavedHadis();
      return;
    }

    unawaited(
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      ),
    );

    try {
      final singleHadis = await _repository.getSingleHadis(
        widget.bookId,
        number,
      );
      if (mounted) {
        Navigator.pop(context);

        setState(() {
          _searchedHadiths[number] = singleHadis;
        });

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HadisDetailPage(
              hadis: singleHadis,
              bookId: widget.bookId,
              bookName: widget.bookName,
            ),
          ),
        );
        await _loadSavedHadis();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memuat hadis nomor $number. Pastikan koneksi internet aktif.',
            ),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _lazyFetchHadis(int number) async {
    if (_fetchingNumbers.contains(number)) return;

    _fetchingNumbers.add(number);
    try {
      final singleHadis = await _repository.getSingleHadis(
        widget.bookId,
        number,
      );
      if (mounted && _searchQuery.isNotEmpty) {
        setState(() {
          _searchedHadiths[number] = singleHadis;
          _fetchingNumbers.remove(number);
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _fetchingNumbers.remove(number);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
        titleSpacing: 8.0,
        title: Container(
          height: 48,
          margin: const EdgeInsets.only(right: 8.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(24),
          ),
          child: TextField(
            controller: _numberController,
            keyboardType: TextInputType.number,
            textAlignVertical: TextAlignVertical.center,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _searchHadisByNumber(),
            onChanged: (value) {
              final trimmed = value.trim();
              setState(() {
                _searchQuery = trimmed;
                _searchError = null;
              });

              if (trimmed.isEmpty) {
                return;
              }

              final parsed = int.tryParse(trimmed);
              if (parsed == null ||
                  parsed < 1 ||
                  parsed > widget.totalAvailable) {
                setState(() {
                  _searchError =
                      'Nomor hadis harus antara 1 dan ${widget.totalAvailable}';
                });
                return;
              }
            },
            decoration: InputDecoration(
              hintText: 'Cari hadis ${widget.bookName}...',
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
                        _numberController.clear();
                        setState(() {
                          _searchQuery = '';
                          _searchError = null;
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_searchQuery.isEmpty && !_isLoading && _hadiths.isNotEmpty)
            Builder(
              builder: (context) {
                final savedCount = _savedHadisNumbers.length;
                final hasSaved = savedCount > 0;

                return Card.filled(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SavedHadisPage(
                            bookId: widget.bookId,
                            bookName: widget.bookName,
                          ),
                        ),
                      );
                      await _loadSavedHadis();
                    },
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
                            hasSaved
                                ? '$savedCount Hadis Disimpan'
                                : 'Belum ada hadis yang disimpan',
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
                );
              },
            ),

          Expanded(
            child: _searchQuery.isNotEmpty
                ? Builder(
                    builder: (context) {
                      if (_searchError != null) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 48,
                                  color: theme.colorScheme.secondary.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _searchError!,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final query = _searchQuery.trim();
                      final List<int> matchingNumbers = [];
                      final parsedQuery = int.tryParse(query);

                      for (int i = 1; i <= widget.totalAvailable; i++) {
                        if (i.toString().contains(query)) {
                          matchingNumbers.add(i);
                        }
                      }

                      matchingNumbers.sort((a, b) {
                        if (a == parsedQuery) return -1;
                        if (b == parsedQuery) return 1;

                        final strA = a.toString();
                        final strB = b.toString();

                        final startsA = strA.startsWith(query);
                        final startsB = strB.startsWith(query);

                        if (startsA && !startsB) return -1;
                        if (!startsA && startsB) return 1;

                        return a.compareTo(b);
                      });

                      final displayedMatches = matchingNumbers
                          .take(100)
                          .toList();

                      if (displayedMatches.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 48,
                                  color: theme.colorScheme.secondary.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Hadis tidak ditemukan',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: displayedMatches.length,
                        itemBuilder: (context, index) {
                          final num = displayedMatches[index];

                          Hadis? foundHadis;
                          final inMemory = _hadiths
                              .where((h) => h.number == num)
                              .toList();
                          if (inMemory.isNotEmpty) {
                            foundHadis = inMemory.first;
                          } else {
                            foundHadis = _searchedHadiths[num];
                          }

                          final double bottomMargin =
                              (index == displayedMatches.length - 1)
                              ? 0.0
                              : 2.0;
                          final BorderRadius borderRadius;
                          if (displayedMatches.length == 1) {
                            borderRadius = BorderRadius.circular(24.0);
                          } else if (index == 0) {
                            borderRadius = const BorderRadius.vertical(
                              top: Radius.circular(24.0),
                            );
                          } else if (index == displayedMatches.length - 1) {
                            borderRadius = const BorderRadius.vertical(
                              bottom: Radius.circular(24.0),
                            );
                          } else {
                            borderRadius = BorderRadius.zero;
                          }

                          if (foundHadis == null) {
                            unawaited(_lazyFetchHadis(num));

                            return Padding(
                              padding: EdgeInsets.only(bottom: bottomMargin),
                              child: Card.filled(
                                margin: EdgeInsets.zero,
                                color: theme.colorScheme.primaryContainer
                                    .withValues(alpha: 0.25),
                                shape: RoundedRectangleBorder(
                                  borderRadius: borderRadius,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary
                                              .withValues(alpha: 0.05),
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  theme.colorScheme.primary
                                                      .withValues(alpha: 0.4),
                                                ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 120,
                                              height: 16,
                                              decoration: BoxDecoration(
                                                color: theme
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.05),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            const SizedBox(height: 12),

                                            Container(
                                              width: double.infinity,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: theme
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.05),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          return Padding(
                            padding: EdgeInsets.only(bottom: bottomMargin),
                            child: Card.filled(
                              margin: EdgeInsets.zero,
                              color: theme.colorScheme.primaryContainer
                                  .withValues(alpha: 0.25),
                              shape: RoundedRectangleBorder(
                                borderRadius: borderRadius,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () => _openHadisByNumber(num),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary
                                              .withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          num.toString(),
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    theme.colorScheme.primary,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              foundHadis.arabic,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  GoogleFonts.scheherazadeNew(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                    height: 1.2,
                                                    color: theme
                                                        .colorScheme
                                                        .onSurface
                                                        .withValues(alpha: 0.8),
                                                  ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              foundHadis.translation,
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    color: theme
                                                        .colorScheme
                                                        .onSurfaceVariant,
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
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.7),
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
                  )
                : _isError && _hadiths.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_off_rounded,
                            size: 48,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Gagal memuat daftar hadis',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pastikan Anda terhubung ke internet dan coba lagi.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _fetchNextBatch,
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _hadiths.isEmpty && _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _hadiths.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _hadiths.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final item = _hadiths[index];
                      final double bottomMargin = (index == _hadiths.length - 1)
                          ? 0.0
                          : 2.0;
                      final BorderRadius borderRadius;
                      if (_hadiths.length == 1) {
                        borderRadius = BorderRadius.circular(24.0);
                      } else if (index == 0) {
                        borderRadius = const BorderRadius.vertical(
                          top: Radius.circular(24.0),
                        );
                      } else if (index == _hadiths.length - 1) {
                        borderRadius = const BorderRadius.vertical(
                          bottom: Radius.circular(24.0),
                        );
                      } else {
                        borderRadius = BorderRadius.zero;
                      }

                      return Padding(
                        padding: EdgeInsets.only(bottom: bottomMargin),
                        child: Card.filled(
                          margin: EdgeInsets.zero,
                          color: theme.colorScheme.primaryContainer.withValues(
                            alpha: 0.25,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: borderRadius,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HadisDetailPage(
                                    hadis: item,
                                    bookId: widget.bookId,
                                    bookName: widget.bookName,
                                  ),
                                ),
                              );
                              await _loadSavedHadis();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      item.number.toString(),
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.arabic,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.scheherazadeNew(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            height: 1.2,
                                            color: theme.colorScheme.onSurface
                                                .withValues(alpha: 0.8),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          item.translation,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
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
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.7,
                                    ),
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

class HadisDetailPage extends StatefulWidget {
  final Hadis hadis;
  final String bookId;
  final String bookName;

  const HadisDetailPage({
    super.key,
    required this.hadis,
    required this.bookId,
    required this.bookName,
  });

  @override
  State<HadisDetailPage> createState() => _HadisDetailPageState();
}

class _HadisDetailPageState extends State<HadisDetailPage> {
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    unawaited(_checkBookmarkStatus());
  }

  Future<void> _checkBookmarkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedList = prefs.getStringList('saved_hadis_${widget.bookId}') ?? [];
    setState(() {
      _isBookmarked = savedList.contains(widget.hadis.number.toString());
    });
  }

  Future<void> _toggleBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'saved_hadis_${widget.bookId}';
    final savedList = prefs.getStringList(key) ?? [];
    final numStr = widget.hadis.number.toString();

    if (_isBookmarked) {
      savedList.remove(numStr);
      await prefs.setStringList(key, savedList);
      setState(() {
        _isBookmarked = false;
      });
    } else {
      savedList.add(numStr);
      await prefs.setStringList(key, savedList);
      setState(() {
        _isBookmarked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Hadis Ke-${widget.hadis.number}'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: _isBookmarked ? theme.colorScheme.primary : null,
            ),
            tooltip: 'Simpan Hadis',
            onPressed: _toggleBookmark,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card.filled(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    widget.bookName,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            Text(
              widget.hadis.arabic,
              textAlign: TextAlign.center,
              style: GoogleFonts.scheherazadeNew(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                height: 1.8,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 28),

            Divider(
              height: 1,
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 28),

            Text(
              widget.hadis.translation,
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

class GlobalSavedHadisItem {
  final Hadis hadis;
  final String bookId;
  final String bookName;

  const GlobalSavedHadisItem({
    required this.hadis,
    required this.bookId,
    required this.bookName,
  });
}

class SavedHadisPage extends StatefulWidget {
  final String? bookId;
  final String? bookName;

  const SavedHadisPage({super.key, this.bookId, this.bookName});

  bool get isGlobal => bookId == null;

  @override
  State<SavedHadisPage> createState() => _SavedHadisPageState();
}

class _SavedHadisPageState extends State<SavedHadisPage> {
  final ScrollController _scrollController = ScrollController();
  final HadisRepository _repository = HadisRepository();
  List<GlobalSavedHadisItem> _savedItems = [];
  bool _isLoading = true;
  bool _isError = false;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final scrolled = _scrollController.offset > 0;
      if (scrolled != _isScrolled) {
        setState(() {
          _isScrolled = scrolled;
        });
      }
    });
    unawaited(_loadSavedHadiths());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedHadiths() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      final List<GlobalSavedHadisItem> tempItems = [];

      if (widget.isGlobal) {
        final List<Future<List<GlobalSavedHadisItem>>> futures = [];

        for (final book in hadisBooks) {
          final numbers = prefs.getStringList('saved_hadis_${book.id}') ?? [];
          if (numbers.isNotEmpty) {
            futures.add(() async {
              final List<GlobalSavedHadisItem> bookItems = [];
              final bookFutures = numbers.map((numStr) async {
                final num = int.parse(numStr);
                try {
                  final h = await _repository.getSingleHadis(book.id, num);
                  bookItems.add(
                    GlobalSavedHadisItem(
                      hadis: h,
                      bookId: book.id,
                      bookName: book.name,
                    ),
                  );
                } catch (_) {}
              }).toList();

              await Future.wait(bookFutures);
              return bookItems;
            }());
          }
        }

        final results = await Future.wait(futures);
        for (final list in results) {
          tempItems.addAll(list);
        }

        tempItems.sort((a, b) {
          final bookCompare = a.bookName.compareTo(b.bookName);
          if (bookCompare != 0) return bookCompare;
          return a.hadis.number.compareTo(b.hadis.number);
        });
      } else {
        final numbers =
            prefs.getStringList('saved_hadis_${widget.bookId}') ?? [];
        if (numbers.isNotEmpty) {
          final bookFutures = numbers.map((numStr) async {
            final num = int.parse(numStr);
            final h = await _repository.getSingleHadis(widget.bookId!, num);
            tempItems.add(
              GlobalSavedHadisItem(
                hadis: h,
                bookId: widget.bookId!,
                bookName: widget.bookName!,
              ),
            );
          }).toList();

          await Future.wait(bookFutures);

          tempItems.sort((a, b) => a.hadis.number.compareTo(b.hadis.number));
        }
      }

      setState(() {
        _savedItems = tempItems;
      });
    } catch (e) {
      setState(() {
        _isError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isGlobal
              ? 'Semua Hadis Disimpan'
              : 'Hadis ${widget.bookName!.replaceAll("HR. ", "")} Disimpan',
        ),
        centerTitle: false,
        backgroundColor: _isScrolled
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Builder(
        builder: (context) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_isError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Gagal memuat hadis yang disimpan',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pastikan Anda terhubung ke internet dan coba lagi.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _loadSavedHadiths,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (_savedItems.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.bookmark_outline_rounded,
                        size: 40,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Belum ada hadis yang disimpan',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.isGlobal
                          ? 'Buka kitab hadis pilihan Anda, buka detail hadis lalu ketuk ikon bookmark di pojok kanan atas untuk menyimpan hadis pilihan Anda.'
                          : 'Buka detail hadis lalu ketuk ikon bookmark di pojok kanan atas untuk menyimpan hadis pilihan Anda.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _savedItems.length,
            itemBuilder: (context, index) {
              final item = _savedItems[index];
              final hadis = item.hadis;
              final double bottomMargin = (index == _savedItems.length - 1)
                  ? 0.0
                  : 2.0;
              final BorderRadius borderRadius;
              if (_savedItems.length == 1) {
                borderRadius = BorderRadius.circular(24.0);
              } else if (index == 0) {
                borderRadius = const BorderRadius.vertical(
                  top: Radius.circular(24.0),
                );
              } else if (index == _savedItems.length - 1) {
                borderRadius = const BorderRadius.vertical(
                  bottom: Radius.circular(24.0),
                );
              } else {
                borderRadius = BorderRadius.zero;
              }

              return Padding(
                padding: EdgeInsets.only(bottom: bottomMargin),
                child: Card.filled(
                  margin: EdgeInsets.zero,
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.25,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: borderRadius),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HadisDetailPage(
                            hadis: hadis,
                            bookId: item.bookId,
                            bookName: item.bookName,
                          ),
                        ),
                      );
                      await _loadSavedHadiths();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              hadis.number.toString(),
                              style: theme.textTheme.titleMedium?.copyWith(
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
                                if (widget.isGlobal) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item.bookName,
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                ],
                                Text(
                                  hadis.arabic,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.scheherazadeNew(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  hadis.translation,
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
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.7,
                            ),
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
