import 'package:flutter/material.dart';
import 'licenses_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          Card.filled(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
              leading: const Icon(Icons.description_outlined),
              title: const Text(
                'Licenses',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Open-source software licenses'),
              trailing: Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
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
}
