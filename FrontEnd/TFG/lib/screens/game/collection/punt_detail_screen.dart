import 'package:flutter/material.dart';
import 'package:tfg/constants/colors.dart';
import 'package:tfg/constants/texts.dart';
import 'package:tfg/services/api_service.dart';
import 'package:tfg/utils/image_utils.dart';
import 'package:tfg/screens/shared/fullscreen_image_viewer.dart';

class PuntDetailScreen extends StatefulWidget {
  final Map<String, dynamic> punt;
  final bool conquerit;
  final String codiUsuari;

  const PuntDetailScreen({super.key, required this.punt, required this.conquerit, required this.codiUsuari});

  @override
  State<PuntDetailScreen> createState() => _PuntDetailScreenState();
}

class _PuntDetailScreenState extends State<PuntDetailScreen> {
  Map<String, String> fotoUsuari = {};
  Map<String, List<String>> fotosAltres = {};

  @override
  void initState() {
    super.initState();
    if (widget.conquerit) _carregarFotos();
  }

  Future<void> _carregarFotos() async {
    final fotos = await ApiService.getFotografies();
    final meves = <String, String>{};
    final altres = <String, List<String>>{};
    final id = widget.punt['nom'];

    for (final f in fotos) {
      if (f['punt_id'] == id && f['tipus'] == 'usuari') {
        if (f['codi_usuari'] == widget.codiUsuari) {
          meves[id] = f['foto_base64'];
        } else {
          altres.putIfAbsent(id, () => []).add(f['foto_base64']);
        }
      }
    }

    setState(() {
      fotoUsuari = meves;
      fotosAltres = altres;
    });
  }

  void _obrirImatges(List<String> imatges, int indexInicial) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullscreenImageViewer(images: imatges, initialIndex: indexInicial),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fotos = widget.punt['foto_urls'] ?? [];
    final fotoMeva = fotoUsuari[widget.punt['nom']];
    final altresFotos = fotosAltres[widget.punt['nom']] ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blau,
        title: Text(widget.punt['nom'], style: const TextStyle(color: AppColors.groc)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.punt['descripcio'] ?? '', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              if (widget.conquerit && fotos.isNotEmpty) ...[
                const Text("Fotografies històriques:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: fotos.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () => _obrirImatges(List<String>.from(fotos), index),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: getImageWidget(fotos[index], width: 160),
                      ),
                    ),
                  ),
                ),
              ],
              if (widget.conquerit && altresFotos.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text("Fotografies dels usuaris:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: altresFotos.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () => _obrirImatges(altresFotos, index),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: getImageWidget(altresFotos[index], width: 160),
                      ),
                    ),
                  ),
                ),
              ],
              if (widget.conquerit && fotoMeva != null) ...[
                const SizedBox(height: 16),
                const Center(child: Text("La teva fotografia:", style: TextStyle(fontWeight: FontWeight.bold))),
                const SizedBox(height: 10),
                Center(
                  child: GestureDetector(
                    onTap: () => _obrirImatges([fotoMeva], 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: getImageWidget(fotoMeva, width: 220),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Center(
                child: Text(
                  widget.conquerit ? 'Punt conquerit!' : 'Aquest punt encara no ha estat conquerit.',
                  style: TextStyle(
                    color: widget.conquerit ? AppColors.verd : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
