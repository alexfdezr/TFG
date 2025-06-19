import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:tfg/constants/colors.dart';
import 'package:tfg/screens/game/collection_screen.dart';
import 'package:tfg/screens/game/map_screen.dart';
import 'package:tfg/screens/game/settings_screen.dart';
import 'package:tfg/screens/game/ranking_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _selectedIndex = 2; // Ara s'inicia al mapa

  final MapController _mapController = MapController();

  late final List<Widget> _screens = [
    const RankingScreen(),
    CollectionScreen(mapController: _mapController),
    MapScreen(mapController: _mapController),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.groc,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        currentIndex: _selectedIndex,
        backgroundColor: AppColors.blau,
        selectedItemColor: AppColors.groc,
        unselectedItemColor: AppColors.groc.withOpacity(0.5),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: 28,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Classificació',
          ),
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
