import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/log_service.dart';
import '../models/log_entry_model.dart';
import '../widgets/main_layout.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  final LogService _logService = LogService();
  List<LogEntry> _logs = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  
  // Filtres
  String? _selectedLevel;
  String? _selectedDateFilter = '24h';
  bool _errorsOnly = false;
  String? _selectedMethod;
  
  final List<String> _levels = ['DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL'];
  final List<String> _dateFilters = ['24h', '7d', '30d'];
  final List<String> _methods = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'];

  @override
  void initState() {
    super.initState();
    _loadLogs();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final logs = await _logService.getLogs(
        level: _selectedLevel,
        dateFilter: _selectedDateFilter,
        errorsOnly: _errorsOnly,
        requestMethod: _selectedMethod,
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
      );
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des logs: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onSearchChanged() {
    _loadLogs();
  }

  Future<void> _showLogDetails(LogEntry log) async {
    try {
      final fullLog = await _logService.getLogById(log.id);
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Détails du log',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Niveau', fullLog.level, color: fullLog.levelColor),
                        _buildDetailRow('Logger', fullLog.loggerName),
                        _buildDetailRow('Date', DateFormat('dd/MM/yyyy HH:mm:ss').format(fullLog.createdAt)),
                        if (fullLog.module != null) _buildDetailRow('Module', fullLog.module!),
                        if (fullLog.function != null) _buildDetailRow('Fonction', fullLog.function!),
                        if (fullLog.lineNumber != null) _buildDetailRow('Ligne', fullLog.lineNumber.toString()),
                        const SizedBox(height: 8),
                        const Text('Message:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: SelectableText(
                            fullLog.message,
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                        if (fullLog.requestMethod != null) ...[
                          const SizedBox(height: 16),
                          const Text('Requête HTTP:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          _buildDetailRow('Méthode', fullLog.requestMethod!),
                          if (fullLog.requestPath != null) _buildDetailRow('Chemin', fullLog.requestPath!),
                          if (fullLog.responseStatus != null) _buildDetailRow('Statut', fullLog.responseStatus.toString()),
                          if (fullLog.responseTimeMs != null) _buildDetailRow('Temps (ms)', fullLog.responseTimeMs!.toStringAsFixed(2)),
                          if (fullLog.requestUserName != null) _buildDetailRow('Utilisateur', fullLog.requestUserName!),
                          if (fullLog.ipAddress != null) _buildDetailRow('IP', fullLog.ipAddress!),
                        ],
                        if (fullLog.exceptionType != null) ...[
                          const SizedBox(height: 16),
                          const Text('Exception:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                          const SizedBox(height: 4),
                          _buildDetailRow('Type', fullLog.exceptionType!, color: Colors.red),
                          if (fullLog.exceptionMessage != null)
                            _buildDetailRow('Message', fullLog.exceptionMessage!, color: Colors.red),
                        ],
                        if (fullLog.traceback != null) ...[
                          const SizedBox(height: 16),
                          const Text('Traceback:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: SelectableText(
                              fullLog.traceback!,
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (fullLog.traceback != null)
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final traceback = await _logService.getTraceback(fullLog.id);
                        if (!mounted) return;
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              height: MediaQuery.of(context).size.height * 0.8,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Traceback complet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                                  const Divider(),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: SelectableText(
                                        traceback['traceback'] ?? '',
                                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.code),
                    label: const Text('Voir le traceback complet'),
                  ),
              ],
            ),
          ),
        ),
      );
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

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentRoute: '/logs',
      title: 'Console de logs',
      child: Column(
        children: [
          // Barre de filtres
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              children: [
                // Recherche
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Rechercher dans les logs...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                // Filtres
                Row(
                  children: [
                    // Filtre par niveau
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedLevel,
                        decoration: const InputDecoration(
                          labelText: 'Niveau',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Tous')),
                          ..._levels.map((level) => DropdownMenuItem(value: level, child: Text(level))),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedLevel = value;
                          });
                          _loadLogs();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Filtre par date
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedDateFilter,
                        decoration: const InputDecoration(
                          labelText: 'Période',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: _dateFilters.map((filter) {
                          String label;
                          switch (filter) {
                            case '24h':
                              label = '24 dernières heures';
                              break;
                            case '7d':
                              label = '7 derniers jours';
                              break;
                            case '30d':
                              label = '30 derniers jours';
                              break;
                            default:
                              label = filter;
                          }
                          return DropdownMenuItem(value: filter, child: Text(label));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDateFilter = value;
                          });
                          _loadLogs();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Filtre par méthode HTTP
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedMethod,
                        decoration: const InputDecoration(
                          labelText: 'Méthode HTTP',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Toutes')),
                          ..._methods.map((method) => DropdownMenuItem(value: method, child: Text(method))),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedMethod = value;
                          });
                          _loadLogs();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Checkbox erreurs uniquement
                    Checkbox(
                      value: _errorsOnly,
                      onChanged: (value) {
                        setState(() {
                          _errorsOnly = value ?? false;
                        });
                        _loadLogs();
                      },
                    ),
                    const Text('Erreurs uniquement'),
                    const SizedBox(width: 12),
                    // Bouton actualiser
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadLogs,
                      tooltip: 'Actualiser',
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Liste des logs
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _logs.isEmpty
                    ? const Center(
                        child: Text('Aucun log trouvé'),
                      )
                    : ListView.builder(
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          final log = _logs[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            color: log.isError ? Colors.red[50] : null,
                            child: ListTile(
                              leading: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: log.levelColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              title: Text(
                                log.shortMessage,
                                style: TextStyle(
                                  fontWeight: log.isError ? FontWeight.bold : FontWeight.normal,
                                  color: log.isError ? Colors.red[900] : null,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    '${log.loggerName} • ${DateFormat('dd/MM/yyyy HH:mm:ss').format(log.createdAt)}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                  if (log.requestMethod != null && log.requestPath != null)
                                    Text(
                                      '${log.requestMethod} ${log.requestPath}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  if (log.responseStatus != null)
                                    Text(
                                      'Status: ${log.responseStatus}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: log.responseStatus! >= 400 ? Colors.red : Colors.green,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: log.isError
                                  ? const Icon(Icons.error, color: Colors.red)
                                  : null,
                              onTap: () => _showLogDetails(log),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

