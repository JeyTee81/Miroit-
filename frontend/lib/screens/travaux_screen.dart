import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/travaux_service.dart';
import '../models/travaux/devis_travaux_model.dart';
import '../models/travaux/commande_travaux_model.dart';
import '../models/travaux/facture_travaux_model.dart';
import '../widgets/main_layout.dart';
import '../widgets/tab_button.dart';
import 'create_devis_travaux_screen.dart';
import 'create_facture_travaux_screen.dart';
import 'create_commande_travaux_screen.dart';

class TravauxScreen extends StatefulWidget {
  const TravauxScreen({super.key});

  @override
  State<TravauxScreen> createState() => _TravauxScreenState();
}

class _TravauxScreenState extends State<TravauxScreen> {
  final TravauxService _travauxService = TravauxService();
  int _selectedTab = 0; // 0: Devis, 1: Commandes, 2: Factures
  List<DevisTravaux> _devis = [];
  List<CommandeTravaux> _commandes = [];
  List<FactureTravaux> _factures = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        _travauxService.getDevisTravaux(),
        _travauxService.getCommandesTravaux(),
        _travauxService.getFacturesTravaux(),
      ]);

      setState(() {
        _devis = results[0] as List<DevisTravaux>;
        _commandes = results[1] as List<CommandeTravaux>;
        _factures = results[2] as List<FactureTravaux>;
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

  Future<void> _deleteDevis(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce devis ?'),
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
        await _travauxService.deleteDevisTravaux(id);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Devis supprimé'), backgroundColor: Colors.green),
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

  Future<void> _deleteCommande(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette commande ?'),
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
        await _travauxService.deleteCommandeTravaux(id);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Commande supprimée'), backgroundColor: Colors.green),
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

  Future<void> _deleteFacture(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette facture ?'),
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
        await _travauxService.deleteFactureTravaux(id);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Facture supprimée'), backgroundColor: Colors.green),
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

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentRoute: '/travaux',
      title: 'Travaux',
      child: Column(
        children: [
          // Onglets
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                TabButton(
                  label: 'Devis',
                  isActive: _selectedTab == 0,
                  onTap: () => setState(() => _selectedTab = 0),
                ),
                const SizedBox(width: 8),
                TabButton(
                  label: 'Commandes',
                  isActive: _selectedTab == 1,
                  onTap: () => setState(() => _selectedTab = 1),
                ),
                const SizedBox(width: 8),
                TabButton(
                  label: 'Factures',
                  isActive: _selectedTab == 2,
                  onTap: () => setState(() => _selectedTab = 2),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadData,
                  tooltip: 'Actualiser',
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_selectedTab == 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateDevisTravauxScreen(),
                        ),
                      ).then((_) => _loadData());
                    } else if (_selectedTab == 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateCommandeTravauxScreen(),
                        ),
                      ).then((_) => _loadData());
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateFactureTravauxScreen(),
                        ),
                      ).then((_) => _loadData());
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: Text(_selectedTab == 0
                      ? 'Nouveau devis'
                      : _selectedTab == 1
                          ? 'Nouvelle commande'
                          : 'Nouvelle facture'),
                ),
              ],
            ),
          ),
          const Divider(),
          // Contenu
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_selectedTab == 0) {
      return _buildDevisList();
    } else if (_selectedTab == 1) {
      return _buildCommandesList();
    } else {
      return _buildFacturesList();
    }
  }

  Widget _buildDevisList() {
    if (_devis.isEmpty) {
      return const Center(child: Text('Aucun devis'));
    }

    return ListView.builder(
      itemCount: _devis.length,
      itemBuilder: (context, index) {
        final devis = _devis[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(devis.numeroDevis),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Client: ${devis.clientNom ?? "N/A"}'),
                Text('Type: ${devis.typeTravaux}'),
                Text('Date: ${DateFormat('dd/MM/yyyy').format(devis.dateDevis)}'),
                Text('Montant TTC: ${NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(devis.montantTtc)}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(
                  label: Text(devis.statutLabel),
                  backgroundColor: devis.statutColor.withOpacity(0.2),
                  labelStyle: TextStyle(color: devis.statutColor),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
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
                          builder: (context) => CreateDevisTravauxScreen(devis: devis),
                        ),
                      ).then((_) => _loadData());
                    } else if (value == 'delete') {
                      _deleteDevis(devis.id!);
                    }
                  },
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateDevisTravauxScreen(devis: devis),
                ),
              ).then((_) => _loadData());
            },
          ),
        );
      },
    );
  }

  Widget _buildCommandesList() {
    if (_commandes.isEmpty) {
      return const Center(child: Text('Aucune commande'));
    }

    return ListView.builder(
      itemCount: _commandes.length,
      itemBuilder: (context, index) {
        final commande = _commandes[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(commande.numeroCommande),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Client: ${commande.clientNom ?? "N/A"}'),
                Text('Type: ${commande.typeTravaux}'),
                Text('Date: ${DateFormat('dd/MM/yyyy').format(commande.dateCommande)}'),
                Text('Montant TTC: ${NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(commande.montantTtc)}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(
                  label: Text(commande.statutLabel),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
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
                          builder: (context) => CreateCommandeTravauxScreen(commande: commande),
                        ),
                      ).then((_) => _loadData());
                    } else if (value == 'delete') {
                      _deleteCommande(commande.id!);
                    }
                  },
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateCommandeTravauxScreen(commande: commande),
                ),
              ).then((_) => _loadData());
            },
          ),
        );
      },
    );
  }

  Widget _buildFacturesList() {
    if (_factures.isEmpty) {
      return const Center(child: Text('Aucune facture'));
    }

    return ListView.builder(
      itemCount: _factures.length,
      itemBuilder: (context, index) {
        final facture = _factures[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(facture.numeroFacture),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Client: ${facture.clientNom ?? "N/A"}'),
                Text('Type: ${facture.typeTravaux}'),
                Text('Date: ${DateFormat('dd/MM/yyyy').format(facture.dateFacture)}'),
                Text('Montant TTC: ${NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(facture.montantTtc)}'),
                if (facture.montantRestant > 0)
                  Text(
                    'Restant: ${NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(facture.montantRestant)}',
                    style: const TextStyle(color: Colors.orange),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(
                  label: Text(facture.statutLabel),
                  backgroundColor: facture.statutColor.withOpacity(0.2),
                  labelStyle: TextStyle(color: facture.statutColor),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
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
                          builder: (context) => CreateFactureTravauxScreen(facture: facture),
                        ),
                      ).then((_) => _loadData());
                    } else if (value == 'delete') {
                      _deleteFacture(facture.id!);
                    }
                  },
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateFactureTravauxScreen(facture: facture),
                ),
              ).then((_) => _loadData());
            },
          ),
        );
      },
    );
  }
}
