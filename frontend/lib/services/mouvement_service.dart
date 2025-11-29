import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mouvement_model.dart';
import 'config_service.dart';

class MouvementService {

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

  Future<List<Mouvement>> getMouvements({
    String? typeMouvement,
    String? articleId,
    String? dateMouvement,
  }) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      String url = '$baseUrl/stock/mouvements/';
      final params = <String>[];
      if (typeMouvement != null) params.add('type_mouvement=$typeMouvement');
      if (articleId != null) params.add('article=$articleId');
      if (dateMouvement != null) params.add('date_mouvement=$dateMouvement');
      if (params.isNotEmpty) url += '?${params.join('&')}';
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => Mouvement.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Mouvement> getMouvementById(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/stock/mouvements/$id/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Mouvement.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Mouvement> createMouvement(Mouvement mouvement) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/stock/mouvements/'),
        headers: headers,
        body: jsonEncode(mouvement.toJson()),
      );

      if (response.statusCode == 201) {
        return Mouvement.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Mouvement> updateMouvement(String id, Mouvement mouvement) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/stock/mouvements/$id/'),
        headers: headers,
        body: jsonEncode(mouvement.toJson()),
      );

      if (response.statusCode == 200) {
        return Mouvement.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<void> deleteMouvement(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/stock/mouvements/$id/'),
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



