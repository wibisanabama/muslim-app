import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/theme_view_model.dart';
import '../viewmodel/language_view_model.dart';
import 'api_list_page.dart';
import 'licenses_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  String _getThemeLabel(ThemeMode mode, LanguageViewModel langVm) {
    switch (mode) {
      case ThemeMode.system:
        return langVm.translate('Bawaan Sistem', 'System Default');
      case ThemeMode.light:
        return langVm.translate('Cerah', 'Light');
      case ThemeMode.dark:
        return langVm.translate('Gelap', 'Dark');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeVm = context.watch<ThemeViewModel>();
    final langVm = context.watch<LanguageViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(langVm.translate('Pengaturan', 'Settings')),
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
                title: Text(
                  langVm.translate('Bahasa', 'Language'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(langVm.currentLabel),
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
                onTap: () => _showLanguageDialog(context, langVm),
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
                title: Text(
                  langVm.translate('Tema', 'Theme'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(_getThemeLabel(themeVm.themeMode, langVm)),
                trailing: Icon(
                  Icons.chevron_right,
                  color:
                      theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                onTap: () => _showThemeDialog(context, themeVm, langVm),
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
                title: Text(
                  langVm.translate('Daftar API', 'API Directory'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(langVm.translate('API Pihak Ketiga', 'Third-Party APIs')),
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
              subtitle: Text(
                langVm.translate('Lisensi perangkat lunak sumber terbuka', 'Open-source software licenses'),
              ),
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

  void _showLanguageDialog(BuildContext context, LanguageViewModel langVm) {
    String selected = langVm.selectedLanguage;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(langVm.translate('Pilih Bahasa', 'Select Language')),
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
                          langVm.translate('Bawaan Sistem', 'System Default'),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        value: 'system',
                      ),
                      RadioListTile<String>(
                        dense: false,
                        title: Text(
                          langVm.englishLabel,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        value: 'en',
                      ),
                      RadioListTile<String>(
                        dense: false,
                        title: Text(
                          langVm.indonesianLabel,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        value: 'id',
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(langVm.translate('Batal', 'Cancel')),
                ),
                FilledButton(
                  onPressed: () {
                    langVm.setLanguage(selected);
                    Navigator.pop(ctx);
                  },
                  child: Text(langVm.translate('Simpan', 'Save')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showThemeDialog(BuildContext context, ThemeViewModel themeVm, LanguageViewModel langVm) {
    ThemeMode selected = themeVm.themeMode;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(langVm.translate('Pilih Tema', 'Select Theme')),
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
                          langVm.translate('Bawaan Sistem', 'System Default'),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        value: ThemeMode.system,
                      ),
                      RadioListTile<ThemeMode>(
                        dense: false,
                        title: Text(
                          langVm.translate('Cerah', 'Light'),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        value: ThemeMode.light,
                      ),
                      RadioListTile<ThemeMode>(
                        dense: false,
                        title: Text(
                          langVm.translate('Gelap', 'Dark'),
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
                  child: Text(langVm.translate('Batal', 'Cancel')),
                ),
                FilledButton(
                  onPressed: () {
                    themeVm.setThemeMode(selected);
                    Navigator.pop(ctx);
                  },
                  child: Text(langVm.translate('Simpan', 'Save')),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
