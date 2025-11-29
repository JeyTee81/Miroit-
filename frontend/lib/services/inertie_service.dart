import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/inertie/famille_materiau_model.dart';
import '../models/inertie/profil_model.dart';
import '../models/inertie/projet_model.dart';
import '../models/inertie/calcul_raidisseur_model.dart';
import '../models/inertie/calcul_traverse_model.dart';
import '../models/inertie/calcul_ei_model.dart';
import 'config_service.dart';

class InertieService {

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

  // Familles de matériaux
  Future<List<FamilleMateriau>> getFamillesMateriaux() async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/inertie/familles-materiaux/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => FamilleMateriau.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<FamilleMateriau> createFamilleMateriau(FamilleMateriau famille) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/inertie/familles-materiaux/'),
        headers: headers,
        body: jsonEncode(famille.toJson()),
      );

      if (response.statusCode == 201) {
        return FamilleMateriau.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Profils
  Future<List<Profil>> getProfils({String? familleMateriauId}) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      String url = '$baseUrl/inertie/profils/';
      if (familleMateriauId != null) {
        url += '?famille_materiau=$familleMateriauId';
      }
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => Profil.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Profil> createProfil(Profil profil) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/inertie/profils/'),
        headers: headers,
        body: jsonEncode(profil.toJson()),
      );

      if (response.statusCode == 201) {
        return Profil.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Projets
  Future<List<ProjetInertie>> getProjets() async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/inertie/projets/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => ProjetInertie.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<ProjetInertie> createProjet(ProjetInertie projet) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/inertie/projets/'),
        headers: headers,
        body: jsonEncode(projet.toJson()),
      );

      if (response.statusCode == 201) {
        return ProjetInertie.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Calculs raidisseur
  Future<List<CalculRaidisseur>> getCalculsRaidisseur({String? projetId}) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      String url = '$baseUrl/inertie/calculs-raidisseur/';
      if (projetId != null) {
        url += '?projet=$projetId';
      }
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => CalculRaidisseur.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<CalculRaidisseur> createCalculRaidisseur(CalculRaidisseur calcul) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/inertie/calculs-raidisseur/'),
        headers: headers,
        body: jsonEncode(calcul.toJson()),
      );

      if (response.statusCode == 201) {
        return CalculRaidisseur.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Map<String, dynamic>> calculerRaidisseur(CalculRaidisseur calcul) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/inertie/calculs-raidisseur/calculer/'),
        headers: headers,
        body: jsonEncode(calcul.toJson()),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Calculs traverse
  Future<List<CalculTraverse>> getCalculsTraverse({String? projetId}) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      String url = '$baseUrl/inertie/calculs-traverse/';
      if (projetId != null) {
        url += '?projet=$projetId';
      }
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => CalculTraverse.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<CalculTraverse> createCalculTraverse(CalculTraverse calcul) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/inertie/calculs-traverse/'),
        headers: headers,
        body: jsonEncode(calcul.toJson()),
      );

      if (response.statusCode == 201) {
        return CalculTraverse.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Map<String, dynamic>> calculerTraverse(CalculTraverse calcul) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/inertie/calculs-traverse/calculer/'),
        headers: headers,
        body: jsonEncode(calcul.toJson()),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Calculs EI
  Future<List<CalculEI>> getCalculsEI({String? projetId}) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      String url = '$baseUrl/inertie/calculs-ei/';
      if (projetId != null) {
        url += '?projet=$projetId';
      }
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => CalculEI.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<CalculEI> createCalculEI(CalculEI calcul) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/inertie/calculs-ei/'),
        headers: headers,
        body: jsonEncode(calcul.toJson()),
      );

      if (response.statusCode == 201) {
        return CalculEI.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Map<String, dynamic>> calculerEI(CalculEI calcul) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/inertie/calculs-ei/calculer/'),
        headers: headers,
        body: jsonEncode(calcul.toJson()),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Calcul utilitaire - inertie tube
  Future<Map<String, dynamic>> calculerInertieTube({
    required double hauteurCm,
    required double largeurCm,
    required double epaisseurCm,
  }) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/inertie/utilitaire/inertie_tube/'),
        headers: headers,
        body: jsonEncode({
          'hauteur_cm': hauteurCm,
          'largeur_cm': largeurCm,
          'epaisseur_cm': epaisseurCm,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}

