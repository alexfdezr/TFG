import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/colors.dart';
import '../../constants/texts.dart';
import '../../services/api_service.dart';
import '../../utils/image_utils.dart';
import 'mapa/search_comarca_screen.dart';
import 'mapa/take_photo_screen.dart';
import '../shared/fullscreen_image_viewer.dart';

class MapScreen extends StatefulWidget {
  final MapController mapController;

  const MapScreen({super.key, required this.mapController});

  @override
  State<MapScreen> createState() => _MapScreenState();
}


class _MapScreenState extends State<MapScreen> {
  LatLng? currentPosition;
  LatLng? centerPosition;
  List<Marker> markers = [];
  String? codiUsuari;
  List<String> conquestes = [];
  Map<String, String> fotosUsuari = {};
  Map<String, List<String>> fotosAltresUsuaris = {};
  final double distanciaMaxima = 25.0;
  final MapController _mapController = MapController();
  bool showRecenterButton = false;

  String comarcaActual = '';
  int puntsConquerits = 0;
  bool comarcaConquerida = false;

  @override
  void initState() {
    super.initState();
    _inicialitzar();
  }

  Future<void> _inicialitzar() async {
    await _recuperarCodiUsuari();
    await _determinePosition();

    await Future.wait([
      _carregarPunts(),
      _carregarFotosUsuari(),
      _actualitzarComarca(),
    ]);
  }

