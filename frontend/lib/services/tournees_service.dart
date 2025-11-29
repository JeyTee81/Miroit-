import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tournees/tournee_model.dart';
import '../models/tournees/vehicule_model.dart';
import '../models/tournees/chauffeur_model.dart';
import '../models/tournees/chariot_model.dart';
import '../models/tournees/livraison_model.dart';
import 'config_service.dart';

class TourneesService {

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

  // Tournées
  Future<List<Tournee>> getTournees({
    String? dateTournee,
    String? statut,
    String? chauffeurId,
  }) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/tournees';
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      if (dateTournee != null) queryParams['date_tournee'] = dateTournee;
      if (statut != null) queryParams['statut'] = statut;
      if (chauffeurId != null) queryParams['chauffeur'] = chauffeurId;

      final uri = Uri.parse('$baseUrl/tournees/').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => Tournee.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Tournee> getTourneeById(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/tournees';
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/tournees/$id/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Tournee.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Tournee> createTournee(Tournee tournee) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/tournees';
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/tournees/'),
        headers: headers,
        body: jsonEncode(tournee.toJson()),
      );

      if (response.statusCode == 201) {
        return Tournee.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Tournee> updateTournee(String id, Tournee tournee) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/tournees';
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/tournees/$id/'),
        headers: headers,
        body: jsonEncode(tournee.toJson()),
      );

      if (response.statusCode == 200) {
        return Tournee.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<void> deleteTournee(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/tournees';
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/tournees/$id/'),
        headers: headers,
      );

      if (response.statusCode != 204) {
        throw Exception('Erreur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Tournee> optimiserTournee(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/tournees';
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/tournees/$id/optimiser/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Tournee.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Tournee> demarrerTournee(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/tournees';
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/tournees/$id/demarrer/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Tournee.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Tournee> terminerTournee(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/tournees';
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/tournees/$id/terminer/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Tournee.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Véhicules
  Future<List<Vehicule>> getVehicules({bool? actif}) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/tournees';
      final headers = await _getHeaders();
      String url = '$baseUrl/vehicules/';
      if (actif != null) url += '?actif=$actif';

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => Vehicule.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Vehicule> createVehicule(Vehicule vehicule) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/tournees';
      final headers = await _getHeaders();
      final body = vehicule.toJson();
      // S'assurer que capacite_charge est un nombre ou null
      if (body['capacite_charge'] != null && body['capacite_charge'] is String) {
        body['capacite_charge'] = double.tryParse(body['capacite_charge']);
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/vehicules/'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        return Vehicule.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Vehicule> updateVehicule(String id, Vehicule vehicule) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/tournees';
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/vehicules/$id/'),
        headers: headers,
        body: jsonEncode(vehicule.toJson()),
      );

      if (response.statusCode == 200) {
        return Vehicule.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<void> deleteVehicule(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/tournees';
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/vehicules/$id/'),
        headers: headers,
      );

      if (response.statusCode != 204) {
        throw Exception('Erreur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Chauffeurs
  Future<List<Chauffeur>> getChauffeurs({bool? actif}) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/tournees';
      final headers = await _getHeaders();
      String url = '$baseUrl/chauffeurs/';
      if (actif != null) url += '?actif=$actif';

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => Chauffeur.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Chauffeur> createChauffeur(Chauffeur chauffeur) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/tournees';
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/chauffeurs/'),
        headers: headers,
        body: jsonEncode(chauffeur.toJson()),
      );

      if (response.statusCode == 201) {
        return Chauffeur.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Chauffeur> updateChauffeur(String id, Chauffeur chauffeur) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/tournees';
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/chauffeurs/$id/'),
        headers: headers,
        body: jsonEncode(chauffeur.toJson()),
      );

      if (response.statusCode == 200) {
        return Chauffeur.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<void> deleteChauffeur(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/tournees';
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/chauffeurs/$id/'),
        headers: headers,
      );

      if (response.statusCode != 204) {
        throw Exception('Erreur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Chariots
  Future<List<Chariot>> getChariots({bool? actif}) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/tournees';
      final headers = await _getHeaders();
      String url = '$baseUrl/chariots/';
      if (actif != null) url += '?actif=$actif';

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => Chariot.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Chariot> createChariot(Chariot chariot) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/tournees';
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/chariots/'),
        headers: headers,
        body: jsonEncode(chariot.toJson()),
      );

      if (response.statusCode == 201) {
        return Chariot.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Chariot> updateChariot(String id, Chariot chariot) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/tournees';
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/chariots/$id/'),
        headers: headers,
        body: jsonEncode(chariot.toJson()),
      );

      if (response.statusCode == 200) {
        return Chariot.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<void> deleteChariot(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/tournees';
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/chariots/$id/'),
        headers: headers,
      );

      if (response.statusCode != 204) {
        throw Exception('Erreur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Livraisons
  Future<List<Livraison>> getLivraisons({
    String? tourneeId,
    String? statut,
  }) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/tournees';
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      if (tourneeId != null) queryParams['tournee'] = tourneeId;
      if (statut != null) queryParams['statut'] = statut;

      final uri = Uri.parse('$baseUrl/livraisons/').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => Livraison.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Livraison> createLivraison(Livraison livraison) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/tournees';
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/livraisons/'),
        headers: headers,
        body: jsonEncode(livraison.toJson()),
      );

      if (response.statusCode == 201) {
        return Livraison.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Livraison> updateLivraison(String id, Livraison livraison) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/tournees';
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/livraisons/$id/'),
        headers: headers,
        body: jsonEncode(livraison.toJson()),
      );

      if (response.statusCode == 200) {
        return Livraison.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Livraison> marquerLivree(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/tournees';
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/livraisons/$id/marquer_livree/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Livraison.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}

