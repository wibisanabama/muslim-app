import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/doa_view_model.dart';
import 'doa_detail_page.dart';

class SavedDoaPage extends StatefulWidget {
  const SavedDoaPage({super.key});

  @override
  State<SavedDoaPage> createState() => _SavedDoaPageState();
}

class _SavedDoaPageState extends State<SavedDoaPage> {
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
    final vm = context.watch<DoaViewModel>();
    final theme = Theme.of(context);
    final savedDoas = vm.getSavedDoas();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doa Disimpan'),
        centerTitle: false,
        backgroundColor: _isScrolled
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Builder(
        builder: (context) {
          if (savedDoas.isEmpty) {
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
                      'Belum ada doa yang disimpan',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Buka detail doa lalu ketuk ikon bookmark di pojok kanan atas untuk menyimpan doa favorit Anda.',
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

          return ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(12),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: savedDoas.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: theme.colorScheme.surface,
              thickness: 1.5,
            ),
            itemBuilder: (context, i) {
              final d = savedDoas[i];
              final isFirst = i == 0;
              final isLast = i == savedDoas.length - 1;

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
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DoaDetailPage(doa: d),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            d.doa,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                        ),
                      ],
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
