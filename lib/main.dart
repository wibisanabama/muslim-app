import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'repository/shalat_repository.dart';
import 'viewmodel/shalat_view_model.dart';
import 'view/shalat_page.dart';

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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Jadwal Shalat MVVM',
        theme: ThemeData(useMaterial3: true),

        // Langsung ke ShalatPage
        home: const ShalatPage(),
      ),
    );
  }
}
