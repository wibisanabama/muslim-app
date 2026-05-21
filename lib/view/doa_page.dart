import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/doa_view_model.dart';

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
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => context.read<DoaViewModel>().fetchDoas(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.error != null) {
            return Center(
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
            );
          }

          if (vm.doas.isEmpty) {
            return const Center(child: Text('Data kosong'));
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            itemCount: vm.doas.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, i) {
              final d = vm.doas[i];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    d.doa,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    d.ayat,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    d.latin,
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    d.artinya,
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
