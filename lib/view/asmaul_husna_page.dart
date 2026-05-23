import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../repository/asmaul_husna_helper.dart';

class AsmaulHusnaPage extends StatefulWidget {
  const AsmaulHusnaPage({super.key});

  @override
  State<AsmaulHusnaPage> createState() => _AsmaulHusnaPageState();
}

class _AsmaulHusnaPageState extends State<AsmaulHusnaPage> {
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

    // Filter names locally based on search
    final filteredNames = AsmaulHusnaHelper.names.where((item) {
      final normQuery = _normalizeString(_searchQuery);
      if (normQuery.isEmpty) return true;

      final normLatin = _normalizeString(item.latin);
      final normTranslation = _normalizeString(item.translation);
      final normArabic = item.arabic;

      return normLatin.contains(normQuery) ||
             normTranslation.contains(normQuery) ||
             normArabic.contains(_searchQuery);
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
              hintText: 'Cari Asmaul Husna...',
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
          if (filteredNames.isEmpty) {
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
                    'Asmaul Husna "$_searchQuery" tidak ditemukan',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: 0.95,
            ),
            itemCount: filteredNames.length,
            itemBuilder: (context, index) {
              final item = filteredNames[index];
              
              // Segmented filled border radius calculations for 2-column grid
              final int total = filteredNames.length;
              final bool isTop = index < 2;
              final bool isLeft = index % 2 == 0;
              final bool isRight = index % 2 == 1;
              final bool hasNoItemBelow = (index + 2) >= total;

              final Radius topLeft = (isTop && isLeft) ? const Radius.circular(24.0) : Radius.zero;
              final Radius topRight = (isTop && isRight) ? const Radius.circular(24.0) : (total == 1 && isLeft ? const Radius.circular(24.0) : Radius.zero);
              final Radius bottomLeft = (hasNoItemBelow && isLeft) ? const Radius.circular(24.0) : Radius.zero;
              final Radius bottomRight = (hasNoItemBelow && isRight) 
                  ? const Radius.circular(24.0) 
                  : ((index == total - 1) ? const Radius.circular(24.0) : Radius.zero);

              final borderRadius = BorderRadius.only(
                topLeft: topLeft,
                topRight: topRight,
                bottomLeft: bottomLeft,
                bottomRight: bottomRight,
              );

              return Card.filled(
                margin: EdgeInsets.zero,
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
                shape: RoundedRectangleBorder(
                  borderRadius: borderRadius,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          item.number.toString(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.arabic,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.scheherazadeNew(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.latin,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.translation,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
