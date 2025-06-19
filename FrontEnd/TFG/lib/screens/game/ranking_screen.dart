import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfg/constants/colors.dart';
import 'package:tfg/services/api_service.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  List<Map<String, dynamic>> usuaris = [];
  String codiUsuari = '';

  @override
  void initState() {
    super.initState();
    _carregarRanking();
  }

  Future<void> _carregarRanking() async {
    final prefs = await SharedPreferences.getInstance();
    final codi = prefs.getString('user_code') ?? '';
    setState(() => codiUsuari = codi);

    final dades = await ApiService.getRanking();
    setState(() => usuaris = dades);
  }

  @override
  Widget build(BuildContext context) {
    final indexJo = usuaris.indexWhere((u) => u['codi_usuari'] == codiUsuari);
    final jo = indexJo != -1 ? usuaris[indexJo] : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blau,
        title: const Text('Classificació', style: TextStyle(color: AppColors.groc, fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: usuaris.length,
              itemBuilder: (context, index) {
                final usuari = usuaris[index];
                final posicio = index + 1;
                final esTop3 = posicio <= 3;
                Color color;
                double mida;
                if (posicio == 1) {
                  color = Colors.amber;
                  mida = 22;
                } else if (posicio == 2) {
                  color = Colors.grey;
                  mida = 20;
                } else if (posicio == 3) {
                  color = Colors.brown;
                  mida = 18;
                } else {
                  color = Colors.grey.shade300;
                  mida = 16;
                }

                final textStyle = TextStyle(
                  fontSize: mida,
                  fontWeight: esTop3 ? FontWeight.bold : FontWeight.normal,
                );

                return Card(
                  color: color,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$posicio.', style: TextStyle(fontSize: mida, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(usuari['nom'], style: textStyle, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        Column(
                          children: [
                            Text('${usuari['comarques']}', style: TextStyle(fontSize: mida - 2)),
                            const Text('Comarques', style: TextStyle(fontSize: 10)),
                          ],
                        ),
                        const SizedBox(width: 10),
                        Column(
                          children: [
                            Text('${usuari['punts']}', style: TextStyle(fontSize: mida - 2)),
                            const Text('Punts', style: TextStyle(fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (jo != null)
            Positioned(
              bottom: 10,
              left: 16,
              right: 16,
              child: Card(
                color: AppColors.blau,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${indexJo + 1}.', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(jo['nom'] ?? '', style: const TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      Column(
                        children: [
                          Text('${jo['comarques'] ?? 0}', style: const TextStyle(color: Colors.white)),
                          const Text('Comarques', style: TextStyle(fontSize: 10, color: Colors.white)),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Column(
                        children: [
                          Text('${jo['punts'] ?? 0}', style: const TextStyle(color: Colors.white)),
                          const Text('Punts', style: TextStyle(fontSize: 10, color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
