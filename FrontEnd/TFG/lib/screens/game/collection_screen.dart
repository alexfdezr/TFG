import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/colors.dart';
import '../../services/api_service.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  List<Map<String, dynamic>> comarques = [];
  String? userName;
  Map<String, int> resum = {'comarques': 0, 'punts': 0};

  @override
  void initState() {
    super.initState();
    carregarDades();
  }

  Future<void> carregarDades() async {
    final prefs = await SharedPreferences.getInstance();
    final nom = prefs.getString('user_nom') ?? '';
    final codi = prefs.getString('user_code') ?? '';
    final llista = await ApiService.getComarques();
    final dadesResum = await ApiService.getResumConquestes(codi);

    setState(() {
      userName = nom;
      resum = dadesResum;
      comarques = llista.map((e) => {
        'nom': e['nom'],
        'conquerides': 0,
        'totals': 5,
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blau,
        title: Text('Col·lecció de ${userName ?? ""}',
            style: const TextStyle(color: AppColors.groc)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: comarques.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.blau,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Comarques conquerides',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${resum['comarques']}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.blau,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Punts conquerits',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${resum['punts']}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: comarques.length,
              padding: const EdgeInsets.all(16),
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final comarca = comarques[index];
                return ListTile(
                  title: Text(comarca['nom']),
                  trailing: Text(
                    '${comarca['conquerides']} / ${comarca['totals']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
