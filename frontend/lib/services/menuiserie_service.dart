import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/menuiserie/projet_model.dart';
import '../models/menuiserie/article_model.dart';
import '../models/menuiserie/option_menuiserie_model.dart';
import 'config_service.dart';

class MenuiserieService {

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
  Future<List<Projet>> getProjets({String? statut, String? devisId}) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      String url = '$baseUrl/menuiserie/projets/';
      final params = <String>[];
      if (statut != null) params.add('statut=$statut');
      if (devisId != null) params.add('devis=$devisId');
      if (params.isNotEmpty) url += '?${params.join('&')}';
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => Projet.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Projet> getProjetById(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/menuiserie/projets/$id/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Projet.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Projet> createProjet(Projet projet) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/menuiserie/projets/'),
        headers: headers,
        body: jsonEncode(projet.toJson()),
      );

      if (response.statusCode == 201) {
        return Projet.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Projet> updateProjet(String id, Projet projet) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/menuiserie/projets/$id/'),
        headers: headers,
        body: jsonEncode(projet.toJson()),
      );

      if (response.statusCode == 200) {
        return Projet.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<void> deleteProjet(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/menuiserie/projets/$id/'),
        headers: headers,
      );

      if (response.statusCode != 204) {
        throw Exception('Erreur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Articles
  Future<List<Article>> getArticles({String? projetId}) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      String url = '$baseUrl/menuiserie/articles/';
      if (projetId != null) url += '?projet=$projetId';
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => Article.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Article> getArticleById(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/menuiserie/articles/$id/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Article.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Article> createArticle(Article article) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/menuiserie/articles/'),
        headers: headers,
        body: jsonEncode(article.toJson()),
      );

      if (response.statusCode == 201) {
        return Article.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Article> updateArticle(String id, Article article) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/menuiserie/articles/$id/'),
        headers: headers,
        body: jsonEncode(article.toJson()),
      );

      if (response.statusCode == 200) {
        return Article.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<void> deleteArticle(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/menuiserie/articles/$id/'),
        headers: headers,
      );

      if (response.statusCode != 204) {
        throw Exception('Erreur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Options Menuiserie
  Future<List<OptionMenuiserie>> getOptions({
    String? typeArticle,
    String? typeOption,
  }) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      String url = '$baseUrl/menuiserie/options/';
      final params = <String>[];
      if (typeArticle != null) params.add('type_article=$typeArticle');
      if (typeOption != null) params.add('type_option=$typeOption');
      if (params.isNotEmpty) url += '?${params.join('&')}';
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => OptionMenuiserie.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Tarifs Fournisseurs
  Future<List<Map<String, dynamic>>> getTarifsFournisseurs({
    String? fournisseurId,
  }) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      String url = '$baseUrl/menuiserie/tarifs-fournisseurs/';
      if (fournisseurId != null) url += '?fournisseur=$fournisseurId';
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return List<Map<String, dynamic>>.from(results);
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Calculer le prix avec options
  Future<double> calculerPrix({
    String? tarifFournisseurId,
    double? prixBaseHt,
    required double largeur,
    required double hauteur,
    required List<String> optionsObligatoires,
    required List<String> optionsFacultatives,
  }) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/menuiserie/options/calculer_prix/'),
        headers: headers,
        body: jsonEncode({
          if (tarifFournisseurId != null) 'tarif_fournisseur': tarifFournisseurId,
          if (prixBaseHt != null) 'prix_base_ht': prixBaseHt,
          'largeur': largeur,
          'hauteur': hauteur,
          'options_obligatoires': optionsObligatoires,
          'options_facultatives': optionsFacultatives,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['prix_calcule'] as num).toDouble();
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Générer la désignation avec options
  Future<String> genererDesignation({
    String? designationBase,
    required String typeArticle,
    required double largeur,
    required double hauteur,
    required List<String> optionsObligatoires,
    required List<String> optionsFacultatives,
  }) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/menuiserie/options/generer_designation/'),
        headers: headers,
        body: jsonEncode({
          if (designationBase != null) 'designation_base': designationBase,
          'type_article': typeArticle,
          'largeur': largeur,
          'hauteur': hauteur,
          'options_obligatoires': optionsObligatoires,
          'options_facultatives': optionsFacultatives,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['designation_generee'] ?? '';
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}


