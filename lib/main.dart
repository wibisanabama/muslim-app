import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'repository/shalat_repository.dart';
import 'viewmodel/shalat_view_model.dart';
import 'repository/quran_repository.dart';
import 'viewmodel/quran_view_model.dart';
import 'repository/doa_repository.dart';
import 'viewmodel/doa_view_model.dart';
import 'repository/asmaul_husna_repository.dart';
import 'viewmodel/ramadhan_view_model.dart';
import 'viewmodel/theme_view_model.dart';
import 'repository/auth_repository.dart';
import 'viewmodel/auth_view_model.dart';
import 'view/splash_page.dart';
import 'theme.dart';
import 'utils/logger.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  AppLogger.init();

  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

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
        Provider<ShalatRepository>(create: (_) => ShalatRepository()),
        ChangeNotifierProvider<ShalatViewModel>(
          create: (context) =>
              ShalatViewModel(context.read<ShalatRepository>()),
        ),
        Provider<QuranRepository>(create: (_) => QuranRepository()),
        ChangeNotifierProvider<QuranViewModel>(
          create: (context) => QuranViewModel(context.read<QuranRepository>()),
        ),
        Provider<DoaRepository>(create: (_) => DoaRepository()),
        ChangeNotifierProvider<DoaViewModel>(
          create: (context) => DoaViewModel(context.read<DoaRepository>()),
        ),
        Provider<AsmaulHusnaRepository>(create: (_) => AsmaulHusnaRepository()),
        ChangeNotifierProvider<RamadhanViewModel>(
          create: (_) => RamadhanViewModel(),
        ),
        ChangeNotifierProvider<ThemeViewModel>(create: (_) => ThemeViewModel()),
        Provider<AuthRepository>(create: (_) => AuthRepository()),
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(
            repository: context.read<AuthRepository>(),
          ),
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
            home: const SplashPage(),
          );
        },
      ),
    );
  }
}