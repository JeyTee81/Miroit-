import 'package:flutter/material.dart';
import '../../services/config_service.dart';
import 'package:http/http.dart' as http;

class ServerConfigTab extends StatefulWidget {
  const ServerConfigTab({super.key});

  @override
  State<ServerConfigTab> createState() => _ServerConfigTabState();
}

class _ServerConfigTabState extends State<ServerConfigTab> {
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
      final cleanUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
      
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
      final cleanUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
      
      await ConfigService.setServerUrl(cleanUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuration sauvegardée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuration du serveur backend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Configurez l\'adresse du serveur backend pour la connexion de l\'application.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
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
            Row(
              children: [
                Expanded(
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
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveConfig,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(_isLoading ? 'Enregistrement...' : 'Enregistrer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

