import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/planning/rendez_vous_model.dart';

class RendezVousService {
  final String baseUrl = 'http://localhost:8000/api/planning';

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

  Future<List<RendezVous>> getRendezVous({
    String? utilisateurId,
    String? type,
    String? statut,
    DateTime? dateDebut,
    DateTime? dateFin,
    String? clientId,
    String? chantierId,
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      
      if (utilisateurId != null) queryParams['utilisateur'] = utilisateurId;
      if (type != null) queryParams['type'] = type;
      if (statut != null) queryParams['statut'] = statut;
      if (dateDebut != null) queryParams['date_debut'] = dateDebut.toIso8601String();
      if (dateFin != null) queryParams['date_fin'] = dateFin.toIso8601String();
      if (clientId != null) queryParams['client'] = clientId;
      if (chantierId != null) queryParams['chantier'] = chantierId;

      final uri = Uri.parse('$baseUrl/rendez-vous/').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => RendezVous.fromJson(json)).toList();
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<RendezVous> getRendezVousById(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/rendez-vous/$id/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return RendezVous.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<RendezVous> createRendezVous(RendezVous rendezVous) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/rendez-vous/'),
        headers: headers,
        body: jsonEncode(rendezVous.toJson()),
      );

      if (response.statusCode == 201) {
        return RendezVous.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<RendezVous> updateRendezVous(String id, RendezVous rendezVous) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/rendez-vous/$id/'),
        headers: headers,
        body: jsonEncode(rendezVous.toJson()),
      );

      if (response.statusCode == 200) {
        return RendezVous.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<void> deleteRendezVous(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/rendez-vous/$id/'),
        headers: headers,
      );

      if (response.statusCode != 204) {
        throw Exception('Erreur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<List<RendezVous>> getRendezVousAujourdhui() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/rendez-vous/aujourdhui/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => RendezVous.fromJson(json)).toList();
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<List<RendezVous>> getRendezVousCetteSemaine() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/rendez-vous/cette_semaine/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => RendezVous.fromJson(json)).toList();
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<List<RendezVous>> getRendezVousCeMois() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/rendez-vous/ce_mois/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => RendezVous.fromJson(json)).toList();
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<List<RendezVous>> getRendezVousParPeriode(DateTime dateDebut, DateTime dateFin) async {
    try {
      final headers = await _getHeaders();
      final queryParams = {
        'date_debut': dateDebut.toIso8601String(),
        'date_fin': dateFin.toIso8601String(),
      };
      final uri = Uri.parse('$baseUrl/rendez-vous/par_periode/').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => RendezVous.fromJson(json)).toList();
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}

