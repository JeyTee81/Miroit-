import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/client_model.dart';
import 'config_service.dart';

class ClientService {

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

  Future<List<Client>> getClients() async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/commerciale/clients/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          final results = data['results'] ?? data;
          if (results is List) {
            return results.map((json) {
              try {
                return Client.fromJson(json as Map<String, dynamic>);
              } catch (e) {
                print('Erreur lors du parsing d\'un client: $e');
                print('JSON: $json');
                rethrow;
              }
            }).toList();
          }
          return [];
        } catch (e) {
          print('Erreur lors du parsing JSON des clients: $e');
          print('Response body: ${response.body}');
          rethrow;
        }
      }
      throw Exception('Erreur lors de la récupération des clients: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Client> getClient(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/commerciale/clients/$id/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Client.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur lors de la récupération du client: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Client> createClient(Client client) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/commerciale/clients/'),
        headers: headers,
        body: jsonEncode(client.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Client.fromJson(jsonDecode(response.body));
      }
      
      final errorData = jsonDecode(response.body);
      throw Exception(errorData.toString());
    } catch (e) {
      throw Exception('Erreur lors de la création du client: $e');
    }
  }

  Future<Client> updateClient(Client client) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/commerciale/clients/${client.id}/'),
        headers: headers,
        body: jsonEncode(client.toJson()),
      );

      if (response.statusCode == 200) {
        return Client.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur lors de la mise à jour du client: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<void> deleteClient(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/commerciale/clients/$id/'),
        headers: headers,
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Erreur lors de la suppression du client: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}





