import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/shalat_view_model.dart';

class ShalatPage extends StatefulWidget {
  static const routeName = '/shalat';
  const ShalatPage({super.key});

  @override
  State<ShalatPage> createState() => _ShalatPageState();
}

class _ShalatPageState extends State<ShalatPage> {
  // sesuai API yang kamu kasih:
  final int cityId = 1206;
  final int year = 2025;
  final int month = 1;

  @override
  void initState() {
    super.initState();
    // panggil setelah build pertama supaya aman akses context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShalatViewModel>().fetchMonthlySchedule(
            cityId: cityId,
            year: year,
            month: month,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShalatViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Shalat'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () =>
                context.read<ShalatViewModel>().fetchMonthlySchedule(
                      cityId: cityId,
                      year: year,
                      month: month,
                    ),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Builder(
          builder: (_) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (vm.error != null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Gagal memuat data:\n${vm.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () =>
                          context.read<ShalatViewModel>().fetchMonthlySchedule(
                                cityId: cityId,
                                year: year,
                                month: month,
                              ),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }

            if (vm.schedules.isEmpty) {
              return const Center(child: Text('Data kosong'));
            }

            return ListView.builder(
              itemCount: vm.schedules.length,
              itemBuilder: (context, i) {
                final d = vm.schedules[i];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          d.tanggal,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('Imsak'),
                        trailing: Text(d.imsak),
                      ),
                      ListTile(
                        title: const Text('Subuh'),
                        trailing: Text(d.subuh),
                      ),
                      ListTile(
                        title: const Text('Terbit'),
                        trailing: Text(d.terbit),
                      ),
                      ListTile(
                        title: const Text('Dhuha'),
                        trailing: Text(d.dhuha),
                      ),
                      ListTile(
                        title: const Text('Dzuhur'),
                        trailing: Text(d.dzuhur),
                      ),
                      ListTile(
                        title: const Text('Ashar'),
                        trailing: Text(d.ashar),
                      ),
                      ListTile(
                        title: const Text('Maghrib'),
                        trailing: Text(d.maghrib),
                      ),
                      ListTile(
                        title: const Text('Isya'),
                        trailing: Text(d.isya),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
