import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import '../../../constants/texts.dart';
import '../../../constants/config.dart';
import '../../../constants/colors.dart';
import '../../../services/api_service.dart';
import '../../../utils/image_utils.dart';

class TakePhotoScreen extends StatefulWidget {
  final String puntId;
  const TakePhotoScreen({super.key, required this.puntId});

  @override
  State<TakePhotoScreen> createState() => _TakePhotoScreenState();
}

class _TakePhotoScreenState extends State<TakePhotoScreen> {
  CameraController? _cameraController;
  late Future<void> _initializeControllerFuture;
  XFile? _image;
  String? _imageBase64;
  bool _sending = false;
  bool _conquerit = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(camera, ResolutionPreset.low);
    _initializeControllerFuture = _cameraController!.initialize();
    await _initializeControllerFuture;
    setState(() {});
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void _ferFoto() async {
    try {
      await _initializeControllerFuture;
      final image = await _cameraController!.takePicture();
      final bytes = kIsWeb
          ? await image.readAsBytes()
          : await File(image.path).readAsBytes();
      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      setState(() {
        _image = image;
        _imageBase64 = base64Image;
      });
    } catch (e) {
      print('Error fent la foto: $e');
    }
  }

  Future<void> _enviarFoto() async {
    if (_imageBase64 == null) return;
    setState(() {
      _sending = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final codiUsuari = prefs.getString('user_code') ?? '';

    final success = await ApiService.conquerirPunt(
      codiUsuari: codiUsuari,
      puntId: widget.puntId,
      fotoBase64: _imageBase64!,
    );

    if (success && mounted) {
      setState(() {
        _image = null;
        _imageBase64 = null;
        _conquerit = true;
      });
    } else {
      print('Error enviant la foto');
    }

    setState(() {
      _sending = false;
    });
  }

  Future<void> _reiniciarCamera() async {
    await _cameraController?.dispose();
    await _initCamera();
    setState(() {
      _image = null;
      _imageBase64 = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.conquerir),
        backgroundColor: AppColors.blau,
      ),
      body: _cameraController == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_conquerit) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.emoji_events, color: AppColors.verd, size: 80),
                    const SizedBox(height: 20),
                    const Text(
                      'Has conquerit el punt! 🏆',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.verd,
                        shadows: [
                          Shadow(blurRadius: 4, color: Colors.black26, offset: Offset(2, 2))
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Felicitats! Has conquerit aquest punt històric!',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blau,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      ),
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      child: const Text(
                        'Tornar al mapa',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          if (_imageBase64 != null) {
            return Stack(
              children: [
                Positioned.fill(
                  child: getImageWidget(_imageBase64!),
                ),
                if (_sending)
                  const Center(child: CircularProgressIndicator()),
                if (!_sending)
                  Positioned(
                    bottom: 30,
                    left: 20,
                    right: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.blau),
                          onPressed: _reiniciarCamera,
                          child: const Text(
                            'Repetir',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.verd),
                          onPressed: _enviarFoto,
                          child: const Text(
                            'Conquerir',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }
          return Stack(
            children: [
              Positioned.fill(
                child: CameraPreview(_cameraController!),
              ),
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Center(
                  child: FloatingActionButton(
                    backgroundColor: AppColors.blau,
                    onPressed: _ferFoto,
                    child: const Icon(Icons.camera_alt),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