  Future<void> _recuperarCodiUsuari() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      codiUsuari = prefs.getString('user_code');
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showMessage(AppTexts.localitzacioDesactivada);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showMessage(AppTexts.permisDenegat);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showMessage(AppTexts.permisDenegatPermanent);
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      currentPosition = LatLng(position.latitude, position.longitude);
      centerPosition = currentPosition;
    });
  }

  Future<void> _carregarPunts() async {
    final punts = await ApiService.getPunts();
    conquestes = await ApiService.getPuntsConquerits(codiUsuari ?? '');
    const Distance distance = Distance();

    final nousMarkers = punts.map((punt) {
      final lat = punt['coordenades']['coordinates'][1];
      final lng = punt['coordenades']['coordinates'][0];
      final LatLng pos = LatLng(lat, lng);
      final String id = punt['nom'];
      final bool conquerit = conquestes.contains(id);

      final double? dist = currentPosition != null
          ? distance(pos, currentPosition!)
          : null;

      Color color;
      if (conquerit) {
        color = AppColors.verd;
      } else if (dist != null && dist <= distanciaMaxima) {
        color = Colors.blue;
      } else {
        color = Colors.grey;
      }

      return Marker(
        point: pos,
        width: 30,
        height: 30,
        child: GestureDetector(
          onTap: () => _mostrarPopup(context, punt, conquerit, dist),
          child: Icon(Icons.location_on, color: color, size: 30),
        ),
      );
    }).toList();

    setState(() {
      markers = nousMarkers;
    });
  }

  Future<void> _carregarFotosUsuari() async {
    final totesFotos = await ApiService.getFotografies();
    final conquestesSet = conquestes.toSet();

    final fotosMeves = <String, String>{};
    final fotosAltres = <String, List<String>>{};

    for (final f in totesFotos) {
      final puntId = f['punt_id'];
      if (f['tipus'] == 'usuari' && conquestesSet.contains(puntId)) {
        if (f['codi_usuari'] == codiUsuari) {
          fotosMeves[puntId] = f['foto_base64'];
        } else {
          fotosAltres.putIfAbsent(puntId, () => []).add(f['foto_base64']);
        }
      }
    }

    setState(() {
      fotosUsuari = fotosMeves;
      fotosAltresUsuaris = fotosAltres;
    });
  }

  Future<void> _actualitzarComarca() async {
    final coords = currentPosition;
    if (coords == null || codiUsuari == null) return;

    final futures = await Future.wait([
      ApiService.getComarcaPerCoordenades(coords.latitude, coords.longitude),
      ApiService.getPuntsConqueritsPerNom(codiUsuari!),
    ]);

    final comarcaNom = futures[0] as String;
    final conquestesPerComarca = futures[1] as Map<String, int>;

    final numPunts = conquestesPerComarca[comarcaNom] ?? 0;

    setState(() {
      comarcaActual = comarcaNom;
      puntsConquerits = numPunts;
      comarcaConquerida = numPunts >= 5;
    });
  }

  void _mostrarPopup(BuildContext context, Map<String, dynamic> punt, bool conquerit, double? dist) {
    final bool aprop = dist != null && dist <= distanciaMaxima;
    final fotos = punt['foto_urls'] ?? [];
    final fotoUsuari = fotosUsuari[punt['nom']];
    final fotosAltres = fotosAltresUsuaris[punt['nom']] ?? [];

    void obrirVisor(List<String> imatges, int indexInicial) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FullscreenImageViewer(images: imatges, initialIndex: indexInicial),
        ),
      );
    }

    showModalBottomSheet(
      backgroundColor: AppColors.groc,
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(punt['nom'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(punt['descripcio'] ?? ''),
                const SizedBox(height: 16),
                if (aprop || conquerit) ...[
                  const Text("Fotografies històriques:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: fotos.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) => GestureDetector(
                        onTap: () => obrirVisor(fotos.cast<String>(), index),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: getImageWidget(fotos[index], width: 160),
                        ),
                      ),
                    ),
                  ),
                ],
                if (conquerit && fotosAltres.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text("Fotografies dels usuaris:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: fotosAltres.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) => GestureDetector(
                        onTap: () => obrirVisor(fotosAltres, index),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: getImageWidget(fotosAltres[index], width: 160),
                        ),
                      ),
                    ),
                  ),
                ],
                if (conquerit && fotoUsuari != null) ...[
                  const SizedBox(height: 16),
                  const Center(child: Text("La teva fotografia:", style: TextStyle(fontWeight: FontWeight.bold))),
                  const SizedBox(height: 10),
                  Center(
                    child: GestureDetector(
                      onTap: () => obrirVisor([fotoUsuari], 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: getImageWidget(fotoUsuari, width: 220),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (conquerit)
                  const Center(child: Text("Punt conquerit!", style: TextStyle(color: AppColors.verd, fontWeight: FontWeight.bold)))
                else if (aprop)
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        final conquerit = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TakePhotoScreen(puntId: punt['nom']),
                          ),
                        );
                        if (conquerit == true) {
                          await _carregarPunts();
                          await _carregarFotosUsuari();
                          await _actualitzarComarca();
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: const Text(AppTexts.conquerir, style: TextStyle(color: Colors.white)),
                    ),
                  )
                else
                  const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange),
                      SizedBox(width: 8),
                      Flexible(child: Text(AppTexts.apropatPerConquerir)),
                    ],
                  )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  void _anarABuscador() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SearchComarcaScreen(mapController: _mapController)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showCenterButton = showRecenterButton;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blau,
        title: const Text('TerritoCAT', style: TextStyle(color: AppColors.groc, fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: currentPosition!,
              initialZoom: 17.0,
              onPositionChanged: (pos, hasGesture) {
                final moved = pos.center != currentPosition;
                if (moved != showRecenterButton) {
                  setState(() {
                    showRecenterButton = moved;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'cat.uab.territocat',
              ),
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 40,
                  size: const Size(30, 30),
                  markers: markers,
                  builder: (context, cluster) {
                    return Center(
                      child: Text(
                        '${cluster.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    );
                  },
                ),
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: currentPosition!,
                    width: 25,
                    height: 25,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1.2),
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeInOut,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.withOpacity(0.3),
                            ),
                            child: Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      onEnd: () => setState(() {}), // reinicia animació
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (showCenterButton)
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Center(
                child: TextButton(
                  onPressed: () {
                    _mapController.move(currentPosition!, 17.0);
                    setState(() {
                      showRecenterButton = false;
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    'Tornar a la posició actual',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 20,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: comarcaConquerida ? AppColors.verd : Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    comarcaActual,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    comarcaConquerida ? 'Conquerida!' : '$puntsConquerits / 5',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: _anarABuscador,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.search, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
