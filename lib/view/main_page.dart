import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/language_view_model.dart';
import 'home_page.dart';
import 'shalat_page.dart';
import 'quran_page.dart';
import 'doa_page.dart';
import 'about_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    // Halaman Beranda
    const HomePage(),
    
    // Halaman Jadwal Shalat (Menggunakan ShalatPage)
    const ShalatPage(),

    // Halaman Quran (Menggunakan QuranPage)
    const QuranPage(),

    // Halaman Doa (Menggunakan DoaPage)
    const DoaPage(),

    // Halaman Tentang (Menggunakan AboutPage)
    const AboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final langVm = context.watch<LanguageViewModel>();

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: langVm.translate('Beranda', 'Home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.access_time),
            selectedIcon: const Icon(Icons.access_time_filled),
            label: langVm.translate('Jadwal', 'Schedule'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: langVm.translate('Quran', 'Quran'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite),
            label: langVm.translate('Doa', 'Doa'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.info_outline),
            selectedIcon: const Icon(Icons.info),
            label: langVm.translate('Tentang', 'About'),
          ),
        ],
      ),
    );
  }
}
