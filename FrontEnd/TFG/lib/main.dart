import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants/colors.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/game/game_screen.dart';

void main() {
  runApp(const TerritoCatApp());
}

class TerritoCatApp extends StatelessWidget {
  const TerritoCatApp({super.key});

  Future<Widget> _detectarPantallaInicial() async {
    final prefs = await SharedPreferences.getInstance();
    final codiUsuari = prefs.getString('user_code');
    return codiUsuari != null ? const GameScreen() : const WelcomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TerritoCAT',
      theme: ThemeData(
        primaryColor: AppColors.groc,
        scaffoldBackgroundColor: AppColors.groc,
      ),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Widget>(
        future: _detectarPantallaInicial(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            return snapshot.data!;
          }
        },
      ),
    );
  }
}
