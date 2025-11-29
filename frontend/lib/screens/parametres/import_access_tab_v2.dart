import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../services/import_access_service.dart';

class ImportAccessTabV2 extends StatefulWidget {
  const ImportAccessTabV2({super.key});

  @override
  State<ImportAccessTabV2> createState() => _ImportAccessTabV2State();
}

class _ImportAccessTabV2State extends State<ImportAccessTabV2> {
  final ImportAccessService _service = ImportAccessService();
  final TextEditingController _whereClauseController = TextEditingController();
  final TextEditingController _uniqueFieldsController = TextEditingController();
  
  String? _filePath;
  List<Map<String, String>> _tables = [];
  String? _selectedTable;
  List<Map<String, dynamic>> _columns = [];
  Map<String, dynamic>? _previewData;
  Map<String, String> _columnMapping = {};
  
  // Modèles Django
  List<Map<String, dynamic>> _availableModels = [];
  Map<String, dynamic>? _selectedModel;
  List<Map<String, dynamic>> _modelFields = [];
  
  // Options d'import
  bool _skipDuplicates = false;
  bool _updateExisting = false;
  List<String> _uniqueFields = [];
  
  bool _pyodbcAvailable = true;
  bool _checkingAvailability = false;

  @override
  void initState() {
    super.initState();
    _checkAvailability();
    _loadModels();
  }

  @override
  void dispose() {
    _whereClauseController.dispose();
    _uniqueFieldsController.dispose();
    super.dispose();
  }

  Future<void> _checkAvailability() async {
    setState(() => _checkingAvailability = true);
    try {
      final result = await _service.verifierDisponibilite();
      setState(() {
        _pyodbcAvailable = result['available'] == true;
        _checkingAvailability = false;
      });
    } catch (e) {
      setState(() {
        _pyodbcAvailable = false;
        _checkingAvailability = false;
      });
    }
  }

  Future<void> _loadModels() async {
    try {
      final models = await _service.listerModeles();
      setState(() {
        _availableModels = models;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        const Divider(),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Import depuis Access (Avancé)',
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
                      const Text('pyodbc non disponible', style: TextStyle(fontSize: 12)),
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
                  _buildFileInfo(),
                  const SizedBox(height: 16),
                  _buildTableSelection(),
                  if (_selectedTable != null) ...[
                    const SizedBox(height: 16),
                    _buildFilters(),
                    const SizedBox(height: 16),
                    _buildModelSelection(),
                    if (_selectedModel != null) ...[
                      const SizedBox(height: 16),
                      _buildColumnMapping(),
                      const SizedBox(height: 16),
                      _buildImportOptions(),
                      const SizedBox(height: 16),
                      _buildActionButtons(),
                    ],
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
                ? const Center(child: Text('Sélectionnez une table'))
                : _previewData == null
                    ? const Center(child: CircularProgressIndicator())
                    : _buildPreview(),
          ),
        ),
      ],
    );
  }

  Widget _buildFileInfo() {
    return Card(
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
    );
  }

