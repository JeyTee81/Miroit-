import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/import_access_service.dart';

class ImportAccessTab extends StatefulWidget {
  const ImportAccessTab({super.key});

  @override
  State<ImportAccessTab> createState() => _ImportAccessTabState();
}

class _ImportAccessTabState extends State<ImportAccessTab> {
  final ImportAccessService _service = ImportAccessService();
  
  String? _filePath;
  List<Map<String, String>> _tables = [];
  String? _selectedTable;
  List<Map<String, dynamic>> _columns = [];
  Map<String, dynamic>? _previewData;
  Map<String, String> _columnMapping = {};
  String? _selectedModel;
  
  // Modèles disponibles pour l'import
  final List<String> _availableModels = ['Client', 'Facture', 'Devis', 'Chantier'];
  
  // Mapping des champs par modèle (pour aide à l'utilisateur)
  final Map<String, List<String>> _modelFields = {
    'Client': ['nom', 'prenom', 'raison_sociale', 'siret', 'adresse', 'code_postal', 'ville', 'telephone', 'email', 'type'],
    'Facture': ['numero_facture', 'date_facture', 'date_echeance', 'montant_ht', 'montant_ttc', 'statut', 'client'],
    'Devis': ['numero_devis', 'date_devis', 'montant_ht', 'montant_ttc', 'statut', 'client'],
    'Chantier': ['nom', 'adresse', 'date_debut', 'date_fin_prevue', 'client'],
  };

  bool _pyodbcAvailable = true;
  bool _checkingAvailability = false;

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    setState(() => _checkingAvailability = true);
    try {
      final result = await _service.verifierDisponibilite();
      setState(() {
        _pyodbcAvailable = result['available'] == true;
        _checkingAvailability = false;
      });
      if (!_pyodbcAvailable && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'pyodbc n\'est pas disponible'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _pyodbcAvailable = false;
        _checkingAvailability = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // En-tête
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Import depuis Access',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  if (!_pyodbcAvailable)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, size: 18, color: Colors.orange.shade800),
                          const SizedBox(width: 8),
                          const Text(
                            'pyodbc non disponible',
                            style: TextStyle(fontSize: 12, color: Colors.orange),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _pyodbcAvailable ? _selectFile : null,
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Sélectionner fichier Access'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(),
        
        // Contenu
        Expanded(
          child: _checkingAvailability
              ? const Center(child: CircularProgressIndicator())
              : !_pyodbcAvailable
                  ? _buildNotAvailableState()
                  : _filePath == null
                      ? _buildEmptyState()
                      : _buildImportInterface(),
        ),
      ],
    );
  }

