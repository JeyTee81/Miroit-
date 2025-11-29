import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vitrages/projet_vitrage_model.dart';
import '../models/vitrages/calcul_vitrage_model.dart';
import '../models/vitrages/region_vent_neige_model.dart';
import '../models/vitrages/categorie_terrain_model.dart';
import 'config_service.dart';

class VitragesService {

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    };
  }

  // Projets
  Future<List<ProjetVitrage>> getProjets({String? chantierId}) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/vitrages';
      final headers = await _getHeaders();
      String url = '$baseUrl/projets/';
      if (chantierId != null) url += '?chantier=$chantierId';

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => ProjetVitrage.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<ProjetVitrage> createProjet(ProjetVitrage projet) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/vitrages';
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/projets/'),
        headers: headers,
        body: jsonEncode(projet.toJson()),
      );

      if (response.statusCode == 201) {
        return ProjetVitrage.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<ProjetVitrage> updateProjet(String id, ProjetVitrage projet) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/vitrages';
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/projets/$id/'),
        headers: headers,
        body: jsonEncode(projet.toJson()),
      );

      if (response.statusCode == 200) {
        return ProjetVitrage.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Calculs
  Future<List<CalculVitrage>> getCalculs({String? projetId, String? typeVitrage}) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/vitrages';
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      if (projetId != null) queryParams['projet'] = projetId;
      if (typeVitrage != null) queryParams['type_vitrage'] = typeVitrage;

      final uri = Uri.parse('$baseUrl/calculs/').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => CalculVitrage.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<CalculVitrage> createCalcul(CalculVitrage calcul) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/vitrages';
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/calculs/'),
        headers: headers,
        body: jsonEncode(calcul.toJson()),
      );

      if (response.statusCode == 201) {
        return CalculVitrage.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<CalculVitrage> updateCalcul(String id, CalculVitrage calcul) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/vitrages';
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/calculs/$id/'),
        headers: headers,
        body: jsonEncode(calcul.toJson()),
      );

      if (response.statusCode == 200) {
        return CalculVitrage.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<CalculVitrage> recalculer(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/vitrages';
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/calculs/$id/recalculer/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return CalculVitrage.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Map<String, dynamic>> getNoteCalcul(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/vitrages';
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/calculs/$id/note_calcul/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Régions vent/neige
  Future<List<RegionVentNeige>> getRegionsVentNeige({bool? actif}) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/vitrages';
      final headers = await _getHeaders();
      String url = '$baseUrl/regions-vent-neige/';
      if (actif != null) url += '?actif=$actif';

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => RegionVentNeige.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<RegionVentNeige?> getRegionParCoordonnees(double latitude, double longitude) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/vitrages';
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/regions-vent-neige/par_coordonnees/?latitude=$latitude&longitude=$longitude'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return RegionVentNeige.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Catégories de terrain
  Future<List<CategorieTerrain>> getCategoriesTerrain({bool? actif}) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/vitrages';
      final headers = await _getHeaders();
      String url = '$baseUrl/categories-terrain/';
      if (actif != null) url += '?actif=$actif';

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => CategorieTerrain.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}

