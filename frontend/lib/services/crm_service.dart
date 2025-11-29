import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/crm/visite_model.dart';
import '../models/crm/suivi_ca_model.dart';
import 'config_service.dart';

class CrmService {

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

  // Visites
  Future<List<Visite>> getVisites({
    String? clientId,
    String? commercialId,
    String? typeVisite,
    String? dateDebut,
    String? dateFin,
  }) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/crm';
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      if (clientId != null) queryParams['client'] = clientId;
      if (commercialId != null) queryParams['commercial'] = commercialId;
      if (typeVisite != null) queryParams['type_visite'] = typeVisite;
      if (dateDebut != null) queryParams['date_debut'] = dateDebut;
      if (dateFin != null) queryParams['date_fin'] = dateFin;

      final uri = Uri.parse('$baseUrl/visites/').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => Visite.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Visite> getVisiteById(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/crm';
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/visites/$id/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Visite.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Visite> createVisite(Visite visite) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/crm';
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/visites/'),
        headers: headers,
        body: jsonEncode(visite.toJson()),
      );

      if (response.statusCode == 201) {
        return Visite.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Visite> updateVisite(String id, Visite visite) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/crm';
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/visites/$id/'),
        headers: headers,
        body: jsonEncode(visite.toJson()),
      );

      if (response.statusCode == 200) {
        return Visite.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<void> deleteVisite(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/crm';
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/visites/$id/'),
        headers: headers,
      );

      if (response.statusCode != 204) {
        throw Exception('Erreur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Suivi CA
  Future<List<SuiviCA>> getSuiviCA({
    String? periodeDebut,
    String? periodeFin,
    String? familleArticle,
  }) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/crm';
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      if (periodeDebut != null) queryParams['periode_debut'] = periodeDebut;
      if (periodeFin != null) queryParams['periode_fin'] = periodeFin;
      if (familleArticle != null) queryParams['famille_article'] = familleArticle;

      final uri = Uri.parse('$baseUrl/suivi-ca/').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => SuiviCA.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<List<SuiviCA>> calculerCA({
    required String periodeDebut,
    required String periodeFin,
  }) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/crm';
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/suivi-ca/calculer/'),
        headers: headers,
        body: jsonEncode({
          'periode_debut': periodeDebut,
          'periode_fin': periodeFin,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((json) => SuiviCA.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Map<String, dynamic>> getResumeCA() async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/crm';
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/suivi-ca/resume/'),
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
}



