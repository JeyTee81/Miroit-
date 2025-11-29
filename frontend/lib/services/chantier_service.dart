import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chantier_model.dart';
import 'config_service.dart';

class ChantierService {

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

  Future<List<Chantier>> getChantiers({String? clientId, String? statut}) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      String url = '$baseUrl/commerciale/chantiers/';
      final params = <String>[];
      if (clientId != null) params.add('client=$clientId');
      if (statut != null) params.add('statut=$statut');
      if (params.isNotEmpty) url += '?${params.join('&')}';
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          final results = data['results'] ?? data;
          if (results is List) {
            return results.map((json) {
              try {
                return Chantier.fromJson(json as Map<String, dynamic>);
              } catch (e) {
                print('Erreur lors du parsing d\'un chantier: $e');
                print('JSON: $json');
                rethrow;
              }
            }).toList();
          }
          return [];
        } catch (e) {
          print('Erreur lors du parsing JSON des chantiers: $e');
          print('Response body: ${response.body}');
          rethrow;
        }
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Chantier> getChantierById(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/commerciale/chantiers/$id/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Chantier.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Chantier> createChantier(Chantier chantier) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/commerciale/chantiers/'),
        headers: headers,
        body: jsonEncode(chantier.toJson()),
      );

      if (response.statusCode == 201) {
        return Chantier.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Chantier> updateChantier(String id, Chantier chantier) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/commerciale/chantiers/$id/'),
        headers: headers,
        body: jsonEncode(chantier.toJson()),
      );

      if (response.statusCode == 200) {
        return Chantier.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<void> deleteChantier(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/commerciale/chantiers/$id/'),
        headers: headers,
      );

      if (response.statusCode != 204) {
        throw Exception('Erreur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}