  Widget _buildTableSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Table Access', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    _selectedModel = null;
                    _modelFields = [];
                  });
                  if (value != null) {
                    _loadColumns(value);
                    _loadPreview(value);
                  }
                },
              ),
      ],
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Filtres SQL (WHERE)', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _whereClauseController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Ex: date_creation > #2024-01-01# AND actif = True',
            helperText: 'Clause WHERE SQL (optionnel)',
          ),
          maxLines: 2,
          onChanged: (_) {
            if (_selectedTable != null) {
              _loadPreview(_selectedTable!);
            }
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _selectedTable != null ? () => _loadPreview(_selectedTable!) : null,
          icon: const Icon(Icons.filter_list),
          label: const Text('Appliquer le filtre'),
        ),
      ],
    );
  }

  Widget _buildModelSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Modèle Django de destination', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedModel?['full_name'],
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Sélectionner un modèle',
          ),
          items: _availableModels.map<DropdownMenuItem<String>>((model) {
            return DropdownMenuItem<String>(
              value: model['full_name'] as String,
              child: Text('${model['app_label']}.${model['model_name']}'),
            );
          }).toList(),
          onChanged: (value) async {
            if (value != null) {
              final model = _availableModels.firstWhere((m) => m['full_name'] == value);
              await _loadModelFields(model['app_label'], model['model_name']);
              setState(() {
                _selectedModel = model;
                _columnMapping = {};
              });
              if (_columns.isNotEmpty) {
                _suggestMapping();
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildColumnMapping() {
    if (_columns.isEmpty || _modelFields.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Mapping des colonnes', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      ..._modelFields.map((field) {
                        final fieldName = field['name'] as String;
                        final fieldType = field['type'] as String;
                        return DropdownMenuItem(
                          value: fieldName,
                          child: Text(
                            '$fieldName ($fieldType)',
                            style: const TextStyle(fontSize: 12),
                          ),
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
      ],
    );
  }

  Widget _buildImportOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Options d\'import', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        CheckboxListTile(
          title: const Text('Ignorer les doublons'),
          subtitle: const Text('Ne pas importer les lignes déjà existantes'),
          value: _skipDuplicates,
          onChanged: (value) => setState(() {
            _skipDuplicates = value ?? false;
            if (!_skipDuplicates) _updateExisting = false;
          }),
        ),
        CheckboxListTile(
          title: const Text('Mettre à jour les existants'),
          subtitle: const Text('Mettre à jour les enregistrements existants'),
          value: _updateExisting,
          onChanged: _skipDuplicates
              ? (value) => setState(() => _updateExisting = value ?? false)
              : null,
          enabled: _skipDuplicates,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _uniqueFieldsController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Champs uniques (séparés par des virgules)',
            helperText: 'Ex: siret,email (pour détecter les doublons)',
          ),
          onChanged: (value) {
            setState(() {
              _uniqueFields = value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
            });
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _selectedTable != null ? _serializeData : null,
                icon: const Icon(Icons.download),
                label: const Text('Exporter JSON'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _selectedTable != null ? () => _serializeData(format: 'csv') : null,
                icon: const Icon(Icons.table_chart),
                label: const Text('Exporter CSV'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreview() {
    final data = _previewData!['data'] as List;
    final rowCount = _previewData!['row_count'] as int;
    final previewCount = _previewData!['preview_count'] as int;

    if (data.isEmpty) {
      return const Center(child: Text('Aucune donnée dans cette table'));
    }

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
          _modelFields = [];
          _whereClauseController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
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
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
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
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _loadColumns(String tableName) async {
    if (_filePath == null) return;
    try {
      final columns = await _service.listerColonnes(_filePath!, tableName);
      setState(() => _columns = columns);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _loadPreview(String tableName) async {
    if (_filePath == null) return;
    try {
      final preview = await _service.apercuDonnees(
        filePath: _filePath!,
        tableName: tableName,
        limit: 10,
        whereClause: _whereClauseController.text.isNotEmpty ? _whereClauseController.text : null,
      );
      setState(() => _previewData = preview);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _loadModelFields(String appLabel, String modelName) async {
    try {
      final result = await _service.obtenirChampsModele(
        appLabel: appLabel,
        modelName: modelName,
      );
      setState(() {
        _modelFields = List<Map<String, dynamic>>.from(result['fields']);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _suggestMapping() {
    final mapping = <String, String>{};
    for (final column in _columns) {
      final accessCol = column['name'] as String;
      final accessColLower = accessCol.toLowerCase();
      
      for (final field in _modelFields) {
        final fieldName = field['name'] as String;
        final fieldNameLower = fieldName.toLowerCase();
        if (accessColLower.contains(fieldNameLower) || fieldNameLower.contains(accessColLower)) {
          mapping[accessCol] = fieldName;
          break;
        }
      }
    }
    setState(() => _columnMapping = mapping);
  }

  Future<void> _importData() async {
    if (!_canImport()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer l\'import'),
        content: Text(
          'Vous allez importer les données de la table "$_selectedTable" '
          'vers le modèle "${_selectedModel!['full_name']}".\n\n'
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
        appLabel: _selectedModel!['app_label'],
        modelName: _selectedModel!['model_name'],
        columnMapping: _columnMapping,
        whereClause: _whereClauseController.text.isNotEmpty ? _whereClauseController.text : null,
        options: {
          'skip_duplicates': _skipDuplicates,
          'update_existing': _updateExisting,
          'unique_fields': _uniqueFields,
        },
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Import terminé'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lignes importées: ${result['imported_count']}'),
                  if (result['updated_count'] > 0)
                    Text('Lignes mises à jour: ${result['updated_count']}'),
                  if (result['skipped_count'] > 0)
                    Text('Lignes ignorées: ${result['skipped_count']}'),
                  Text('Total: ${result['total_count']}'),
                  if (result['errors_count'] > 0)
                    Text('Erreurs: ${result['errors_count']}', style: const TextStyle(color: Colors.red)),
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
          SnackBar(content: Text('Erreur lors de l\'import: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _serializeData({String format = 'json'}) async {
    if (_filePath == null || _selectedTable == null) return;

    try {
      final result = await _service.serialiserDonnees(
        filePath: _filePath!,
        tableName: _selectedTable!,
        whereClause: _whereClauseController.text.isNotEmpty ? _whereClauseController.text : null,
        format: format,
      );

      if (mounted) {
        // Sauvegarder le fichier
        final fileName = '${_selectedTable}_${DateTime.now().millisecondsSinceEpoch}.$format';
        final path = await FilePicker.platform.saveFile(
          dialogTitle: 'Enregistrer le fichier',
          fileName: fileName,
        );

        if (path != null) {
          final file = File(path);
          await file.writeAsString(result['data']);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fichier enregistré: $fileName'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

