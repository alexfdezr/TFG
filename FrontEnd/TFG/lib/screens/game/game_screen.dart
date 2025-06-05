import 'package:flutter/material.dart';
import 'package:tfg/constants/colors.dart';
import 'package:tfg/screens/game/collection_screen.dart';
import 'package:tfg/screens/game/map_screen.dart';
import 'package:tfg/screens/game/settings_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _selectedIndex = 1;

  final List<Widget> _screens = [
    const CollectionScreen(),
    const MapScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: AppColors.blau,
        selectedItemColor: AppColors.groc,
        unselectedItemColor: AppColors.groc.withOpacity(0.5),
        showUnselectedLabels: false,
        showSelectedLabels: false,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.collections),
            label: 'Col·lecció',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuració',
          ),
        ],
      ),
    );
  }
}
