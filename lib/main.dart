import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'repository/shalat_repository.dart';
import 'viewmodel/shalat_view_model.dart';
import 'repository/quran_repository.dart';
import 'viewmodel/quran_view_model.dart';
import 'view/splash_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ShalatRepository>(
          create: (_) => ShalatRepository(),
        ),
        ChangeNotifierProvider<ShalatViewModel>(
          create: (context) => ShalatViewModel(
            context.read<ShalatRepository>(),
          ),
        ),
        Provider<QuranRepository>(
          create: (_) => QuranRepository(),
        ),
        ChangeNotifierProvider<QuranViewModel>(
          create: (context) => QuranViewModel(
            context.read<QuranRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Jadwal Shalat MVVM',
        theme: ThemeData(useMaterial3: true),

        // Splash Screen sebagai pintu masuk utama
        home: const SplashPage(),
      ),
    );
  }
}
