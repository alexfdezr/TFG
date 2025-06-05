import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import 'settings/qui_som_screen.dart';
import 'settings/informacio_legal_screen.dart';
import 'settings/instruccions_screen.dart';
import 'settings/identificador_screen.dart';
import 'settings/notificacions_screen.dart';

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
        'titol': 'Notificacions',
        'pantalla': const NotificacionsScreen(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blau,
        title: const Text('Configuració', style: TextStyle(color: AppColors.groc)),
        centerTitle: true,
        automaticallyImplyLeading: false, // <- elimina el botó enrere
      ),
      body: ListView.separated(
        itemCount: opcions.length,
        padding: const EdgeInsets.all(16),
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final opcio = opcions[index];
          return ListTile(
            title: Text(opcio['titol']),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => opcio['pantalla']),
              );
            },
          );
        },
      ),
    );
  }
}
