import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fournisseur_model.dart';
import 'config_service.dart';

class FournisseurService {

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

  Future<List<Fournisseur>> getFournisseurs({bool? actif}) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      String url = '$baseUrl/stock/fournisseurs/';
      if (actif != null) url += '?actif=$actif';
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => Fournisseur.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Fournisseur> getFournisseurById(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/stock/fournisseurs/$id/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Fournisseur.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Fournisseur> createFournisseur(Fournisseur fournisseur) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/stock/fournisseurs/'),
        headers: headers,
        body: jsonEncode(fournisseur.toJson()),
      );

      if (response.statusCode == 201) {
        return Fournisseur.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Fournisseur> updateFournisseur(String id, Fournisseur fournisseur) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/stock/fournisseurs/$id/'),
        headers: headers,
        body: jsonEncode(fournisseur.toJson()),
      );

      if (response.statusCode == 200) {
        return Fournisseur.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<void> deleteFournisseur(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/stock/fournisseurs/$id/'),
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



