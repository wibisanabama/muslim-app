import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'repository/shalat_repository.dart';
import 'viewmodel/shalat_view_model.dart';
import 'repository/quran_repository.dart';
import 'viewmodel/quran_view_model.dart';
import 'repository/doa_repository.dart';
import 'viewmodel/doa_view_model.dart';
import 'viewmodel/ramadhan_view_model.dart';
import 'viewmodel/theme_view_model.dart';
import 'view/splash_page.dart';
import 'theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final materialTheme = MaterialTheme(textTheme);

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
        Provider<DoaRepository>(
          create: (_) => DoaRepository(),
        ),
        ChangeNotifierProvider<DoaViewModel>(
          create: (context) => DoaViewModel(
            context.read<DoaRepository>(),
          ),
        ),
        ChangeNotifierProvider<RamadhanViewModel>(
          create: (_) => RamadhanViewModel(),
        ),
        ChangeNotifierProvider<ThemeViewModel>(
          create: (_) => ThemeViewModel(),
        ),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeVm, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Muslim',
            theme: materialTheme.light(),
            darkTheme: materialTheme.dark(),
            themeMode: themeVm.themeMode,

            // Splash Screen sebagai pintu masuk utama
            home: const SplashPage(),
          );
        },
      ),
    );
  }
}

