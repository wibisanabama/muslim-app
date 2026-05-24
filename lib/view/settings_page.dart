import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  String _selectedLanguage = 'Indonesia';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('app_language') ?? 'Indonesia';
    });
  }

  Future<void> _saveLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', lang);
    setState(() {
      _selectedLanguage = lang;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeVm = context.watch<ThemeViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          // ─── Bahasa (top item → rounded top) ───
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                leading: const Icon(Icons.language_outlined),
                title: const Text(
                  'Bahasa',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(_selectedLanguage),
                trailing: Icon(
                  Icons.chevron_right,
                  color:
                      theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                onTap: () => _showLanguageDialog(context),
              ),
            ),
          ),

          // ─── Tema (middle item) ───
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                leading: const Icon(Icons.palette_outlined),
                title: const Text(
                  'Tema',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(themeVm.label),
                trailing: Icon(
                  Icons.chevron_right,
                  color:
                      theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                onTap: () => _showThemeDialog(context, themeVm),
              ),
            ),
          ),

          // ─── Sumber API (middle item) ───
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                leading: const Icon(Icons.dns_outlined),
                title: const Text(
                  'Daftar API',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('API Pihak Ketiga'),
                trailing: Icon(
                  Icons.chevron_right,
                  color:
                      theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ApiListPage(),
                    ),
                  );
                },
              ),
            ),
          ),

          // ─── Licenses (bottom item → rounded bottom) ───
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
              leading: const Icon(Icons.description_outlined),
              title: const Text(
                'Licenses',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Open-source software licenses'),
              trailing: Icon(
                Icons.chevron_right,
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LicensesPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    String selected = _selectedLanguage;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Pilih Bahasa'),
              insetPadding: const EdgeInsets.symmetric(horizontal: 16),
              contentPadding:
                  const EdgeInsets.only(left: 0, right: 0, top: 8, bottom: 0),
              content: SizedBox(
                width: double.maxFinite,
                child: RadioGroup<String>(
                  groupValue: selected,
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selected = val);
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<String>(
                        dense: false,
                        title: Text(
                          'English',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        value: 'English',
                      ),
                      RadioListTile<String>(
                        dense: false,
                        title: Text(
                          'Indonesia',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        value: 'Indonesia',
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
                  onPressed: () {
                    _saveLanguage(selected);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showThemeDialog(BuildContext context, ThemeViewModel themeVm) {
    ThemeMode selected = themeVm.themeMode;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Pilih Tema'),
              insetPadding: const EdgeInsets.symmetric(horizontal: 16),
              contentPadding:
                  const EdgeInsets.only(left: 0, right: 0, top: 8, bottom: 0),
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
                      RadioListTile<ThemeMode>(
                        dense: false,
                        title: Text(
                          'Bawaan Sistem',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        value: ThemeMode.system,
                      ),
                      RadioListTile<ThemeMode>(
                        dense: false,
                        title: Text(
                          'Cerah',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        value: ThemeMode.light,
                      ),
                      RadioListTile<ThemeMode>(
                        dense: false,
                        title: Text(
                          'Gelap',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        value: ThemeMode.dark,
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
                  onPressed: () {
                    themeVm.setThemeMode(selected);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
