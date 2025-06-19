import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/colors.dart';
import '../../services/api_service.dart';
import 'collection/comarca_detail_screen.dart';

class CollectionScreen extends StatefulWidget {
  final MapController mapController;

  const CollectionScreen({super.key, required this.mapController});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  List<Map<String, dynamic>> comarques = [];
  Map<String, int> conquestesPerComarca = {};
  String? userName;
  String? userCode;
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
    final conquestes = await ApiService.getPuntsConqueritsPerNom(codi);

    setState(() {
      userName = nom;
      userCode = codi;
      resum = dadesResum;
      conquestesPerComarca = conquestes;
      comarques = llista.map((e) {
        final nom = e['nom'];
        final conquerits = conquestes[nom] ?? 0;
        return {
          'nom': nom,
          'conquerides': conquerits,
          'totals': 5,
        };
      }).toList();
    });
  }

  Future<void> centrarComarca(String nomComarca) async {
    final bounds = await ApiService.getBoundsComarca(nomComarca);
    if (bounds != null) {
      final zona = LatLngBounds(
        LatLng(bounds['minLat'] as double, bounds['minLng'] as double),
        LatLng(bounds['maxLat'] as double, bounds['maxLng'] as double),
      );
      widget.mapController.fitBounds(
        zona,
        options: const FitBoundsOptions(padding: EdgeInsets.all(50)),
      );
    }
  }

  void obrirDetallComarca(String nomComarca) {
    if (userCode == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ComarcaDetailScreen(comarca: nomComarca, codiUsuari: userCode!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blau,
        title: Text('Col·lecció de ${userName ?? ""}',
            style: const TextStyle(color: AppColors.groc, fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: comarques.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${resum['comarques']}',
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
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
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${resum['punts']}',
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
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
                final conquerides = comarca['conquerides'];
                final totals = comarca['totals'];
                final conquerida = conquerides >= totals;

                return GestureDetector(
                  onTap: () => obrirDetallComarca(comarca['nom']),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: conquerida ? AppColors.verd : Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          comarca['nom'],
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          conquerida ? 'Conquerida!' : '$conquerides / $totals',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
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
