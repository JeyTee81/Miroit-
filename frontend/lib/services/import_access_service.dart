import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config_service.dart';

class ImportAccessService {

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    };
  }

  /// Vérifie si pyodbc est disponible
  Future<Map<String, dynamic>> verifierDisponibilite() async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/parametres/import-access';
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/verifier_disponibilite/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        return error;
      }
    } catch (e) {
      throw Exception('Erreur lors de la vérification: $e');
    }
  }

  /// Teste la connexion à un fichier Access
  Future<Map<String, dynamic>> testerConnexion(String filePath) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/parametres/import-access';
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/tester_connexion/'),
        headers: headers,
        body: jsonEncode({'file_path': filePath}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Erreur de connexion');
      }
    } catch (e) {
      throw Exception('Erreur lors du test de connexion: $e');
    }
  }

  /// Liste toutes les tables d'un fichier Access
  Future<List<Map<String, String>>> listerTables(String filePath) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/parametres/import-access';
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/lister_tables/'),
        headers: headers,
        body: jsonEncode({'file_path': filePath}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, String>>.from(
          (data['tables'] as List).map((t) => Map<String, String>.from(t)),
        );
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Erreur lors de la liste des tables');
      }
    } catch (e) {
      throw Exception('Erreur lors de la liste des tables: $e');
    }
  }

  /// Liste les colonnes d'une table Access
  Future<List<Map<String, dynamic>>> listerColonnes(
    String filePath,
    String tableName,
  ) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/parametres/import-access';
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/lister_colonnes/'),
        headers: headers,
        body: jsonEncode({
          'file_path': filePath,
          'table_name': tableName,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['columns']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Erreur lors de la liste des colonnes');
      }
    } catch (e) {
      throw Exception('Erreur lors de la liste des colonnes: $e');
    }
  }


  /// Liste tous les modèles Django disponibles
  Future<List<Map<String, dynamic>>> listerModeles() async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/parametres/import-access';
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/lister_modeles/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['models']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Erreur lors de la liste des modèles');
      }
    } catch (e) {
      throw Exception('Erreur lors de la liste des modèles: $e');
    }
  }

  /// Obtient les champs d'un modèle Django
  Future<Map<String, dynamic>> obtenirChampsModele({
    required String appLabel,
    required String modelName,
  }) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/parametres/import-access';
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/obtenir_champs_modele/'),
        headers: headers,
        body: jsonEncode({
          'app_label': appLabel,
          'model_name': modelName,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Erreur lors de la récupération des champs');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des champs: $e');
    }
  }

  /// Aperçu des données avec filtres
  Future<Map<String, dynamic>> apercuDonnees({
    required String filePath,
    required String tableName,
    int limit = 10,
    String? whereClause,
  }) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/parametres/import-access';
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/apercu_donnees/'),
        headers: headers,
        body: jsonEncode({
          'file_path': filePath,
          'table_name': tableName,
          'limit': limit,
          if (whereClause != null && whereClause.isNotEmpty) 'where_clause': whereClause,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Erreur lors de l\'aperçu');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'aperçu: $e');
    }
  }

  /// Importe les données d'une table Access vers un modèle Django
  Future<Map<String, dynamic>> importerDonnees({
    required String filePath,
    required String tableName,
    required String appLabel,
    required String modelName,
    required Map<String, String> columnMapping,
    String? whereClause,
    Map<String, dynamic>? options,
  }) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/parametres/import-access';
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/importer_donnees/'),
        headers: headers,
        body: jsonEncode({
          'file_path': filePath,
          'table_name': tableName,
          'app_label': appLabel,
          'model_name': modelName,
          'column_mapping': columnMapping,
          if (whereClause != null && whereClause.isNotEmpty) 'where_clause': whereClause,
          if (options != null) 'options': options,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Erreur lors de l\'import');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'import: $e');
    }
  }

  /// Sérialise les données d'une table Access
  Future<Map<String, dynamic>> serialiserDonnees({
    required String filePath,
    required String tableName,
    String? whereClause,
    String format = 'json',
  }) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/parametres/import-access';
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/serialiser_donnees/'),
        headers: headers,
        body: jsonEncode({
          'file_path': filePath,
          'table_name': tableName,
          if (whereClause != null && whereClause.isNotEmpty) 'where_clause': whereClause,
          'format': format,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Erreur lors de la sérialisation');
      }
    } catch (e) {
      throw Exception('Erreur lors de la sérialisation: $e');
    }
  }
}

