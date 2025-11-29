import 'package:flutter/material.dart';
import '../services/config_service.dart';
import 'package:http/http.dart' as http;

class ServerConfigScreen extends StatefulWidget {
  const ServerConfigScreen({super.key});

  @override
  State<ServerConfigScreen> createState() => _ServerConfigScreenState();
}

class _ServerConfigScreenState extends State<ServerConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serverUrlController = TextEditingController();
  bool _isLoading = false;
  bool _isTesting = false;
  String? _testMessage;
  Color? _testMessageColor;

  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
  }

  Future<void> _loadCurrentConfig() async {
    final currentUrl = await ConfigService.getServerUrl();
    _serverUrlController.text = currentUrl;
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    if (_serverUrlController.text.trim().isEmpty) {
      setState(() {
        _testMessage = 'Veuillez entrer une adresse de serveur';
        _testMessageColor = Colors.red;
      });
      return;
    }

    setState(() {
      _isTesting = true;
      _testMessage = null;
    });

    try {
      final url = _serverUrlController.text.trim();
      // Nettoyer l'URL (enlever le slash final si présent)
      final cleanUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
      
      // Tester la connexion en appelant l'endpoint racine de l'API
      final response = await http.get(
        Uri.parse('$cleanUrl/api/'),
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Timeout : le serveur ne répond pas');
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _testMessage = 'Connexion réussie !';
          _testMessageColor = Colors.green;
        });
      } else {
        setState(() {
          _testMessage = 'Le serveur a répondu avec le code ${response.statusCode}';
          _testMessageColor = Colors.orange;
        });
      }
    } catch (e) {
      setState(() {
        _testMessage = 'Erreur de connexion : $e';
        _testMessageColor = Colors.red;
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = _serverUrlController.text.trim();
      // Nettoyer l'URL (enlever le slash final si présent)
      final cleanUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
      
      // Sauvegarder l'URL
      await ConfigService.setServerUrl(cleanUrl);
      await ConfigService.setConfigCompleted(true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuration sauvegardée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        // Retourner à l'écran de connexion
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(24),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.settings_ethernet,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Configuration du serveur',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Veuillez configurer l\'adresse du serveur backend',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _serverUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Adresse du serveur',
                        hintText: 'http://192.168.1.100:8000',
                        prefixIcon: Icon(Icons.dns),
                        border: OutlineInputBorder(),
                        helperText: 'Exemple: http://192.168.1.100:8000 ou http://localhost:8000',
                      ),
                      keyboardType: TextInputType.url,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez entrer une adresse de serveur';
                        }
                        final url = value.trim();
                        if (!url.startsWith('http://') && !url.startsWith('https://')) {
                          return 'L\'adresse doit commencer par http:// ou https://';
                        }
                        try {
                          Uri.parse(url);
                        } catch (e) {
                          return 'Adresse invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Message de test
                    if (_testMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _testMessageColor?.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _testMessageColor ?? Colors.grey),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _testMessageColor == Colors.green
                                  ? Icons.check_circle
                                  : Icons.error,
                              color: _testMessageColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _testMessage!,
                                style: TextStyle(color: _testMessageColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                    // Bouton de test
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isTesting ? null : _testConnection,
                        icon: _isTesting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.network_check),
                        label: Text(_isTesting ? 'Test en cours...' : 'Tester la connexion'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Bouton de sauvegarde
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveConfig,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Enregistrer et continuer'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

