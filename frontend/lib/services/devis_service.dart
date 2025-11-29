import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/devis_model.dart';
import 'config_service.dart';
import 'log_service.dart';

class DevisService {

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

  Future<List<Devis>> getDevis() async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/commerciale/devis/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          final results = data['results'] ?? data;
          if (results is List) {
            return results.map((json) {
              try {
                return Devis.fromJson(json as Map<String, dynamic>);
              } catch (e, stackTrace) {
                print('Erreur lors du parsing d\'un devis: $e');
                print('JSON: $json');
                // Logger l'erreur au backend
                LogService().logFrontendError(
                  message: 'Erreur lors du parsing d\'un devis: $e',
                  exceptionType: e.runtimeType.toString(),
                  exceptionMessage: e.toString(),
                  traceback: stackTrace.toString(),
                  module: 'devis_service',
                  function: 'getDevis',
                  extraData: {'json': json},
                );
                rethrow;
              }
            }).toList();
          }
          return [];
        } catch (e) {
          print('Erreur lors du parsing JSON des devis: $e');
          print('Response body: ${response.body}');
          rethrow;
        }
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Devis> getDevisById(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/commerciale/devis/$id/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Devis.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Devis> createDevis(Devis devis) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/commerciale/devis/'),
        headers: headers,
        body: jsonEncode(devis.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Devis.fromJson(jsonDecode(response.body));
      }
      
      final errorData = jsonDecode(response.body);
      throw Exception(errorData.toString());
    } catch (e) {
      throw Exception('Erreur lors de la création du devis: $e');
    }
  }

  Future<Devis> updateDevis(Devis devis) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/commerciale/devis/${devis.id}/'),
        headers: headers,
        body: jsonEncode(devis.toJson()),
      );

      if (response.statusCode == 200) {
        return Devis.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<void> deleteDevis(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/commerciale/devis/$id/'),
        headers: headers,
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Erreur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}





