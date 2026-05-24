import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodel/theme_view_model.dart';
import 'api_list_page.dart';
import 'licenses_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _contentSource = 'offline';

  @override
  void initState() {
    super.initState();
    unawaited(_loadSettings());
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _contentSource = prefs.getString('content_source_quran') ?? 'offline';
    });
  }

  Future<void> _setContentSource(String val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('content_source_quran', val);
    setState(() {
      _contentSource = val;
    });
  }

  Future<void> _clearLocationData(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      const secureStorage = FlutterSecureStorage();
      await secureStorage.delete(key: 'cached_city_id');
      await secureStorage.delete(key: 'cached_city_name');

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_qibla_angle');
      await prefs.remove('cached_qibla_name');
      await prefs.remove('cached_qibla_lat');
      await prefs.remove('cached_qibla_lon');

      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2C2C2C),
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          content: const Text(
            'Data lokasi berhasil dihapus!',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      );
    } catch (_) {
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2C2C2C),
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          content: const Text(
            'Gagal menghapus data lokasi.',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      );
    }
  }

  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Bawaan Sistem';
      case ThemeMode.light:
        return 'Cerah';
      case ThemeMode.dark:
        return 'Gelap';
    }
  }

  void _showClearLocationConfirmDialog(BuildContext context) {
    final theme = Theme.of(context);
    unawaited(
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 8),
                const Text('Hapus Data Lokasi'),
              ],
            ),
            content: const Text(
              'Apakah Anda yakin ingin menghapus seluruh cache data lokasi? Tindakan ini akan menghapus cache kota shalat dan arah kiblat yang disimpan secara terenkripsi di perangkat Anda.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _clearLocationData(context);
                },
                child: const Text('Hapus'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showContentSourceDialog(BuildContext context) {
    String selected = _contentSource;
    unawaited(
      showDialog(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Sumber Konten Quran'),
                insetPadding: const EdgeInsets.symmetric(horizontal: 16),
                contentPadding: const EdgeInsets.only(
                  left: 0,
                  right: 0,
                  top: 8,
                  bottom: 0,
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: RadioGroup<String>(
                    groupValue: selected,
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selected = val);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          title: const Text(
                            'Hanya Offline (Rekomendasi)',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: const Text(
                            'Menggunakan data lokal terverifikasi. Sangat cepat, hemat kuota, dan 100% aman.',
                          ),
                          leading: const Radio<String>(value: 'offline'),
                          onTap: () {
                            setDialogState(() => selected = 'offline');
                          },
                        ),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          title: const Text(
                            'Hybrid (Offline & Online)',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: const Text(
                            'Menggunakan data lokal dan mengunduh pembaruan dari API jika koneksi tersedia.',
                          ),
                          leading: const Radio<String>(value: 'online'),
                          onTap: () {
                            setDialogState(() => selected = 'online');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Batal'),
                  ),
                  FilledButton(
                    onPressed: () async {
                      await _setContentSource(selected);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Simpan'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeVm = context.watch<ThemeViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan'), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 2.0),
            child: Card.filled(
              margin: EdgeInsets.zero,
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 4.0,
                ),
                leading: const Icon(Icons.palette_outlined),
                title: const Text(
                  'Tema',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(_getThemeLabel(themeVm.themeMode)),
                trailing: Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.8,
                  ),
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                onTap: () => _showThemeDialog(context, themeVm),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 2.0),
            child: Card.filled(
              margin: EdgeInsets.zero,
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 4.0,
                ),
                leading: const Icon(Icons.download_for_offline_outlined),
                title: const Text(
                  'Sumber Konten Quran',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  _contentSource == 'offline'
                      ? 'Hanya Offline (Sangat Aman)'
                      : 'Hybrid (Offline & API Online)',
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.8,
                  ),
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                onTap: () => _showContentSourceDialog(context),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 2.0),
            child: Card.filled(
              margin: EdgeInsets.zero,
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 4.0,
                ),
                leading: const Icon(Icons.dns_outlined),
                title: const Text(
                  'Daftar API',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('API Pihak Ketiga'),
                trailing: Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.8,
                  ),
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ApiListPage(),
                    ),
                  );
                },
              ),
            ),
          ),

          Card.filled(
            margin: EdgeInsets.zero,
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 4.0,
              ),
              leading: const Icon(Icons.description_outlined),
              title: const Text(
                'Lisensi',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Lisensi perangkat lunak sumber terbuka'),
              trailing: Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.8,
                ),
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LicensesPage()),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          Card.filled(
            margin: EdgeInsets.zero,
            color: theme.colorScheme.errorContainer.withValues(alpha: 0.15),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 4.0,
              ),
              leading: Icon(
                Icons.location_off_outlined,
                color: theme.colorScheme.error,
              ),
              title: Text(
                'Hapus Data Lokasi',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.error,
                ),
              ),
              subtitle: const Text('Hapus cache kota shalat & kiblat'),
              trailing: Icon(
                Icons.chevron_right,
                color: theme.colorScheme.error.withValues(alpha: 0.8),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onTap: () => _showClearLocationConfirmDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, ThemeViewModel themeVm) {
    ThemeMode selected = themeVm.themeMode;
    final theme = Theme.of(context);

    unawaited(
      showDialog(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Pilih Tema'),
                insetPadding: const EdgeInsets.symmetric(horizontal: 16),
                contentPadding: const EdgeInsets.only(
                  left: 0,
                  right: 0,
                  top: 8,
                  bottom: 0,
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: RadioGroup<ThemeMode>(
                    groupValue: selected,
                    onChanged: (mode) {
                      if (mode != null) {
                        setDialogState(() => selected = mode);
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          title: Text(
                            'Bawaan Sistem',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          leading: const Radio<ThemeMode>(
                            value: ThemeMode.system,
                          ),
                          onTap: () {
                            setDialogState(() => selected = ThemeMode.system);
                          },
                        ),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          title: Text(
                            'Cerah',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          leading: const Radio<ThemeMode>(
                            value: ThemeMode.light,
                          ),
                          onTap: () {
                            setDialogState(() => selected = ThemeMode.light);
                          },
                        ),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          title: Text(
                            'Gelap',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          leading: const Radio<ThemeMode>(
                            value: ThemeMode.dark,
                          ),
                          onTap: () {
                            setDialogState(() => selected = ThemeMode.dark);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Batal'),
                  ),
                  FilledButton(
                    onPressed: () async {
                      await themeVm.setThemeMode(selected);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Simpan'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
