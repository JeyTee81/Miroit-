import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/debit/affaire_model.dart';
import '../models/debit/lancement_model.dart';
import '../models/debit/debit_model.dart';
import '../models/debit/matiere_model.dart';
import '../models/debit/parametres_debit_model.dart';
import '../models/debit/chute_model.dart';
import '../models/debit/stock_matiere_model.dart';
import 'config_service.dart';

class DebitService {

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

  // Matières
  Future<List<Matiere>> getMatieres({bool? actif, String? typeMatiere}) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/optimisation';
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      if (actif != null) queryParams['actif'] = actif.toString();
      if (typeMatiere != null) queryParams['type_matiere'] = typeMatiere;

      final uri = Uri.parse('$baseUrl/matieres/').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => Matiere.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Matiere> createMatiere(Matiere matiere) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/optimisation';
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/matieres/'),
        headers: headers,
        body: jsonEncode(matiere.toJson()),
      );

      if (response.statusCode == 201) {
        return Matiere.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Paramètres de débit
  Future<List<ParametresDebit>> getParametresDebit({bool? actif}) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/optimisation';
      final headers = await _getHeaders();
      String url = '$baseUrl/parametres-debit/';
      if (actif != null) url += '?actif=$actif';

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => ParametresDebit.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Affaires
  Future<List<Affaire>> getAffaires({String? statut, String? chantierId}) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/optimisation';
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      if (statut != null) queryParams['statut'] = statut;
      if (chantierId != null) queryParams['chantier'] = chantierId;

      final uri = Uri.parse('$baseUrl/affaires/').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => Affaire.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Affaire> createAffaire(Affaire affaire) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/optimisation';
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/affaires/'),
        headers: headers,
        body: jsonEncode(affaire.toJson()),
      );

      if (response.statusCode == 201) {
        return Affaire.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Lancements
  Future<List<Lancement>> getLancements({String? affaireId, String? statut}) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/optimisation';
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      if (affaireId != null) queryParams['affaire'] = affaireId;
      if (statut != null) queryParams['statut'] = statut;

      final uri = Uri.parse('$baseUrl/lancements/').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => Lancement.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Lancement> createLancement(Lancement lancement) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/optimisation';
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/lancements/'),
        headers: headers,
        body: jsonEncode(lancement.toJson()),
      );

      if (response.statusCode == 201) {
        return Lancement.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Débits
  Future<List<Debit>> getDebits({String? lancementId}) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/optimisation';
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      if (lancementId != null) queryParams['lancement'] = lancementId;

      final uri = Uri.parse('$baseUrl/debits/').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => Debit.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Debit> createDebit(Debit debit) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/optimisation';
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/debits/'),
        headers: headers,
        body: jsonEncode(debit.toJson()),
      );

      if (response.statusCode == 201) {
        return Debit.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Debit> updateDebit(String id, Debit debit) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/optimisation';
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/debits/$id/'),
        headers: headers,
        body: jsonEncode(debit.toJson()),
      );

      if (response.statusCode == 200) {
        return Debit.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Debit> optimiserDebit(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/optimisation';
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/debits/$id/optimiser/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Debit.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Chutes
  Future<List<Chute>> getChutes({String? matiereId, String? statut, bool? disponibles}) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/optimisation';
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      if (matiereId != null) queryParams['matiere'] = matiereId;
      if (statut != null) queryParams['statut'] = statut;
      if (disponibles != null) queryParams['disponibles'] = disponibles.toString();

      final uri = Uri.parse('$baseUrl/chutes/').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => Chute.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Stocks
  Future<List<StockMatiere>> getStocks({String? matiereId, String? statut, bool? disponibles}) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/optimisation';
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      if (matiereId != null) queryParams['matiere'] = matiereId;
      if (statut != null) queryParams['statut'] = statut;
      if (disponibles != null) queryParams['disponibles'] = disponibles.toString();

      final uri = Uri.parse('$baseUrl/stocks/').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => StockMatiere.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<StockMatiere> createStock(StockMatiere stock) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl() + '/optimisation';
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/stocks/'),
        headers: headers,
        body: jsonEncode(stock.toJson()),
      );

      if (response.statusCode == 201) {
        return StockMatiere.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}



