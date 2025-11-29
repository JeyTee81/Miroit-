import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/travaux/devis_travaux_model.dart';
import '../models/travaux/ligne_devis_travaux_model.dart';
import '../models/travaux/commande_travaux_model.dart';
import '../models/travaux/facture_travaux_model.dart';
import '../models/travaux/ligne_facture_travaux_model.dart';
import 'config_service.dart';

class TravauxService {

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

  // ========== DEVIS ==========
  Future<List<DevisTravaux>> getDevisTravaux({String? statut, String? clientId}) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      String url = '$baseUrl/travaux/devis/';
      List<String> params = [];
      if (statut != null) params.add('statut=$statut');
      if (clientId != null) params.add('client=$clientId');
      if (params.isNotEmpty) url += '?${params.join('&')}';
      
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => DevisTravaux.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<DevisTravaux> getDevisTravauxById(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/travaux/devis/$id/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return DevisTravaux.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<DevisTravaux> createDevisTravaux(DevisTravaux devis) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/travaux/devis/'),
        headers: headers,
        body: jsonEncode(devis.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return DevisTravaux.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<DevisTravaux> updateDevisTravaux(DevisTravaux devis) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/travaux/devis/${devis.id}/'),
        headers: headers,
        body: jsonEncode(devis.toJson()),
      );

      if (response.statusCode == 200) {
        return DevisTravaux.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<void> deleteDevisTravaux(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/travaux/devis/$id/'),
        headers: headers,
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Erreur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // ========== LIGNES DEVIS ==========
  Future<List<LigneDevisTravaux>> getLignesDevisTravaux(String devisId) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/travaux/devis-lignes/?devis=$devisId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => LigneDevisTravaux.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<LigneDevisTravaux> createLigneDevisTravaux(LigneDevisTravaux ligne) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/travaux/devis-lignes/'),
        headers: headers,
        body: jsonEncode(ligne.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return LigneDevisTravaux.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<LigneDevisTravaux> updateLigneDevisTravaux(LigneDevisTravaux ligne) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/travaux/devis-lignes/${ligne.id}/'),
        headers: headers,
        body: jsonEncode(ligne.toJson()),
      );

      if (response.statusCode == 200) {
        return LigneDevisTravaux.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<void> deleteLigneDevisTravaux(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/travaux/devis-lignes/$id/'),
        headers: headers,
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Erreur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // ========== COMMANDES ==========
  Future<List<CommandeTravaux>> getCommandesTravaux({String? statut, String? clientId}) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      String url = '$baseUrl/travaux/commandes/';
      List<String> params = [];
      if (statut != null) params.add('statut=$statut');
      if (clientId != null) params.add('client=$clientId');
      if (params.isNotEmpty) url += '?${params.join('&')}';
      
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => CommandeTravaux.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<CommandeTravaux> getCommandeTravauxById(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/travaux/commandes/$id/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return CommandeTravaux.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<CommandeTravaux> createCommandeTravaux(CommandeTravaux commande) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/travaux/commandes/'),
        headers: headers,
        body: jsonEncode(commande.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return CommandeTravaux.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<CommandeTravaux> updateCommandeTravaux(CommandeTravaux commande) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/travaux/commandes/${commande.id}/'),
        headers: headers,
        body: jsonEncode(commande.toJson()),
      );

      if (response.statusCode == 200) {
        return CommandeTravaux.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<void> deleteCommandeTravaux(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/travaux/commandes/$id/'),
        headers: headers,
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Erreur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // ========== FACTURES ==========
  Future<List<FactureTravaux>> getFacturesTravaux({String? statut, String? clientId}) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      String url = '$baseUrl/travaux/factures/';
      List<String> params = [];
      if (statut != null) params.add('statut=$statut');
      if (clientId != null) params.add('client=$clientId');
      if (params.isNotEmpty) url += '?${params.join('&')}';
      
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => FactureTravaux.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<FactureTravaux> getFactureTravauxById(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/travaux/factures/$id/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return FactureTravaux.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<FactureTravaux> createFactureTravaux(FactureTravaux facture) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/travaux/factures/'),
        headers: headers,
        body: jsonEncode(facture.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return FactureTravaux.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<FactureTravaux> updateFactureTravaux(FactureTravaux facture) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/travaux/factures/${facture.id}/'),
        headers: headers,
        body: jsonEncode(facture.toJson()),
      );

      if (response.statusCode == 200) {
        return FactureTravaux.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<void> deleteFactureTravaux(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/travaux/factures/$id/'),
        headers: headers,
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Erreur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // ========== LIGNES FACTURES ==========
  Future<List<LigneFactureTravaux>> getLignesFactureTravaux(String factureId) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/travaux/factures-lignes/?facture=$factureId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => LigneFactureTravaux.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<LigneFactureTravaux> createLigneFactureTravaux(LigneFactureTravaux ligne) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/travaux/factures-lignes/'),
        headers: headers,
        body: jsonEncode(ligne.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return LigneFactureTravaux.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<LigneFactureTravaux> updateLigneFactureTravaux(LigneFactureTravaux ligne) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/travaux/factures-lignes/${ligne.id}/'),
        headers: headers,
        body: jsonEncode(ligne.toJson()),
      );

      if (response.statusCode == 200) {
        return LigneFactureTravaux.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<void> deleteLigneFactureTravaux(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/travaux/factures-lignes/$id/'),
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



