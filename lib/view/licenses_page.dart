import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LicensesPage extends StatefulWidget {
  const LicensesPage({super.key});

  @override
  State<LicensesPage> createState() => _LicensesPageState();
}

class _LicensesPageState extends State<LicensesPage> {
  late final Future<List<_PackageLicense>> _licensesFuture;

  @override
  void initState() {
    super.initState();
    _licensesFuture = _loadLicenses();
  }

  Future<List<_PackageLicense>> _loadLicenses() async {
    final Map<String, List<LicenseEntry>> packageLicenses = {};
    await for (final entry in LicenseRegistry.licenses) {
      for (final package in entry.packages) {
        packageLicenses.putIfAbsent(package, () => []).add(entry);
      }
    }

    final sortedPackages = packageLicenses.keys.toList()..sort();
    return sortedPackages.map((package) {
      return _PackageLicense(
        packageName: package,
        entries: packageLicenses[package]!,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lisensi'),
        centerTitle: false,
      ),
      body: FutureBuilder<List<_PackageLicense>>(
        future: _licensesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Gagal memuat lisensi: ${snapshot.error}',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            );
          }
          final packages = snapshot.data ?? [];
          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            children: [
              Card.filled(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.25,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Muslim',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Versi 1.0.0',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, indent: 40, endIndent: 40),
                      const SizedBox(height: 12),
                      Text(
                        'Ditenagai oleh Flutter & Sumber Terbuka',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  'Lisensi Pihak Ketiga',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              ...List.generate(packages.length, (i) {
                final double bottomMargin = (i == packages.length - 1)
                    ? 0.0
                    : 2.0;
                final BorderRadius borderRadius;
                if (packages.length == 1) {
                  borderRadius = BorderRadius.circular(16.0);
                } else if (i == 0) {
                  borderRadius = const BorderRadius.vertical(
                    top: Radius.circular(16.0),
                  );
                } else if (i == packages.length - 1) {
                  borderRadius = const BorderRadius.vertical(
                    bottom: Radius.circular(16.0),
                  );
                } else {
                  borderRadius = BorderRadius.zero;
                }

                return Padding(
                  padding: EdgeInsets.only(bottom: bottomMargin),
                  child: Card.filled(
                    margin: EdgeInsets.zero,
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.15,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: borderRadius),
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 4.0,
                      ),
                      title: Text(
                        packages[i].packageName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${packages[i].entries.length} lisensi',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.8,
                        ),
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PackageLicenseDetailPage(
                              packageName: packages[i].packageName,
                              entries: packages[i].entries,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class PackageLicenseDetailPage extends StatefulWidget {
  final String packageName;
  final List<LicenseEntry> entries;

  const PackageLicenseDetailPage({
    super.key,
    required this.packageName,
    required this.entries,
  });

  @override
  State<PackageLicenseDetailPage> createState() =>
      _PackageLicenseDetailPageState();
}

class _PackageLicenseDetailPageState extends State<PackageLicenseDetailPage> {
  late final List<_LicenseItem> _items;

  @override
  void initState() {
    super.initState();
    _items = [];
    for (int i = 0; i < widget.entries.length; i++) {
      final entry = widget.entries[i];
      if (widget.entries.length > 1) {
        _items.add(_LicenseItem(isHeader: true, text: 'Lisensi ${i + 1}'));
      }
      for (final paragraph in entry.paragraphs) {
        _items.add(
          _LicenseItem(
            isHeader: false,
            text: paragraph.text,
            indent: paragraph.indent,
          ),
        );
      }
      if (i < widget.entries.length - 1) {
        _items.add(_LicenseItem(isHeader: false, text: '', isSpacer: true));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.packageName),
        centerTitle: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          if (item.isSpacer) {
            return const SizedBox(height: 16);
          }
          if (item.isHeader) {
            return Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Text(
                item.text,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            );
          }
          final double leftPadding =
              (item.indent < 0 ? 0.0 : item.indent) * 16.0;
          final TextAlign textAlign = item.indent < 0
              ? TextAlign.center
              : TextAlign.left;
          return Padding(
            padding: EdgeInsets.only(left: leftPadding, top: 2.0, bottom: 2.0),
            child: Text(
              item.text,
              textAlign: textAlign,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12.0,
                height: 1.5,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LicenseItem {
  final bool isHeader;
  final bool isSpacer;
  final String text;
  final int indent;

  _LicenseItem({
    required this.isHeader,
    required this.text,
    this.indent = 0,
    this.isSpacer = false,
  });
}

class _PackageLicense {
  final String packageName;
  final List<LicenseEntry> entries;

  _PackageLicense({required this.packageName, required this.entries});
}