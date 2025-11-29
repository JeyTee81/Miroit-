import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/log_entry_model.dart';
import 'config_service.dart';

class LogService {

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

  Future<List<LogEntry>> getLogs({
    String? level,
    String? loggerName,
    String? requestMethod,
    int? responseStatus,
    String? dateFilter,
    bool? errorsOnly,
    String? userId,
    String? search,
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      if (level != null) queryParams['level'] = level;
      if (loggerName != null) queryParams['logger_name'] = loggerName;
      if (requestMethod != null) queryParams['request_method'] = requestMethod;
      if (responseStatus != null) queryParams['response_status'] = responseStatus.toString();
      if (dateFilter != null) queryParams['date_filter'] = dateFilter;
      if (errorsOnly == true) queryParams['errors_only'] = 'true';
      if (userId != null) queryParams['user_id'] = userId;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final baseUrl = await ConfigService.getApiBaseUrl();
      final uri = Uri.parse('$baseUrl/system_logs/logs/').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] ?? data;
        if (results is List) {
          return results.map((json) => LogEntry.fromJson(json)).toList();
        }
        return [];
      }
      throw Exception('Erreur lors de la récupération des logs: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<LogEntry> getLogById(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/system_logs/logs/$id/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return LogEntry.fromJson(jsonDecode(response.body));
      }
      throw Exception('Erreur lors de la récupération du log: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Map<String, dynamic>> getStats() async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/system_logs/logs/stats/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Erreur lors de la récupération des statistiques: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Map<String, dynamic>> getTraceback(String id) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/system_logs/logs/$id/traceback/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Erreur lors de la récupération du traceback: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<void> clearOldLogs({int days = 30}) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/system_logs/logs/clear_old_logs/?days=$days'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la suppression des logs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Envoie un log d'erreur depuis le frontend vers le backend
  Future<void> logFrontendError({
    required String message,
    String? exceptionType,
    String? exceptionMessage,
    String? traceback,
    String? module,
    String? function,
    int? lineNumber,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      final baseUrl = await ConfigService.getApiBaseUrl();
      final headers = await _getHeaders();
      
      final logData = {
        'level': 'ERROR',
        'logger_name': 'frontend',
        'message': message,
        'exception_type': exceptionType,
        'exception_message': exceptionMessage,
        'traceback': traceback,
        'module': module,
        'function': function,
        'line_number': lineNumber,
        'extra_data': extraData,
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/system_logs/logs/create_frontend_log/'),
        headers: headers,
        body: jsonEncode(logData),
      );

      if (response.statusCode != 201) {
        // Ne pas lancer d'exception pour éviter une boucle infinie
        print('Erreur lors de l\'envoi du log frontend: ${response.statusCode}');
      }
    } catch (e) {
      // Ne pas lancer d'exception pour éviter une boucle infinie
      print('Erreur lors de l\'envoi du log frontend: $e');
    }
  }
}

