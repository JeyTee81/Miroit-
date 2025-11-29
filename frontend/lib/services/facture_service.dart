import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/facture_model.dart';
import '../models/paiement_model.dart';
import 'config_service.dart';

class FactureService {

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

  Future<List<Facture>> getFactures({String? clientId, String? statut}) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      String url = '$baseUrl/commerciale/factures/';
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
                return Facture.fromJson(json as Map<String, dynamic>);
              } catch (e) {
                print('Erreur lors du parsing d\'une facture: $e');
                print('JSON: $json');
                rethrow;
              }
            }).toList();
          }
          return [];
        } catch (e) {
          print('Erreur lors du parsing JSON des factures: $e');
          print('Response body: ${response.body}');
          rethrow;
        }
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Facture> getFactureById(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/commerciale/factures/$id/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Facture.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Facture> createFacture(Facture facture) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/commerciale/factures/'),
        headers: headers,
        body: jsonEncode(facture.toJson()),
      );

      if (response.statusCode == 201) {
        return Facture.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Facture> updateFacture(String id, Facture facture) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/commerciale/factures/$id/'),
        headers: headers,
        body: jsonEncode(facture.toJson()),
      );

      if (response.statusCode == 200) {
        return Facture.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<void> deleteFacture(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/commerciale/factures/$id/'),
        headers: headers,
      );

      if (response.statusCode != 204) {
        throw Exception('Erreur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<List<Paiement>> getPaiements(String factureId) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/commerciale/factures/$factureId/paiements/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((json) => Paiement.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Paiement> enregistrerPaiement(String factureId, Paiement paiement) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/commerciale/factures/$factureId/enregistrer_paiement/'),
        headers: headers,
        body: jsonEncode(paiement.toJson()),
      );

      if (response.statusCode == 200) {
        return Paiement.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}

