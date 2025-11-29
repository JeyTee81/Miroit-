import 'package:flutter/material.dart';
import '../../models/imprimante_model.dart';
import '../../services/imprimante_service.dart';
import 'create_imprimante_screen.dart';

class ImprimantesTab extends StatefulWidget {
  const ImprimantesTab({super.key});

  @override
  State<ImprimantesTab> createState() => _ImprimantesTabState();
}

class _ImprimantesTabState extends State<ImprimantesTab> {
  final ImprimanteService _imprimanteService = ImprimanteService();
  List<Imprimante> _imprimantes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadImprimantes();
  }

  Future<void> _loadImprimantes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final imprimantes = await _imprimanteService.getImprimantes();
      setState(() {
        _imprimantes = imprimantes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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

  Future<void> _deleteImprimante(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette imprimante ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _imprimanteService.deleteImprimante(id);
        _loadImprimantes();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Imprimante supprimée'), backgroundColor: Colors.green),
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
  }

  Future<void> _definirParDefaut(String id) async {
    try {
      await _imprimanteService.definirParDefaut(id);
      _loadImprimantes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imprimante définie par défaut'), backgroundColor: Colors.green),
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

  Future<void> _testerImprimante(String id) async {
    try {
      final result = await _imprimanteService.testerImprimante(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Test effectué'),
            backgroundColor: result['status'] == 'success' ? Colors.green : Colors.orange,
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

  Future<void> _detecterImprimantesWindows() async {
    try {
      final result = await _imprimanteService.detecterImprimantesWindows();
      if (mounted) {
        if (result.containsKey('printers')) {
          final printers = result['printers'] as List;
          if (printers.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Aucune imprimante détectée'),
                backgroundColor: Colors.orange,
              ),
            );
          } else {
            // Afficher un dialogue pour sélectionner une imprimante à ajouter
            _showImprimantesDetectees(printers);
          }
        } else if (result.containsKey('error')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error']),
              backgroundColor: Colors.red,
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

  void _showImprimantesDetectees(List<dynamic> printers) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Imprimantes détectées'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: printers.length,
            itemBuilder: (context, index) {
              final printer = printers[index];
              return ListTile(
                title: Text(printer['nom'] ?? 'N/A'),
                subtitle: Text('Statut: ${printer['statut'] ?? 'N/A'}'),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateImprimanteScreen(
                          imprimantePreRemplie: Imprimante(
                            nom: printer['nom'] ?? '',
                            typeImprimante: 'locale',
                            nomSysteme: printer['nom_systeme'] ?? printer['nom'] ?? '',
                          ),
                        ),
                      ),
                    ).then((_) => _loadImprimantes());
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Future<void> _imprimerPageTest(String id) async {
    try {
      final result = await _imprimanteService.imprimerPageTest(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Page de test envoyée'),
            backgroundColor: result['status'] == 'success' ? Colors.green : Colors.orange,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barre d'actions
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Imprimantes configurées',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadImprimantes,
                    tooltip: 'Actualiser',
                  ),
                  Tooltip(
                    message: 'Détecter les imprimantes installées sur Windows',
                    child: OutlinedButton.icon(
                      onPressed: _detecterImprimantesWindows,
                      icon: const Icon(Icons.search),
                      label: const Text('Détecter (Windows)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateImprimanteScreen(),
                        ),
                      ).then((_) => _loadImprimantes());
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Nouvelle imprimante'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(),
        // Liste des imprimantes
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _imprimantes.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'Aucune imprimante configurée.\nCliquez sur "Nouvelle imprimante" pour en ajouter une.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _imprimantes.length,
                      itemBuilder: (context, index) {
                        final imprimante = _imprimantes[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: Icon(
                              imprimante.typeImprimante == 'locale'
                                  ? Icons.print
                                  : Icons.print_disabled,
                              color: imprimante.actif ? Colors.blue : Colors.grey,
                            ),
                            title: Row(
                              children: [
                                Text(imprimante.nom),
                                if (imprimante.imprimanteParDefaut) ...[
                                  const SizedBox(width: 8),
                                  Chip(
                                    label: const Text('Par défaut', style: TextStyle(fontSize: 10)),
                                    backgroundColor: Colors.green.shade100,
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                  ),
                                ],
                                if (!imprimante.actif) ...[
                                  const SizedBox(width: 8),
                                  Chip(
                                    label: const Text('Inactive', style: TextStyle(fontSize: 10)),
                                    backgroundColor: Colors.grey.shade200,
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Type: ${imprimante.typeImprimanteLabel}'),
                                if (imprimante.typeImprimante == 'reseau') ...[
                                  Text('IP: ${imprimante.adresseIp ?? "N/A"}'),
                                  Text('Port: ${imprimante.port}'),
                                  Text('Protocole: ${imprimante.protocoleLabel}'),
                                ] else ...[
                                  Text('Nom système: ${imprimante.nomSysteme ?? "N/A"}'),
                                ],
                                Text('Format: ${imprimante.formatPapierLabel} - ${imprimante.orientationLabel}'),
                                if (imprimante.connectionString != null)
                                  Text(
                                    'Connexion: ${imprimante.connectionString}',
                                    style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.print),
                                  onPressed: () => _imprimerPageTest(imprimante.id!),
                                  tooltip: 'Imprimer une page de test',
                                  color: Colors.blue,
                                ),
                                if (imprimante.typeImprimante == 'reseau')
                                  IconButton(
                                    icon: const Icon(Icons.network_check),
                                    onPressed: () => _testerImprimante(imprimante.id!),
                                    tooltip: 'Tester la connexion',
                                  ),
                                PopupMenuButton(
                                  itemBuilder: (context) => [
                                    if (!imprimante.imprimanteParDefaut)
                                      const PopupMenuItem(
                                        value: 'default',
                                        child: Row(
                                          children: [
                                            Icon(Icons.star, size: 20),
                                            SizedBox(width: 8),
                                            Text('Définir par défaut'),
                                          ],
                                        ),
                                      ),
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 20),
                                          SizedBox(width: 8),
                                          Text('Modifier'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, size: 20, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Supprimer', style: TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CreateImprimanteScreen(imprimante: imprimante),
                                        ),
                                      ).then((_) => _loadImprimantes());
                                    } else if (value == 'delete') {
                                      _deleteImprimante(imprimante.id!);
                                    } else if (value == 'default') {
                                      _definirParDefaut(imprimante.id!);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

