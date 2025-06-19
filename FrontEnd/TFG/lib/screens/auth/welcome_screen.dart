import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/texts.dart';
import '../../widgets/custom_styles.dart';
import 'new_user_screen.dart';
import 'existing_user_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  AppTexts.titolBenvinguda,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blau,
                  ),
                  textAlign: TextAlign.center,
                ),
                Image.asset(
                  'assets/images/icona_app.png',
                  height: 180,
                ),
                Column(
                  children: [
                    ElevatedButton(
                      style: CustomStyles.botoPrincipal(),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NewUserScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        AppTexts.botoNouUsuari,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: CustomStyles.botoPrincipal(),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ExistingUserScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        AppTexts.botoUsuariExistent,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'TerritoCAT v1.0 - juny 2025',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
