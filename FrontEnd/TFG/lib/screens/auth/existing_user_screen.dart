import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/colors.dart';
import '../../constants/texts.dart';
import '../../widgets/custom_styles.dart';
import '../../services/api_service.dart';
import '../game/game_screen.dart';

class ExistingUserScreen extends StatefulWidget {
  const ExistingUserScreen({super.key});

  @override
  State<ExistingUserScreen> createState() => _ExistingUserScreenState();
}

class _ExistingUserScreenState extends State<ExistingUserScreen> {
  final TextEditingController controller = TextEditingController();
  String? errorMessage;

  bool formatCorrecte(String codi) {
    final regex = RegExp(r'^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$');
    return regex.hasMatch(codi);
  }

  Future<void> verificarIdentificador() async {
    final codi = controller.text.trim().toUpperCase();

    setState(() {
      errorMessage = null;
    });

    if (!formatCorrecte(codi)) {
      setState(() {
        errorMessage = AppTexts.formatIncorrecte;
      });
      return;
    }

    final existeix = await ApiService.existeixUsuari(codi);

    if (existeix) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('user_code', codi);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GameScreen()),
      );
    } else {
      setState(() {
        errorMessage = AppTexts.identificadorInexistent;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blau,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.groc),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/icona_app.png', height: 30),
            const SizedBox(width: 8),
            const Text('TerritoCAT', style: TextStyle(color: AppColors.groc)),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                AppTexts.tornada,
                style: TextStyle(fontSize: 26, color: AppColors.blau),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                AppTexts.introdueixIdentificador,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'XXXX-XXXX-XXXX',
                  border: OutlineInputBorder(),
                ),
                textAlign: TextAlign.center,
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  errorMessage!,
                  style: const TextStyle(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 30),
              ElevatedButton(
                style: CustomStyles.botoPrincipal(size: const Size(200, 60)),
                onPressed: verificarIdentificador,
                child: const Text(AppTexts.botoComencar, style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
