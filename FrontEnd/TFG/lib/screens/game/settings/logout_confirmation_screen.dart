import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfg/constants/colors.dart';
import 'package:tfg/constants/texts.dart';
import 'package:tfg/screens/auth/welcome_screen.dart';

class LogoutConfirmationScreen extends StatelessWidget {
  const LogoutConfirmationScreen({super.key});

  Future<void> _tancarSessio(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_code');
    await prefs.remove('user_nom');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blau,
        title: const Text('Tancar sessió', style: TextStyle(color: AppColors.groc)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 20),
            const Text(
              AppTexts.textConfirmacioLogout,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _tancarSessio(context),
              child: const Text(
                'Tancar sessió',
                style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
