import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/client_service.dart';
import '../services/devis_service.dart';
import '../services/facture_service.dart';
import '../services/chantier_service.dart';
import '../services/print_service.dart';
import '../pdf_generators/facture_pdf_generator.dart';
import '../models/client_model.dart';
import '../models/devis_model.dart';
import '../models/facture_model.dart';
import '../models/chantier_model.dart';
import '../widgets/main_layout.dart';
import '../widgets/tab_button.dart';
import '../theme/app_theme.dart';
import 'create_client_screen.dart';
import 'create_devis_screen.dart';
import 'create_facture_screen.dart';
import 'create_chantier_screen.dart';
import 'facture_detail_screen.dart';

class CommercialeScreen extends StatefulWidget {
  const CommercialeScreen({super.key});

  @override
  State<CommercialeScreen> createState() => _CommercialeScreenState();
}

class _CommercialeScreenState extends State<CommercialeScreen> {
  final ClientService _clientService = ClientService();
  final DevisService _devisService = DevisService();
  final FactureService _factureService = FactureService();
  final ChantierService _chantierService = ChantierService();
  final PrintService _printService = PrintService();
  int _selectedTab = 0; // 0: Clients, 1: Devis, 2: Factures, 3: Chantiers
  List<Client> _clients = [];
  List<Client> _filteredClients = [];
  List<Devis> _devis = [];
  List<Facture> _factures = [];
  List<Chantier> _chantiers = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAllData();
    _searchController.addListener(_filterClients);
  }

  Future<void> _loadAllData() async {
    // Charger les données séquentiellement pour mieux gérer les erreurs
    try {
      await _loadClients();
    } catch (e) {
      debugPrint('Erreur lors du chargement des clients: $e');
    }
    
    try {
      await _loadDevis();
    } catch (e) {
      debugPrint('Erreur lors du chargement des devis: $e');
    }
    
    try {
      await _loadFactures();
    } catch (e) {
      debugPrint('Erreur lors du chargement des factures: $e');
    }
    
    try {
      await _loadChantiers();
    } catch (e) {
      debugPrint('Erreur lors du chargement des chantiers: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterClients() {
    final query = _searchController.text.toLowerCase().trim();
    
    if (query.isEmpty) {
      setState(() {
        _filteredClients = _clients;
      });
      return;
    }

    setState(() {
      _filteredClients = _clients.where((client) {
        // Recherche dans le nom
        if (client.nom.toLowerCase().contains(query)) return true;
        
        // Recherche dans le prénom
        if (client.prenom != null && 
            client.prenom!.toLowerCase().contains(query)) return true;
        
        // Recherche dans la raison sociale
        if (client.raisonSociale != null && 
            client.raisonSociale!.toLowerCase().contains(query)) return true;
        
        // Recherche dans l'email
        if (client.email != null && 
            client.email!.toLowerCase().contains(query)) return true;
        
        // Recherche dans le téléphone
        if (client.telephone != null && 
            client.telephone!.contains(query)) return true;
        
        // Recherche dans la ville
        if (client.ville.toLowerCase().contains(query)) return true;
        
        // Recherche dans le code postal
        if (client.codePostal.contains(query)) return true;
        
        // Recherche dans l'adresse
        if (client.adresse.toLowerCase().contains(query)) return true;
        
        // Recherche dans le SIRET
        if (client.siret != null && 
            client.siret!.contains(query)) return true;
        
        // Recherche dans le nom complet (displayName)
        if (client.displayName.toLowerCase().contains(query)) return true;
        
        return false;
      }).toList();
    });
  }

  Future<void> _loadClients() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final clients = await _clientService.getClients();
      setState(() {
        _clients = clients;
        _filteredClients = clients;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Erreur _loadClients: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des clients: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      rethrow;
    }
  }

  Future<void> _deleteClient(Client client) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer ${client.displayName} ?'),
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

    if (confirm == true) {
      try {
        await _clientService.deleteClient(client.id!);
        _loadClients();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Client supprimé avec succès'),
              backgroundColor: Colors.green,
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
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentRoute: '/commerciale',
      title: 'Gestion commerciale',
      searchBar: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher...',
          prefixIcon: const Icon(Icons.search, color: AppTheme.textGrey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      tabs: [
        TabButton(
          label: 'Clients',
          isActive: _selectedTab == 0,
          onTap: () => setState(() => _selectedTab = 0),
        ),
        TabButton(
          label: 'Devis',
          isActive: _selectedTab == 1,
          onTap: () => setState(() => _selectedTab = 1),
        ),
        TabButton(
          label: 'Factures',
          isActive: _selectedTab == 2,
          onTap: () => setState(() => _selectedTab = 2),
        ),
        TabButton(
          label: 'Chantiers',
          isActive: _selectedTab == 3,
          onTap: () => setState(() => _selectedTab = 3),
        ),
      ],
      child: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                _buildClientsTab(),
                _buildDevisTab(),
                _buildFacturesTab(),
                _buildChantiersTab(),
              ],
            ),
          ),
          // Bouton d'action flottant en bas
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    if (_selectedTab == 0) {
                      _navigateToCreateClient();
                    } else if (_selectedTab == 1) {
                      _navigateToCreateDevis();
                    } else if (_selectedTab == 2) {
                      _navigateToCreateFacture();
                    } else if (_selectedTab == 3) {
                      _navigateToCreateChantier();
                    }
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_clients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Aucun client',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _navigateToCreateClient,
              child: const Text('Créer un client'),
            ),
          ],
        ),
      );
    }

    // Trier les clients filtrés par nom de famille
    final sortedClients = List<Client>.from(_filteredClients)
      ..sort((a, b) => a.nom.toLowerCase().compareTo(b.nom.toLowerCase()));

    // Grouper les clients par première lettre du nom
    final Map<String, List<Client>> clientsByLetter = {};
    for (var client in sortedClients) {
      final firstLetter = client.nom[0].toUpperCase();
      if (!clientsByLetter.containsKey(firstLetter)) {
        clientsByLetter[firstLetter] = [];
      }
      clientsByLetter[firstLetter]!.add(client);
    }

    // Obtenir toutes les lettres disponibles
    final letters = clientsByLetter.keys.toList()..sort();

    return RefreshIndicator(
      onRefresh: _loadClients,
      child: DefaultTabController(
        length: letters.isEmpty ? 1 : letters.length,
        child: Column(
          children: [
            // Onglets alphabétiques (seulement si pas de recherche active)
            if (letters.isNotEmpty && _searchController.text.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: TabBar(
                  isScrollable: true,
                  tabs: letters.map((letter) => Tab(text: letter)).toList(),
                  indicatorColor: AppTheme.activeTabBg,
                  labelColor: AppTheme.textDark,
                  unselectedLabelColor: AppTheme.textGrey,
                ),
              ),
            // Liste des clients
            Expanded(
              child: letters.isEmpty
                  ? _buildEmptySearchResult()
                  : _searchController.text.isNotEmpty
                      ? _buildSearchResults(sortedClients)
                      : TabBarView(
                          children: letters.map((letter) {
                            final clients = clientsByLetter[letter]!;
                            return _buildClientList(clients);
                          }).toList(),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientList(List<Client> clients) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: clients.length,
        itemBuilder: (context, index) {
          final client = clients[index];
          return _buildClientTableRow(client);
        },
      ),
    );
  }

  Widget _buildSearchResults(List<Client> clients) {
    if (clients.isEmpty) {
      return _buildEmptySearchResult();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: clients.length,
        itemBuilder: (context, index) {
          final client = clients[index];
          return _buildClientTableRow(client);
        },
      ),
    );
  }

  Widget _buildClientTableRow(Client client) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryDark,
          child: Text(
            client.nom[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          client.displayName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (client.email != null) Text(client.email!, style: const TextStyle(fontSize: 12)),
            if (client.telephone != null) Text(client.telephone!, style: const TextStyle(fontSize: 12)),
            Text('${client.codePostal} ${client.ville}', style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: PopupMenuButton(
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
              _navigateToEditClient(client);
            } else if (value == 'delete') {
              _deleteClient(client);
            }
          },
        ),
        onTap: () {
          _navigateToEditClient(client);
        },
      ),
    );
  }

  Widget _buildEmptySearchResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? 'Aucun client trouvé'
                : 'Aucun résultat pour "${_searchController.text}"',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          if (_searchController.text.isNotEmpty)
            TextButton(
              onPressed: () {
                _searchController.clear();
              },
              child: const Text('Effacer la recherche'),
            ),
        ],
      ),
    );
  }

  void _navigateToCreateClient() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateClientScreen(),
      ),
    );

    if (result == true) {
      _loadClients();
    }
  }

  void _navigateToEditClient(Client client) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateClientScreen(client: client),
      ),
    );

    if (result == true) {
      _loadClients();
    }
  }

  Future<void> _loadDevis() async {
    try {
      final devis = await _devisService.getDevis();
      setState(() {
        _devis = devis;
      });
    } catch (e, stackTrace) {
      debugPrint('Erreur _loadDevis: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des devis: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      rethrow;
    }
  }

  Future<void> _deleteDevis(Devis devis) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer le devis ${devis.numeroDevis ?? devis.id} ?'),
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

    if (confirm == true && devis.id != null) {
      try {
        await _devisService.deleteDevis(devis.id!);
        _loadDevis();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Devis supprimé avec succès'),
              backgroundColor: Colors.green,
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
  }

  void _navigateToCreateDevis() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateDevisScreen(),
      ),
    );

    if (result == true) {
      _loadDevis();
    }
  }

  void _navigateToEditDevis(Devis devis) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateDevisScreen(devis: devis),
      ),
    );

    if (result == true) {
      _loadDevis();
    }
  }

  Widget _buildDevisTab() {
    if (_devis.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.description_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Aucun devis',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _navigateToCreateDevis,
              child: const Text('Créer un devis'),
            ),
          ],
        ),
      );
    }

    // Trier par date de création (plus récent en premier)
    final sortedDevis = List<Devis>.from(_devis)
      ..sort((a, b) {
        if (a.dateCreation == null || b.dateCreation == null) return 0;
        return b.dateCreation!.compareTo(a.dateCreation!);
      });

    return RefreshIndicator(
      onRefresh: _loadDevis,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: sortedDevis.length,
          itemBuilder: (context, index) {
            final devis = sortedDevis[index];
            return _buildDevisTableRow(devis);
          },
        ),
      ),
    );
  }

  Widget _buildDevisTableRow(Devis devis) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: ListTile(
        leading: SizedBox(
          width: 60,
          child: Text(
            devis.numeroDevis ?? 'N/A',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        title: Text(
          devis.client?.displayName ?? 'Client inconnu',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: devis.dateCreation != null
            ? Text(DateFormat('dd/MM/yyyy').format(devis.dateCreation!))
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${devis.montantTtc.toStringAsFixed(2)} €',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 16),
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
                  _navigateToEditDevis(devis);
                } else if (value == 'delete') {
                  _deleteDevis(devis);
                }
              },
            ),
          ],
        ),
        onTap: () {
          _navigateToEditDevis(devis);
        },
      ),
    );
  }


  Future<void> _loadFactures() async {
    try {
      final factures = await _factureService.getFactures();
      setState(() {
        _factures = factures;
      });
    } catch (e, stackTrace) {
      debugPrint('Erreur _loadFactures: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des factures: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      rethrow;
    }
  }

  Future<void> _loadChantiers() async {
    try {
      final chantiers = await _chantierService.getChantiers();
      setState(() {
        _chantiers = chantiers;
      });
    } catch (e, stackTrace) {
      debugPrint('Erreur _loadChantiers: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des chantiers: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      rethrow;
    }
  }

  Widget _buildFacturesTab() {
    if (_factures.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Aucune facture',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _navigateToCreateFacture,
              child: const Text('Créer une facture'),
            ),
          ],
        ),
      );
    }

    // Trier par date de facture (plus récent en premier)
    final sortedFactures = List<Facture>.from(_factures)
      ..sort((a, b) => b.dateFacture.compareTo(a.dateFacture));

    return RefreshIndicator(
      onRefresh: _loadFactures,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: sortedFactures.length,
          itemBuilder: (context, index) {
            final facture = sortedFactures[index];
            return _buildFactureTableRow(facture);
          },
        ),
      ),
    );
  }

  Widget _buildFactureTableRow(Facture facture) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 60,
          child: Text(
            facture.numeroFacture,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        title: Text(
          facture.clientNom ?? 'Client inconnu',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('dd/MM/yyyy').format(facture.dateFacture)),
            if (facture.montantRestant != null && facture.montantRestant! > 0)
              Text(
                'Reste: ${facture.montantRestant!.toStringAsFixed(2)} €',
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: facture.statutColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                facture.statutLabel,
                style: TextStyle(
                  color: facture.statutColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${facture.montantTtc.toStringAsFixed(2)} €',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 16),
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'print',
                  child: Row(
                    children: [
                      Icon(Icons.print, size: 20),
                      SizedBox(width: 8),
                      Text('Imprimer'),
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
                if (value == 'print') {
                  _imprimerFacture(facture);
                } else if (value == 'edit') {
                  _navigateToEditFacture(facture);
                } else if (value == 'delete') {
                  _deleteFacture(facture);
                }
              },
            ),
          ],
        ),
        onTap: () {
          _navigateToFactureDetail(facture);
        },
      ),
    );
  }

  Widget _buildChantiersTab() {
    if (_chantiers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Aucun chantier',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _navigateToCreateChantier,
              child: const Text('Créer un chantier'),
            ),
          ],
        ),
      );
    }

    // Trier par date de début (plus récent en premier)
    final sortedChantiers = List<Chantier>.from(_chantiers)
      ..sort((a, b) => b.dateDebut.compareTo(a.dateDebut));

    return RefreshIndicator(
      onRefresh: _loadChantiers,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: sortedChantiers.length,
          itemBuilder: (context, index) {
            final chantier = sortedChantiers[index];
            return _buildChantierTableRow(chantier);
          },
        ),
      ),
    );
  }

  Widget _buildChantierTableRow(Chantier chantier) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: chantier.statutColor.withOpacity(0.1),
          child: Icon(
            Icons.construction,
            color: chantier.statutColor,
          ),
        ),
        title: Text(
          chantier.nom,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(chantier.clientNom ?? 'Client inconnu'),
            Text(
              '${DateFormat('dd/MM/yyyy').format(chantier.dateDebut)} - ${DateFormat('dd/MM/yyyy').format(chantier.dateFinPrevue)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: chantier.statutColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                chantier.statutLabel,
                style: TextStyle(
                  color: chantier.statutColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 16),
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
                  _navigateToEditChantier(chantier);
                } else if (value == 'delete') {
                  _deleteChantier(chantier);
                }
              },
            ),
          ],
        ),
        onTap: () {
          _navigateToEditChantier(chantier);
        },
      ),
    );
  }

  Future<void> _imprimerFacture(Facture facture) async {
    try {
      // Charger la facture complète avec le client et le devis
      final factureComplet = await _factureService.getFactureById(facture.id!);
      Client? client;
      Devis? devis;
      
      if (factureComplet.clientId.isNotEmpty) {
        try {
          client = await _clientService.getClient(factureComplet.clientId);
        } catch (e) {
          // Client non trouvé, continuer sans
        }
      }
      
      if (factureComplet.devisId != null) {
        try {
          devis = await _devisService.getDevisById(factureComplet.devisId!);
        } catch (e) {
          // Devis non trouvé, continuer sans
        }
      }

      // Générer le PDF
      final pdfDoc = FacturePdfGenerator.generateFacture(factureComplet, client: client, devis: devis);

      // Imprimer
      final success = await _printService.imprimerAvecSelection(pdfDoc);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Impression lancée' : 'Erreur lors de l\'impression'),
            backgroundColor: success ? Colors.green : Colors.red,
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

  Future<void> _deleteFacture(Facture facture) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer la facture ${facture.numeroFacture} ?'),
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

    if (confirm == true && facture.id != null) {
      try {
        await _factureService.deleteFacture(facture.id!);
        _loadFactures();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Facture supprimée avec succès'),
              backgroundColor: Colors.green,
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
  }

  Future<void> _deleteChantier(Chantier chantier) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer le chantier "${chantier.nom}" ?'),
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

    if (confirm == true && chantier.id != null) {
      try {
        await _chantierService.deleteChantier(chantier.id!);
        _loadChantiers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chantier supprimé avec succès'),
              backgroundColor: Colors.green,
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
  }

  void _navigateToCreateFacture() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateFactureScreen(),
      ),
    );

    if (result == true) {
      _loadFactures();
    }
  }

  void _navigateToEditFacture(Facture facture) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateFactureScreen(facture: facture),
      ),
    );

    if (result == true) {
      _loadFactures();
    }
  }

  void _navigateToFactureDetail(Facture facture) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FactureDetailScreen(facture: facture),
      ),
    );
    // Recharger les factures pour mettre à jour les statuts
    _loadFactures();
  }

  void _navigateToCreateChantier() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateChantierScreen(),
      ),
    );

    if (result == true) {
      _loadChantiers();
    }
  }

  void _navigateToEditChantier(Chantier chantier) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateChantierScreen(chantier: chantier),
      ),
    );

    if (result == true) {
      _loadChantiers();
    }
  }
}

