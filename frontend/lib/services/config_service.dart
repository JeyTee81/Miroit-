import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  static const String _serverUrlKey = 'server_url';
  static const String _configCompletedKey = 'config_completed';
  static const String _defaultServerUrl = 'http://localhost:8000';

  /// Récupère l'URL du serveur backend
  static Future<String> getServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_serverUrlKey) ?? _defaultServerUrl;
  }

  /// Récupère l'URL de base de l'API (serveur + /api)
  static Future<String> getApiBaseUrl() async {
    final serverUrl = await getServerUrl();
    // S'assurer qu'il n'y a pas de slash final
    final cleanUrl = serverUrl.endsWith('/') 
        ? serverUrl.substring(0, serverUrl.length - 1) 
        : serverUrl;
    return '$cleanUrl/api';
  }

  /// Définit l'URL du serveur backend
  static Future<void> setServerUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_serverUrlKey, url);
  }

  /// Vérifie si la configuration a été complétée
  static Future<bool> isConfigCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_configCompletedKey) ?? false;
  }

  /// Marque la configuration comme complétée
  static Future<void> setConfigCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_configCompletedKey, completed);
  }

  /// Réinitialise la configuration (pour forcer l'écran de configuration)
  static Future<void> resetConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_configCompletedKey, false);
  }

  /// URL par défaut
  static String get defaultServerUrl => _defaultServerUrl;
}

