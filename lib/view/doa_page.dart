import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/doa_view_model.dart';
import 'doa_detail_page.dart';

class DoaPage extends StatefulWidget {
  const DoaPage({super.key});

  @override
  State<DoaPage> createState() => _DoaPageState();
}

class _DoaPageState extends State<DoaPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoaViewModel>().fetchDoas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DoaViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doa Harian'),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<DoaViewModel>().fetchDoas(),
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
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Gagal memuat data doa:\n${vm.error}',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: () => context.read<DoaViewModel>().fetchDoas(),
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }

            if (vm.doas.isEmpty) {
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

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: vm.doas.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final d = vm.doas[i];
                return ListTile(
                  title: Text(
                    d.doa,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DoaDetailPage(doa: d),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
