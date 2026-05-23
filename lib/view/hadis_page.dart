import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../repository/hadis_helper.dart';

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

    // Filter hadis locally based on search query
    final filteredList = HadisHelper.list.where((item) {
      final normQuery = _normalizeString(_searchQuery);
      if (normQuery.isEmpty) return true;

      final normTitle = _normalizeString(item.title);
      final normNarrator = _normalizeString(item.narrator);
      final normTranslation = _normalizeString(item.translation);
      final normLatin = _normalizeString(item.latin);

      return normTitle.contains(normQuery) ||
             normNarrator.contains(normQuery) ||
             normTranslation.contains(normQuery) ||
             normLatin.contains(normQuery);
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
              hintText: 'Cari Hadis...',
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
          if (filteredList.isEmpty) {
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
                    'Hadis "$_searchQuery" tidak ditemukan',
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
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final item = filteredList[index];
              final double bottomMargin = (index == filteredList.length - 1) ? 0.0 : 2.0;
              final BorderRadius borderRadius;
              if (filteredList.length == 1) {
                borderRadius = BorderRadius.circular(24.0);
              } else if (index == 0) {
                borderRadius = const BorderRadius.vertical(top: Radius.circular(24.0));
              } else if (index == filteredList.length - 1) {
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
                          builder: (context) => HadisDetailPage(hadis: item),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Lingkaran Nomor Hadis
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
                          // Detail Hadis
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.narrator,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
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
          );
        },
      ),
    );
  }
}

class HadisDetailPage extends StatelessWidget {
  final Hadis hadis;

  const HadisDetailPage({super.key, required this.hadis});

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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kartu Judul & Perawi
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
                      hadis.title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hadis.narrator,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

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
            const SizedBox(height: 16),

            // Teks Latin
            Text(
              hadis.latin,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // Terjemah Indonesia
            Text(
              '"${hadis.translation}"',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),

            // Penjelasan / Syarah Hadis
            Card.filled(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Penjelasan & Kandungan Hadis',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      hadis.explanation,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
