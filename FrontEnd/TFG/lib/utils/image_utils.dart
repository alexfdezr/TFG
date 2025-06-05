import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants/config.dart';

/// Retorna imatge adequada segons el tipus de font:
/// - Base64 -> Image.memory
/// - URL    -> proxy a Image.network
/// - Arxiu  -> Image.file (només si no és Web)
Widget getImageWidget(String font, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
}) {
  if (font.startsWith('data:image')) {
    // Imatge codificada en base64
    try {
      final base64Str = font.split(',').last;
      final bytes = base64Decode(base64Str);
      return Image.memory(bytes, width: width, height: height, fit: fit);
    } catch (e) {
      return const Icon(Icons.broken_image);
    }
  } else if (font.startsWith('http://') || font.startsWith('https://')) {
    // Imatge remota, fem servir el proxy
    final proxiedUrl = '${AppConfig.baseUrl}/proxy_imatge?url=${Uri.encodeComponent(font)}';
    return Image.network(
      proxiedUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.broken_image);
      },
    );
  } else if (!kIsWeb && File(font).existsSync()) {
    // Imatge local (només a Android/iOS)
    return Image.file(File(font), width: width, height: height, fit: fit);
  } else {
    return const Icon(Icons.broken_image);
  }
}
