import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/quran_view_model.dart';
import 'quran_detail_page.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuranViewModel>().fetchSurahs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<QuranViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Al-Quran'),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<QuranViewModel>().fetchSurahs(),
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
                                'Gagal memuat data:\n${vm.error}',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: () => context.read<QuranViewModel>().fetchSurahs(),
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

            if (vm.surahs.isEmpty) {
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
              itemCount: vm.surahs.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final s = vm.surahs[i];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(s.nomor.toString()),
                  ),
                  title: Text(s.namaLatin),
                  subtitle: Text('${s.tempatTurun} • ${s.jumlahAyat} Ayat'),
                  trailing: Text(
                    s.nama,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuranDetailPage(
                          nomorSurah: s.nomor,
                          namaLatin: s.namaLatin,
                        ),
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
