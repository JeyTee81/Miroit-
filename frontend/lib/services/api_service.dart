import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config_service.dart';

class ApiService {
  String? _token;

  Future<String?> _getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    };
  }

  Future<http.Response> get(String endpoint) async {
    final baseUrl = await ConfigService.getApiBaseUrl();
    final headers = await _getHeaders();
    return await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final baseUrl = await ConfigService.getApiBaseUrl();
    final headers = await _getHeaders();
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    final baseUrl = await ConfigService.getApiBaseUrl();
    final headers = await _getHeaders();
    return await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
  }

  Future<http.Response> delete(String endpoint) async {
    final baseUrl = await ConfigService.getApiBaseUrl();
    final headers = await _getHeaders();
    return await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
  }
}





