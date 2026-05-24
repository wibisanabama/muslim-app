import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PermissionsPage extends StatelessWidget {
  const PermissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Izin Aplikasi'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          Card.filled(
            margin: EdgeInsets.zero,
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
              title: const Text(
                'Lokasi',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  'Digunakan untuk menentukan jadwal shalat dan arah kiblat secara otomatis.',
                ),
              ),
              trailing: Icon(
                Icons.open_in_new,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                size: 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              onTap: () async {
                await Geolocator.openAppSettings();
              },
            ),
          ),
        ],
      ),
    );
  }
}
