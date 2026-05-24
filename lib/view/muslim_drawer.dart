import 'package:flutter/material.dart';
import 'settings_page.dart';

class MuslimDrawer extends StatelessWidget {
  const MuslimDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 24.0,
                top: 24.0,
                bottom: 16.0,
              ),
              child: Text(
                'Muslim',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
              leading: const Icon(Icons.settings_outlined),
              title: const Text(
                'Pengaturan',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
