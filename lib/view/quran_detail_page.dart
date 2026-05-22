import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/quran_view_model.dart';

class QuranDetailPage extends StatefulWidget {
  final int nomorSurah;
  final String namaLatin;

  const QuranDetailPage({
    super.key,
    required this.nomorSurah,
    required this.namaLatin,
  });

  @override
  State<QuranDetailPage> createState() => _QuranDetailPageState();
}

class _QuranDetailPageState extends State<QuranDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuranViewModel>().fetchSurahDetail(widget.nomorSurah);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<QuranViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.namaLatin),
        centerTitle: false,
      ),
      body: Builder(
        builder: (context) {
          if (vm.isDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.detailError != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Gagal memuat detail surat:\n${vm.detailError}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => context
                          .read<QuranViewModel>()
                          .fetchSurahDetail(widget.nomorSurah),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final detail = vm.surahDetail;
          if (detail == null) {
            return const Center(child: Text('Data detail tidak ditemukan'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            itemCount: detail.ayat.length,
            itemBuilder: (context, index) {
              final a = detail.ayat[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            child: Text(
                              a.nomorAyat.toString(),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        a.teksArab,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.8,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        a.teksLatin,
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        a.teksIndonesia,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
