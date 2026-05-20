import 'package:flutter/material.dart';
import 'shalat_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    // Halaman Beranda (Polos)
    const Scaffold(
      body: Center(
        child: Text(
          'Halaman Beranda',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
    ),
    
    // Halaman Jadwal Shalat (Menggunakan ShalatPage)
    const ShalatPage(),

    // Halaman Quran (Polos)
    const Scaffold(
      body: Center(
        child: Text(
          'Halaman Quran',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
    ),

    // Halaman Doa (Polos)
    const Scaffold(
      body: Center(
        child: Text(
          'Halaman Doa',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
    ),

    // Halaman Tentang (Polos)
    const Scaffold(
      body: Center(
        child: Text(
          'Halaman Tentang',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.access_time),
            selectedIcon: Icon(Icons.access_time_filled),
            label: 'Jadwal',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Quran',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Doa',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
            label: 'Tentang',
          ),
        ],
      ),
    );
  }
}
