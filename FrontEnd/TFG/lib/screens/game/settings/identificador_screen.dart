import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import '../../../constants/colors.dart';
import '../../../constants/texts.dart';

class IdentificadorScreen extends StatefulWidget {
  const IdentificadorScreen({super.key});

  @override
  State<IdentificadorScreen> createState() => _IdentificadorScreenState();
}

class _IdentificadorScreenState extends State<IdentificadorScreen> {
  String? codiUsuari;

  @override
  void initState() {
    super.initState();
    carregarCodi();
  }

  Future<void> carregarCodi() async {
    final prefs = await SharedPreferences.getInstance();
    final codi = prefs.getString('user_code') ?? '';
    setState(() => codiUsuari = codi);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blau,
        title: const Text(AppTexts.titolIdentificador, style: TextStyle(color: AppColors.groc)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(AppTexts.textIdentificadorInfo, textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            if (codiUsuari != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(codiUsuari!, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () => Clipboard.setData(ClipboardData(text: codiUsuari!)),
                  ),
                ],
              )
            else
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