  Widget _buildNotAvailableState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.orange.shade400),
            const SizedBox(height: 16),
            const Text(
              'pyodbc n\'est pas disponible',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Pour utiliser l\'import Access, vous devez installer pyodbc.\n\n'
                'Note: pyodbc nécessite une compilation et peut ne pas être compatible '
                'avec toutes les versions de Python.\n\n'
                'Recommandations:\n'
                '• Python 3.8-3.13 est recommandé\n'
                '• Installer avec: pip install pyodbc\n'
                '• Ou utiliser une version précompilée de pyodbc',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _checkAvailability,
              icon: const Icon(Icons.refresh),
              label: const Text('Vérifier à nouveau'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storage, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Sélectionnez un fichier Access (.mdb ou .accdb)',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Format supporté: Microsoft Access (.mdb, .accdb)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportInterface() {
    return Row(
      children: [
        // Panneau gauche : Configuration
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Fichier sélectionné
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.insert_drive_file, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _filePath!.split('\\').last,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _testConnection,
                            icon: const Icon(Icons.check_circle, size: 18),
                            label: const Text('Tester la connexion'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Sélection de la table
                  const Text(
                    'Table Access',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  _tables.isEmpty
                      ? ElevatedButton.icon(
                          onPressed: _loadTables,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Charger les tables'),
                        )
                      : DropdownButtonFormField<String>(
                          value: _selectedTable,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Sélectionner une table',
                          ),
                          items: _tables.map((table) {
                            return DropdownMenuItem(
                              value: table['name'],
                              child: Text(table['name'] ?? ''),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedTable = value;
                              _columns = [];
                              _previewData = null;
                              _columnMapping = {};
                            });
                            if (value != null) {
                              _loadColumns(value);
                              _loadPreview(value);
                            }
                          },
                        ),
                  
                  if (_selectedTable != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Modèle de destination',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedModel,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Sélectionner le modèle',
                      ),
                      items: _availableModels.map((model) {
                        return DropdownMenuItem(
                          value: model,
                          child: Text(model),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedModel = value;
                          _columnMapping = {};
                        });
                        if (value != null && _columns.isNotEmpty) {
                          _suggestMapping(value);
                        }
                      },
                    ),
                  ],
                  
                  if (_selectedTable != null && _selectedModel != null && _columns.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Mapping des colonnes',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    ..._columns.map((column) {
                      final accessCol = column['name'] as String;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                accessCol,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Text('→', style: TextStyle(color: Colors.grey)),
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<String>(
                                value: _columnMapping[accessCol],
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('Ignorer', style: TextStyle(fontSize: 12)),
                                  ),
                                  ...(_modelFields[_selectedModel] ?? []).map((field) {
                                    return DropdownMenuItem(
                                      value: field,
                                      child: Text(field, style: const TextStyle(fontSize: 12)),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    if (value == null) {
                                      _columnMapping.remove(accessCol);
                                    } else {
                                      _columnMapping[accessCol] = value;
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _canImport() ? _importData : null,
                      icon: const Icon(Icons.upload),
                      label: const Text('Importer les données'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        
        // Panneau droit : Aperçu
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: _selectedTable == null
                ? const Center(
                    child: Text(
                      'Sélectionnez une table pour voir l\'aperçu',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : _previewData == null
                    ? const Center(child: CircularProgressIndicator())
                    : _buildPreview(),
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    final data = _previewData!['data'] as List;
    final rowCount = _previewData!['row_count'] as int;
    final previewCount = _previewData!['preview_count'] as int;

    if (data.isEmpty) {
      return const Center(
        child: Text('Aucune donnée dans cette table'),
      );
    }

    // Récupérer les colonnes
    final columns = (data.first as Map).keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aperçu ($previewCount / $rowCount lignes)',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columns: columns.map((col) {
                  return DataColumn(label: Text(col.toString()));
                }).toList(),
                rows: data.take(10).map((row) {
                  return DataRow(
                    cells: columns.map((col) {
                      final value = row[col];
                      return DataCell(
                        Text(
                          value?.toString() ?? '',
                          style: const TextStyle(fontSize: 11),
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _canImport() {
    return _filePath != null &&
        _selectedTable != null &&
        _selectedModel != null &&
        _columnMapping.isNotEmpty;
  }

  Future<void> _selectFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mdb', 'accdb'],
        dialogTitle: 'Sélectionner un fichier Access',
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _filePath = result.files.single.path;
          _tables = [];
          _selectedTable = null;
          _columns = [];
          _previewData = null;
          _columnMapping = {};
          _selectedModel = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _testConnection() async {
    if (_filePath == null) return;

    try {
      final result = await _service.testerConnexion(_filePath!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Connexion réussie'),
            backgroundColor: result['success'] == true ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadTables() async {
    if (_filePath == null) return;

    try {
      final tables = await _service.listerTables(_filePath!);
      setState(() {
        _tables = tables;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadColumns(String tableName) async {
    if (_filePath == null) return;

    try {
      final columns = await _service.listerColonnes(_filePath!, tableName);
      setState(() {
        _columns = columns;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des colonnes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadPreview(String tableName) async {
    if (_filePath == null) return;

    try {
      final preview = await _service.apercuDonnees(_filePath!, tableName, limit: 10);
      setState(() {
        _previewData = preview;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'aperçu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _suggestMapping(String model) {
    // Suggestion automatique basée sur les noms de colonnes
    final mapping = <String, String>{};
    final fields = _modelFields[model] ?? [];

    for (final column in _columns) {
      final accessCol = column['name'] as String;
      final accessColLower = accessCol.toLowerCase();

      // Chercher une correspondance approximative
      for (final field in fields) {
        final fieldLower = field.toLowerCase();
        if (accessColLower.contains(fieldLower) || fieldLower.contains(accessColLower)) {
          mapping[accessCol] = field;
          break;
        }
      }
    }

    setState(() {
      _columnMapping = mapping;
    });
  }

  Future<void> _importData() async {
    if (!_canImport()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer l\'import'),
        content: Text(
          'Vous allez importer les données de la table "$_selectedTable" '
          'vers le modèle "$_selectedModel".\n\n'
          'Cette action peut prendre du temps selon le nombre de lignes.\n\n'
          'Continuer ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Importer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final result = await _service.importerDonnees(
        filePath: _filePath!,
        tableName: _selectedTable!,
        modelName: _selectedModel!,
        columnMapping: _columnMapping,
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Import terminé'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lignes importées: ${result['imported_count']}'),
                Text('Total: ${result['total_count']}'),
                if (result['errors_count'] > 0)
                  Text(
                    'Erreurs: ${result['errors_count']}',
                    style: const TextStyle(color: Colors.red),
                  ),
                if (result['errors'] != null && (result['errors'] as List).isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Détails des erreurs:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  ...(result['errors'] as List).take(5).map((error) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        error.toString(),
                        style: const TextStyle(fontSize: 11, color: Colors.red),
                      ),
                    );
                  }),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'import: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

