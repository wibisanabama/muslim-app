import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/theme_view_model.dart';
import 'api_list_page.dart';
import 'licenses_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
          // ─── Tema (top item → rounded top) ───
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
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
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
                subtitle: const Text('API pihak ketiga yang digunakan aplikasi'),
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
