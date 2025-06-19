import 'package:flutter/material.dart';
import 'package:tfg/constants/colors.dart';
import 'package:tfg/services/api_service.dart';
import 'punt_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComarcaDetailScreen extends StatefulWidget {
  final String comarca;
  final String codiUsuari;

  const ComarcaDetailScreen({super.key, required this.comarca, required this.codiUsuari});

  @override
  State<ComarcaDetailScreen> createState() => _ComarcaDetailScreenState();
}

class _ComarcaDetailScreenState extends State<ComarcaDetailScreen> {
  List<Map<String, dynamic>> punts = [];
  List<String> conquestes = [];

  @override
  void initState() {
    super.initState();
    carregarDades();
  }

  Future<void> carregarDades() async {
    final puntsComarca = await ApiService.getPuntsPerComarca(widget.comarca);
    conquestes = await ApiService.getPuntsConquerits(widget.codiUsuari);

    setState(() {
      punts = puntsComarca;
    });
  }

  @override
  Widget build(BuildContext context) {
    final conquerits = punts.where((p) => conquestes.contains(p['nom'])).toList();
    final noConquerits = punts.where((p) => !conquestes.contains(p['nom'])).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blau,
        title: Text(widget.comarca, style: const TextStyle(color: AppColors.groc)),
        centerTitle: true,
      ),
      body: punts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.blau,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'Punts conquerits: ${conquerits.length} / ${punts.length}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          if (conquerits.isNotEmpty) const Text('Punts conquerits:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...conquerits.map((punt) => _buildPuntItem(punt, true)),
          const SizedBox(height: 16),
          if (noConquerits.isNotEmpty) const Text('Punts no conquerits:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...noConquerits.map((punt) => _buildPuntItem(punt, false)),
        ],
      ),
    );
  }

  Widget _buildPuntItem(Map<String, dynamic> punt, bool conquerit) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PuntDetailScreen(
            punt: punt,
            conquerit: conquerit,
            codiUsuari: widget.codiUsuari,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: conquerit ? AppColors.verd : Colors.grey,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(punt['nom'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            Text(
              conquerit ? 'Conquerit!' : 'No conquerit',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
