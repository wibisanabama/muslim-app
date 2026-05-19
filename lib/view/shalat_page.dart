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

            return ListView.separated(
              itemCount: vm.schedules.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final d = vm.schedules[i];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.tanggal,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _row('Imsak', d.imsak),
                        _row('Subuh', d.subuh),
                        _row('Terbit', d.terbit),
                        _row('Dhuha', d.dhuha),
                        _row('Dzuhur', d.dzuhur),
                        _row('Ashar', d.ashar),
                        _row('Maghrib', d.maghrib),
                        _row('Isya', d.isya),
                      ],
                    ),
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

Widget _row(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        SizedBox(width: 80, child: Text(label)),
        const Text(': '),
        Expanded(child: Text(value.isEmpty ? '-' : value)),
      ],
    ),
  );
}
