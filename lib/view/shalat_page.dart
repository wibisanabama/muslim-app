import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/shalat_view_model.dart';
import 'shalat_detail_page.dart';

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
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ShalatViewModel>().fetchMonthlySchedule(
              cityId: cityId,
              year: year,
              month: month,
            ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Builder(
            builder: (context) {
              if (vm.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (vm.error != null) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Center(
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
                        ),
                      ),
                    );
                  },
                );
              }

              if (vm.schedules.isEmpty) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: const Center(
                          child: Text('Data kosong'),
                        ),
                      ),
                    );
                  },
                );
              }

              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: vm.schedules.length,
                itemBuilder: (context, i) {
                  final d = vm.schedules[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ShalatDetailPage(schedule: d),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              d.tanggal,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
