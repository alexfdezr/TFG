import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import 'settings/qui_som_screen.dart';
import 'settings/informacio_legal_screen.dart';
import 'settings/instruccions_screen.dart';
import 'settings/identificador_screen.dart';
import 'settings/logout_confirmation_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> opcions = [
      {
        'titol': 'Qui som',
        'pantalla': const QuiSomScreen(),
      },
      {
        'titol': 'Informació legal',
        'pantalla': const InformacioLegalScreen(),
      },
      {
        'titol': 'Instruccions',
        'pantalla': const InstruccionsScreen(),
      },
      {
        'titol': 'El meu identificador',
        'pantalla': const IdentificadorScreen(),
      },
      {
        'titol': 'Tancar sessió',
        'pantalla': const LogoutConfirmationScreen(),
        'color': AppColors.error,
        'icona': Icons.logout,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blau,
        title: const Text('Configuració', style: TextStyle(color: AppColors.groc, fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: opcions.length,
              padding: const EdgeInsets.all(16),
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final opcio = opcions[index];
                return ListTile(
                  title: Text(
                    opcio['titol'],
                    style: TextStyle(
                      color: opcio['color'] == AppColors.error ? AppColors.error : null,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Icon(
                    opcio['icona'] ?? Icons.arrow_forward_ios,
                    color: opcio['color'] == AppColors.error ? AppColors.error : null,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => opcio['pantalla']),
                    );
                  },
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Center(
              child: Text(
                'TerritoCAT v1.0 - juny 2025',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
