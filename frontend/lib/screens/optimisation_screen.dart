import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';
import '../widgets/tab_button.dart';
import '../models/debit/affaire_model.dart';
import '../models/debit/matiere_model.dart';
import '../models/debit/chute_model.dart';
import '../models/debit/stock_matiere_model.dart';
import '../services/debit_service.dart';

class OptimisationScreen extends StatefulWidget {
  const OptimisationScreen({super.key});

  @override
  State<OptimisationScreen> createState() => _OptimisationScreenState();
}

class _OptimisationScreenState extends State<OptimisationScreen> {
  final DebitService _debitService = DebitService();
  
  int _selectedTab = 0; // 0: Affaires, 1: Matières, 2: Stocks, 3: Chutes
  List<Affaire> _affaires = [];
  List<Matiere> _matieres = [];
  List<StockMatiere> _stocks = [];
  List<Chute> _chutes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAffaires();
    _loadMatieres();
    _loadStocks();
    _loadChutes();
  }

  Future<void> _loadAffaires() async {
    setState(() => _isLoading = true);
    try {
      final affaires = await _debitService.getAffaires();
      setState(() => _affaires = affaires);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMatieres() async {
    try {
      final matieres = await _debitService.getMatieres(actif: true);
      setState(() => _matieres = matieres);
    } catch (e) {
      // Ignorer silencieusement
    }
  }

  Future<void> _loadStocks() async {
    try {
      final stocks = await _debitService.getStocks(disponibles: true);
      setState(() => _stocks = stocks);
    } catch (e) {
      // Ignorer silencieusement
    }
  }

  Future<void> _loadChutes() async {
    try {
      final chutes = await _debitService.getChutes(disponibles: true);
      setState(() => _chutes = chutes);
    } catch (e) {
      // Ignorer silencieusement
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentRoute: '/optimisation',
      title: 'Débit',
      tabs: [
        TabButton(
          label: 'Affaires',
          isActive: _selectedTab == 0,
          onTap: () => setState(() => _selectedTab = 0),
        ),
        TabButton(
          label: 'Matières',
          isActive: _selectedTab == 1,
          onTap: () => setState(() => _selectedTab = 1),
        ),
        TabButton(
          label: 'Stocks',
          isActive: _selectedTab == 2,
          onTap: () => setState(() => _selectedTab = 2),
        ),
        TabButton(
          label: 'Chutes',
          isActive: _selectedTab == 3,
          onTap: () => setState(() => _selectedTab = 3),
        ),
      ],
      child: IndexedStack(
        index: _selectedTab,
        children: [
          _buildAffairesTab(),
          _buildMatieresTab(),
          _buildStocksTab(),
          _buildChutesTab(),
        ],
      ),
    );
  }

  Widget _buildAffairesTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadAffaires,
                tooltip: 'Actualiser',
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Créer une affaire
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Création d\'affaire à implémenter'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Nouvelle affaire'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _affaires.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.folder, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'Aucune affaire',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _affaires.length,
                        itemBuilder: (context, index) {
                          final affaire = _affaires[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const Icon(Icons.folder, size: 32),
                              title: Text(
                                affaire.numeroAffaire,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(affaire.nom),
                                  if (affaire.chantierNom != null)
                                    Text('Chantier: ${affaire.chantierNom}'),
                                  Text('Statut: ${affaire.statutLabel}'),
                                  if (affaire.lancements != null)
                                    Text('${affaire.lancements!.length} lancement(s)'),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.arrow_forward),
                                onPressed: () {
                                  // TODO: Ouvrir les détails de l'affaire
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Détails de l\'affaire à implémenter'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildMatieresTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadMatieres,
                tooltip: 'Actualiser',
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Créer une matière
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Création de matière à implémenter'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Nouvelle matière'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _matieres.isEmpty
              ? const Center(
                  child: Text(
                    'Aucune matière disponible',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _matieres.length,
                    itemBuilder: (context, index) {
                      final matiere = _matieres[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.category, color: Colors.indigo),
                          ),
                          title: Text(
                            matiere.code,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(matiere.designation),
                              Text('Type: ${matiere.typeLabel}'),
                              if (matiere.largeurStandard != null && matiere.longueurStandard != null)
                                Text(
                                  'Format standard: ${matiere.largeurStandard} x ${matiere.longueurStandard} mm',
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildStocksTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadStocks,
                tooltip: 'Actualiser',
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Créer un stock
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Création de stock à implémenter'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Nouveau stock'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _stocks.isEmpty
              ? const Center(
                  child: Text(
                    'Aucun stock disponible',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _stocks.length,
                    itemBuilder: (context, index) {
                      final stock = _stocks[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.inventory, color: Colors.green),
                          ),
                          title: Text(
                            stock.matiereDetail?.code ?? 'N/A',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Dimensions: ${stock.largeur} x ${stock.longueur} mm'),
                              Text('Quantité: ${stock.quantite} (Disponible: ${stock.quantiteDisponible})'),
                              if (stock.emplacement != null)
                                Text('Emplacement: ${stock.emplacement}'),
                            ],
                          ),
                          trailing: Text(
                            stock.statutLabel,
                            style: TextStyle(
                              color: stock.statut == 'disponible' ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildChutesTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadChutes,
                tooltip: 'Actualiser',
              ),
              const Expanded(
                child: Text(
                  'Chutes réutilisables',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _chutes.isEmpty
              ? const Center(
                  child: Text(
                    'Aucune chute disponible',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _chutes.length,
                    itemBuilder: (context, index) {
                      final chute = _chutes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.cut, color: Colors.orange),
                          ),
                          title: Text(
                            chute.matiereDetail?.code ?? 'N/A',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (chute.largeur != null && chute.longueur != null)
                                Text('Dimensions: ${chute.largeur} x ${chute.longueur} mm'),
                              if (chute.surface != null)
                                Text('Surface: ${chute.surface!.toStringAsFixed(0)} mm²'),
                              Text('Quantité: ${chute.quantite}'),
                            ],
                          ),
                          trailing: Text(
                            chute.statutLabel,
                            style: TextStyle(
                              color: chute.statut == 'disponible' ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
