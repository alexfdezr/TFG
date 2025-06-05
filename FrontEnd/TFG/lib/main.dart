import 'package:flutter/material.dart';
import 'constants/colors.dart';
import 'screens/auth/welcome_screen.dart';

void main() {
  runApp(const TerritoCatApp());
}

class TerritoCatApp extends StatelessWidget {
  const TerritoCatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TerritoCat',
      theme: ThemeData(
        primaryColor: AppColors.groc,
        scaffoldBackgroundColor: AppColors.groc,
      ),
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(),
    );
  }
}
