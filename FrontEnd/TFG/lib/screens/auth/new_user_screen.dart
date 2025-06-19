import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:math';

import '../../constants/colors.dart';
import '../../constants/texts.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_styles.dart';
import '../game/game_screen.dart';

class NewUserScreen extends StatefulWidget {
  const NewUserScreen({super.key});

  @override
  State<NewUserScreen> createState() => _NewUserScreenState();
}

class _NewUserScreenState extends State<NewUserScreen> {
  final TextEditingController _nomController = TextEditingController();
  String? errorMessage;
  late String generatedCode;
  String? acceptacio = 'no';

  @override
  void initState() {
    super.initState();
    generatedCode = _generarIdentificador();
  }

  String _generarIdentificador() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();

    String segment() => List.generate(4, (_) => chars[rand.nextInt(chars.length)]).join();

    return '${segment()}-${segment()}-${segment()}';
  }

  Future<void> _comencar() async {
    final nom = _nomController.text.trim();

    if (nom.isEmpty) {
      setState(() => errorMessage = 'Si us plau, introdueix un nom.');
      return;
    }

    if (acceptacio != 'sí') {
      setState(() => errorMessage = "Has d'acceptar les condicions abans de continuar.");
      return;
    }

    setState(() => errorMessage = null);

    final success = await ApiService.crearNouUsuari(nom, generatedCode);

    if (success) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('user_code', generatedCode);
      prefs.setString('user_nom', nom);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GameScreen()),
      );
    } else {
      setState(() => errorMessage = "Error creant l'usuari. Torna-ho a intentar.");
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
            Image.asset(
              'assets/images/icona_app.png',
              height: 28,
            ),
            const SizedBox(width: 8),
            const Text(
              'TerritoCAT',
              style: TextStyle(color: AppColors.groc),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Text(
                AppTexts.titolBenvinguda,
                style: TextStyle(fontSize: 26, color: AppColors.blau),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(AppTexts.nomInstruccio, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              TextField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              const Text(AppTexts.instruccioIdentificador, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    generatedCode,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: generatedCode));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                'Les fotografies que realitzis seran utilitzades per enriquir la Xarxa Arxius Comarcals de Catalunya. Les imatges podran ser visualitzades per altres usuaris un cop conquerit el punt.',
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Accepto'),
                      value: 'sí',
                      groupValue: acceptacio,
                      onChanged: (val) => setState(() => acceptacio = val),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('No accepto'),
                      value: 'no',
                      groupValue: acceptacio,
                      onChanged: (val) => setState(() => acceptacio = val),
                    ),
                  ),
                ],
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
                onPressed: _comencar,
                child: const Text(AppTexts.botoComencar, style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
