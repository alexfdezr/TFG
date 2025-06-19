import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/config.dart';

class ApiService {
  /// Crea un nou usuari amb nom i codi generat pel client
  static Future<bool> crearNouUsuari(String nom, String codiUsuari) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/nou_usuari'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nom': nom,
        'codi_usuari': codiUsuari,
      }),
    );

    return response.statusCode == 200;
  }

  /// Verifica si un identificador ja existeix
  static Future<bool> existeixUsuari(String codi) async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/existeix_usuari/$codi'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['existeix'] ?? false;
    }

    return false;
  }

  /// Obté la llista de totes les comarques des del backend
  static Future<List<Map<String, dynamic>>> getComarques() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/comarques'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> dades = json.decode(response.body);
        return dades.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      print('Error obtenint comarques: $e');
      return [];
    }
  }

  /// Obté tots els punts històrics des del backend
  static Future<List<Map<String, dynamic>>> getPunts() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/punts'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> dades = json.decode(response.body);
        return dades.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      print('Error obtenint punts: $e');
      return [];
    }
  }

  /// Obté la llista d'identificadors de punts conquerits per un usuari
  static Future<List<String>> getPuntsConquerits(String codiUsuari) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/conquestes_punts/$codiUsuari'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> dades = json.decode(response.body);
        return dades.cast<String>();
      } else {
        return [];
      }
    } catch (e) {
      print('Error obtenint conquestes: $e');
      return [];
    }
  }

  /// Obté el nom de la comarca a partir de coordenades (lat, lon)
  static Future<String> getComarcaPerCoordenades(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/comarca?lat=$lat&lon=$lon'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['comarca'] ?? 'Desconeguda';
      } else {
        return 'Desconeguda';
      }
    } catch (e) {
      print('Error obtenint comarca per coordenades: $e');
      return 'Desconeguda';
    }
  }

  /// Obté els límits geogràfics (bounds) d'una comarca pel seu nom
  static Future<Map<String, double>?> getBoundsComarca(String nomComarca) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/bounds_comarca/$nomComarca'),
      );

      if (response.statusCode == 200) {
        return Map<String, double>.from(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Error obtenint bounds: $e');
      return null;
    }
  }

  static Future<Map<String, int>> getResumConquestes(String codiUsuari) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/resum_conquestes/$codiUsuari'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'comarques': data['comarques_conquerides'] ?? 0,
          'punts': data['punts_conquerits'] ?? 0,
        };
      } else {
        return {'comarques': 0, 'punts': 0};
      }
    } catch (e) {
      print('Error obtenint resum de conquestes: $e');
      return {'comarques': 0, 'punts': 0};
    }
  }

  /// Envia una foto codificada en base64 per conquerir un punt
  static Future<bool> conquerirPunt({
    required String codiUsuari,
    required String puntId,
    required String fotoBase64,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/conquerir_punt'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'codi_usuari': codiUsuari,
          'punt_id': puntId,
          'foto_base64': fotoBase64,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error conquerint punt: $e');
      return false;
    }
  }

  /// Obté totes les fotografies (històriques i d'usuari) des del backend
  static Future<List<Map<String, dynamic>>> getFotografies() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/fotografies'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> dades = json.decode(response.body);
        return dades.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      print('Error obtenint fotografies: $e');
      return [];
    }
  }

  static Future<Map<String, int>> getPuntsConqueritsComarca(String codiUsuari) async {
    final response = await http.get(Uri.parse('${AppConfig.baseUrl}/punts_conquerits_comarca/$codiUsuari'));

    if (response.statusCode == 200) {
      return Map<String, int>.from(jsonDecode(response.body));
    } else {
      throw Exception('Error obtenint punts conquerits per comarca');
    }
  }

  static Future<Map<String, int>> getPuntsConqueritsPerNom(String codiUsuari) async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/punts_conquerits_comarca/$codiUsuari'),
    );

    if (response.statusCode == 200) {
      return Map<String, int>.from(jsonDecode(response.body));
    } else {
      throw Exception('Error obtenint punts conquerits per comarca');
    }
  }

  static Future<List<Map<String, dynamic>>> getPuntsPerComarca(String nomComarca) async {
    final response = await http.get(Uri.parse('${AppConfig.baseUrl}/punts_comarca/${Uri.encodeComponent(nomComarca)}'));

    if (response.statusCode == 200) {
      final List<dynamic> dades = json.decode(response.body);
      return dades.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Error obtenint els punts de la comarca $nomComarca');
    }
  }

  static Future<List<Map<String, dynamic>>> getRanking() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/ranking'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> dades = json.decode(response.body);
        return dades.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      print('Error obtenint ranking: $e');
      return [];
    }
  }

}
