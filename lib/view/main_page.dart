import 'package:flutter/material.dart';
import 'home_page.dart';
import 'shalat_page.dart';
import 'quran_page.dart';
import 'doa_page.dart';
import 'about_page.dart';
import 'muslim_drawer.dart';
import 'auth_dialogs.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(scaffoldKey: _scaffoldKey),
      ShalatPage(scaffoldKey: _scaffoldKey),
      QuranPage(scaffoldKey: _scaffoldKey),
      DoaPage(scaffoldKey: _scaffoldKey),
      AboutPage(scaffoldKey: _scaffoldKey),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const MuslimDrawer(),
      endDrawer: const ProfileDrawer(),
      drawerEnableOpenDragGesture: false,
      endDrawerEnableOpenDragGesture: false,
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