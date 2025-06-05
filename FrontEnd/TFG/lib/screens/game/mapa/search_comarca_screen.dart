import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../../constants/colors.dart';
import '../../../services/api_service.dart';

class SearchComarcaScreen extends StatefulWidget {
  final MapController mapController;

  const SearchComarcaScreen({super.key, required this.mapController});

  @override
  State<SearchComarcaScreen> createState() => _SearchComarcaScreenState();
}

class _SearchComarcaScreenState extends State<SearchComarcaScreen> {
  List<String> comarques = [];
  List<String> comarquesFiltrades = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarComarques();
  }

  Future<void> _carregarComarques() async {
    final llista = await ApiService.getComarques();
    final noms = llista.map((c) => c['nom'] as String).toList()..sort();
    setState(() {
      comarques = noms;
      comarquesFiltrades = noms;
    });
  }

  void _filtrarComarques(String query) {
    setState(() {
      comarquesFiltrades = comarques
          .where((c) => c.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _centrarComarca(String nomComarca) async {
    final bounds = await ApiService.getBoundsComarca(nomComarca);
    if (bounds != null) {
      final LatLngBounds zona = LatLngBounds(
        LatLng(bounds['minLat'] as double, bounds['minLng'] as double),
        LatLng(bounds['maxLat'] as double, bounds['maxLng'] as double),
      );
      Navigator.pop(context); // Tornar enrere al mapa
      widget.mapController.fitBounds(zona, options: const FitBoundsOptions(padding: EdgeInsets.all(50)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blau,
        title: const Text('Cerca comarca', style: TextStyle(color: AppColors.groc)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.groc),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              onChanged: _filtrarComarques,
              decoration: InputDecoration(
                hintText: 'Escriu una comarca...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: comarquesFiltrades.length,
              itemBuilder: (context, index) {
                final comarca = comarquesFiltrades[index];
                return ListTile(
                  title: Text(comarca),
                  onTap: () => _centrarComarca(comarca),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
