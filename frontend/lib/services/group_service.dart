import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/group_model.dart';
import 'config_service.dart';

class GroupService {

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

  Future<List<Group>> getGroups({bool? actif}) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      String url = '$baseUrl/auth/groups/';
      if (actif != null) {
        url += '?actif=$actif';
      }
      
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => Group.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur lors de la récupération des groupes: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Group> getGroupById(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/auth/groups/$id/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Group.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur lors de la récupération du groupe: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Group> createGroup(Group group) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/auth/groups/'),
        headers: headers,
        body: jsonEncode(group.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Group.fromJson(jsonDecode(response.body));
      }
      
      final errorData = jsonDecode(response.body);
      throw Exception(errorData.toString());
    } catch (e) {
      throw Exception('Erreur lors de la création du groupe: $e');
    }
  }

  Future<Group> updateGroup(Group group) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/auth/groups/${group.id}/'),
        headers: headers,
        body: jsonEncode(group.toJson()),
      );

      if (response.statusCode == 200) {
        return Group.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur lors de la mise à jour du groupe: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<void> deleteGroup(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/auth/groups/$id/'),
        headers: headers,
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Erreur lors de la suppression du groupe: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}

