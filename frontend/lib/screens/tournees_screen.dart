import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../widgets/main_layout.dart';
import '../widgets/tab_button.dart';
import '../models/tournees/tournee_model.dart';
import '../models/tournees/chariot_model.dart';
import '../models/tournees/vehicule_model.dart';
import '../models/tournees/chauffeur_model.dart';
import '../services/tournees_service.dart';
import 'create_tournee_screen.dart';
import 'create_chariot_screen.dart';
import 'create_vehicule_screen.dart';
import 'create_chauffeur_screen.dart';

class TourneesScreen extends StatefulWidget {
  const TourneesScreen({super.key});

  @override
  State<TourneesScreen> createState() => _TourneesScreenState();
}

class _TourneesScreenState extends State<TourneesScreen> {
  final TourneesService _tourneesService = TourneesService();
  
  int _selectedTab = 0; // 0: Tournées, 1: Véhicules, 2: Chauffeurs, 3: Chariots
  List<Tournee> _tournees = [];
  List<Chariot> _chariots = [];
  List<Vehicule> _vehicules = [];
  List<Chauffeur> _chauffeurs = [];
  Tournee? _selectedTournee;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTournees();
    _loadChariots();
    _loadVehicules();
    _loadChauffeurs();
  }

  Future<void> _loadTournees() async {
    setState(() => _isLoading = true);
    try {
      final tournees = await _tourneesService.getTournees();
      setState(() => _tournees = tournees);
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

  Future<void> _loadChariots() async {
    try {
      final chariots = await _tourneesService.getChariots();
      setState(() => _chariots = chariots);
    } catch (e) {
      // Ignorer les erreurs silencieusement
    }
  }

  Future<void> _loadVehicules() async {
    try {
      final vehicules = await _tourneesService.getVehicules();
      setState(() => _vehicules = vehicules);
    } catch (e) {
      // Ignorer les erreurs silencieusement
    }
  }

  Future<void> _loadChauffeurs() async {
    try {
      final chauffeurs = await _tourneesService.getChauffeurs();
      setState(() => _chauffeurs = chauffeurs);
    } catch (e) {
      // Ignorer les erreurs silencieusement
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentRoute: '/tournees',
      title: 'Tournées',
      tabs: [
        TabButton(
          label: 'Tournées',
          isActive: _selectedTab == 0,
          onTap: () => setState(() => _selectedTab = 0),
        ),
        TabButton(
          label: 'Véhicules',
          isActive: _selectedTab == 1,
          onTap: () => setState(() => _selectedTab = 1),
        ),
        TabButton(
          label: 'Chauffeurs',
          isActive: _selectedTab == 2,
          onTap: () => setState(() => _selectedTab = 2),
        ),
        TabButton(
          label: 'Chariots',
          isActive: _selectedTab == 3,
          onTap: () => setState(() => _selectedTab = 3),
        ),
      ],
      child: IndexedStack(
        index: _selectedTab,
        children: [
          _buildTourneesTab(),
          _buildVehiculesTab(),
          _buildChauffeursTab(),
          _buildChariotsTab(),
        ],
      ),
    );
  }

  Widget _buildTourneesTab() {
    return Column(
      children: [
        // En-tête avec actions
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
                onPressed: _loadTournees,
                tooltip: 'Actualiser',
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateTourneeScreen(),
                    ),
                  );
                  if (result == true) {
                    _loadTournees();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Nouvelle tournée'),
              ),
            ],
          ),
        ),
        
        // Contenu principal
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _tournees.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.local_shipping, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'Aucune tournée',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CreateTourneeScreen(),
                                ),
                              );
                              if (result == true) {
                                _loadTournees();
                              }
                            },
                            child: const Text('Créer une tournée'),
                          ),
                        ],
                      ),
                    )
                  : Row(
                      children: [
                        // Liste des tournées
                        Expanded(
                          flex: 1,
                          child: Container(
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
                              itemCount: _tournees.length,
                              itemBuilder: (context, index) {
                                final tournee = _tournees[index];
                                return _buildTourneeCard(tournee);
                              },
                            ),
                          ),
                        ),
                        
                        // Carte et détails
                        Expanded(
                          flex: 2,
                          child: Container(
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
                            child: _selectedTournee == null
                                ? _buildDefaultMapView()
                                : _buildMapView(_selectedTournee!),
                          ),
                        ),
                      ],
                    ),
        ),
      ],
    );
  }

  Widget _buildTourneeCard(Tournee tournee) {
    final isSelected = _selectedTournee?.id == tournee.id;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? Colors.blue.shade50 : Colors.white,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: tournee.statutColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            Icons.local_shipping,
            color: tournee.statutColor,
          ),
        ),
        title: Text(
          tournee.numeroTournee,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('dd/MM/yyyy').format(tournee.dateTournee)),
            if (tournee.chauffeurDetail != null)
              Text('Chauffeur: ${tournee.chauffeurDetail!.displayName}'),
            if (tournee.distanceTotale != null)
              Text('Distance: ${tournee.distanceTotale!.toStringAsFixed(1)} km'),
            if (tournee.livraisons != null)
              Text('${tournee.livraisons!.length} livraison(s)'),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'optimiser',
              child: Row(
                children: [
                  Icon(Icons.route, size: 20),
                  SizedBox(width: 8),
                  Text('Optimiser'),
                ],
              ),
            ),
            if (tournee.statut == 'planifiee')
              const PopupMenuItem(
                value: 'demarrer',
                child: Row(
                  children: [
                    Icon(Icons.play_arrow, size: 20),
                    SizedBox(width: 8),
                    Text('Démarrer'),
                  ],
                ),
              ),
            if (tournee.statut == 'en_cours')
              const PopupMenuItem(
                value: 'terminer',
                child: Row(
                  children: [
                    Icon(Icons.check, size: 20),
                    SizedBox(width: 8),
                    Text('Terminer'),
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
            if (value == 'optimiser') {
              _optimiserTournee(tournee);
            } else if (value == 'demarrer') {
              _demarrerTournee(tournee);
            } else if (value == 'terminer') {
              _terminerTournee(tournee);
            } else if (value == 'edit') {
              _editTournee(tournee);
            } else if (value == 'delete') {
              _deleteTournee(tournee);
            }
          },
        ),
        onTap: () {
          setState(() => _selectedTournee = tournee);
        },
      ),
    );
  }

  Widget _buildDefaultMapView() {
    // Carte par défaut centrée sur la France
    const center = LatLng(46.6034, 1.8883); // Centre de la France
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: const Row(
            children: [
              Icon(Icons.map, color: Colors.teal),
              SizedBox(width: 8),
              Text(
                'Carte des tournées',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 6.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.miroiterie.app',
              ),
              // Afficher tous les points de livraison de toutes les tournées
              MarkerLayer(
                markers: _buildAllTourneesMarkers(),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sélectionnez une tournée dans la liste pour voir son itinéraire détaillé',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              if (_tournees.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '${_tournees.length} tournée(s) au total',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  List<Marker> _buildAllTourneesMarkers() {
    final markers = <Marker>[];
    
    for (var tournee in _tournees) {
      if (tournee.livraisons != null) {
        for (var livraison in tournee.livraisons!) {
          if (livraison.latitude != null && livraison.longitude != null) {
            markers.add(
              Marker(
                point: LatLng(livraison.latitude!, livraison.longitude!),
                width: 30,
                height: 30,
                child: Container(
                  decoration: BoxDecoration(
                    color: tournee.statutColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '${livraison.ordreLivraison}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        }
      }
    }
    
    return markers;
  }

  Widget _buildMapView(Tournee tournee) {
    // Récupérer les points de livraison avec coordonnées
    final points = <LatLng>[];
    final markers = <Marker>[];
    
    if (tournee.livraisons != null) {
      for (var livraison in tournee.livraisons!) {
        if (livraison.latitude != null && livraison.longitude != null) {
          final point = LatLng(livraison.latitude!, livraison.longitude!);
          points.add(point);
          
          markers.add(
            Marker(
              point: point,
              width: 40,
              height: 40,
              child: Container(
                decoration: BoxDecoration(
                  color: livraison.statutColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '${livraison.ordreLivraison}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      }
    }
    
    // Calculer le centre de la carte
    LatLng center = const LatLng(46.6034, 1.8883); // Centre de la France par défaut
    if (points.isNotEmpty) {
      double avgLat = points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
      double avgLon = points.map((p) => p.longitude).reduce((a, b) => a + b) / points.length;
      center = LatLng(avgLat, avgLon);
    }
    
    return Column(
      children: [
        // En-tête de la tournée
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tournee.numeroTournee,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (tournee.chauffeurDetail != null)
                      Text('Chauffeur: ${tournee.chauffeurDetail!.displayName}'),
                    if (tournee.distanceTotale != null)
                      Text('Distance: ${tournee.distanceTotale!.toStringAsFixed(1)} km'),
                    if (tournee.dureeEstimee != null)
                      Text('Durée estimée: ${tournee.dureeEstimee} min'),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: tournee.statutColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tournee.statutLabel,
                  style: TextStyle(
                    color: tournee.statutColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Carte
        Expanded(
          child: FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: points.isNotEmpty ? 10.0 : 6.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.miroiterie.app',
              ),
              if (points.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: points,
                      strokeWidth: 3,
                      color: Colors.blue,
                    ),
                  ],
                ),
              MarkerLayer(markers: markers),
            ],
          ),
        ),
        
        // Liste des livraisons
        if (tournee.livraisons != null && tournee.livraisons!.isNotEmpty)
          Container(
            height: 200,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: ListView.builder(
              itemCount: tournee.livraisons!.length,
              itemBuilder: (context, index) {
                final livraison = tournee.livraisons![index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: livraison.statutColor,
                    child: Text(
                      '${livraison.ordreLivraison}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(livraison.chantierNom ?? 'Chantier inconnu'),
                  subtitle: Text(livraison.adresseLivraison),
                  trailing: Text(
                    livraison.statutLabel,
                    style: TextStyle(
                      color: livraison.statutColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildVehiculesTab() {
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
                onPressed: _loadVehicules,
                tooltip: 'Actualiser',
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateVehiculeScreen(),
                    ),
                  );
                  if (result == true) {
                    _loadVehicules();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Nouveau véhicule'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _vehicules.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.directions_car, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Aucun véhicule',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateVehiculeScreen(),
                            ),
                          );
                          if (result == true) {
                            _loadVehicules();
                          }
                        },
                        child: const Text('Créer un véhicule'),
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
                    itemCount: _vehicules.length,
                    itemBuilder: (context, index) {
                      final vehicule = _vehicules[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.directions_car, size: 32),
                          title: Text(
                            vehicule.immatriculation,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${vehicule.marque} ${vehicule.modele}'),
                              Text('Type: ${vehicule.typeLabel}'),
                              if (vehicule.capaciteCharge != null)
                                Text('Capacité: ${vehicule.capaciteCharge} kg'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!vehicule.actif)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Inactif',
                                    style: TextStyle(fontSize: 12),
                                  ),
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
                                    _editVehicule(vehicule);
                                  } else if (value == 'delete') {
                                    _deleteVehicule(vehicule);
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
        ),
      ],
    );
  }

  Widget _buildChauffeursTab() {
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
                onPressed: _loadChauffeurs,
                tooltip: 'Actualiser',
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateChauffeurScreen(),
                    ),
                  );
                  if (result == true) {
                    _loadChauffeurs();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Nouveau chauffeur'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _chauffeurs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Aucun chauffeur',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateChauffeurScreen(),
                            ),
                          );
                          if (result == true) {
                            _loadChauffeurs();
                          }
                        },
                        child: const Text('Créer un chauffeur'),
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
                    itemCount: _chauffeurs.length,
                    itemBuilder: (context, index) {
                      final chauffeur = _chauffeurs[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.person, size: 32),
                          title: Text(
                            chauffeur.displayName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Permis: ${chauffeur.numeroPermis}'),
                              Text('Expiration: ${DateFormat('dd/MM/yyyy').format(chauffeur.dateExpirationPermis)}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!chauffeur.actif)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Inactif',
                                    style: TextStyle(fontSize: 12),
                                  ),
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
                                    _editChauffeur(chauffeur);
                                  } else if (value == 'delete') {
                                    _deleteChauffeur(chauffeur);
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
        ),
      ],
    );
  }

  Widget _buildChariotsTab() {
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
                onPressed: _loadChariots,
                tooltip: 'Actualiser',
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateChariotScreen(),
                    ),
                  );
                  if (result == true) {
                    _loadChariots();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Nouveau chariot'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _chariots.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_cart, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Aucun chariot',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateChariotScreen(),
                            ),
                          );
                          if (result == true) {
                            _loadChariots();
                          }
                        },
                        child: const Text('Créer un chariot'),
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
                    itemCount: _chariots.length,
                    itemBuilder: (context, index) {
                      final chariot = _chariots[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.shopping_cart, size: 32),
                          title: Text(
                            chariot.numero,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Type: ${chariot.type}'),
                              if (chariot.capacite != null)
                                Text('Capacité: ${chariot.capacite}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!chariot.actif)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Inactif',
                                    style: TextStyle(fontSize: 12),
                                  ),
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
                                    _editChariot(chariot);
                                  } else if (value == 'delete') {
                                    _deleteChariot(chariot);
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
        ),
      ],
    );
  }

  Future<void> _optimiserTournee(Tournee tournee) async {
    if (tournee.id == null) return;
    
    try {
      final updated = await _tourneesService.optimiserTournee(tournee.id!);
      _loadTournees();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tournée optimisée. Distance: ${updated.distanceTotale?.toStringAsFixed(1) ?? "N/A"} km'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _selectedTournee = updated);
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

  Future<void> _demarrerTournee(Tournee tournee) async {
    if (tournee.id == null) return;
    
    try {
      final updated = await _tourneesService.demarrerTournee(tournee.id!);
      _loadTournees();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tournée démarrée'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _selectedTournee = updated);
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

  Future<void> _terminerTournee(Tournee tournee) async {
    if (tournee.id == null) return;
    
    try {
      final updated = await _tourneesService.terminerTournee(tournee.id!);
      _loadTournees();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tournée terminée'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _selectedTournee = updated);
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

  Future<void> _editTournee(Tournee tournee) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTourneeScreen(tournee: tournee),
      ),
    );
    if (result == true) {
      _loadTournees();
    }
  }

  Future<void> _deleteTournee(Tournee tournee) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer la tournée ${tournee.numeroTournee} ?'),
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

    if (confirm == true && tournee.id != null) {
      try {
        await _tourneesService.deleteTournee(tournee.id!);
        _loadTournees();
        setState(() => _selectedTournee = null);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tournée supprimée avec succès'),
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

  Future<void> _editChariot(Chariot chariot) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateChariotScreen(chariot: chariot),
      ),
    );
    if (result == true) {
      _loadChariots();
    }
  }

  Future<void> _deleteChariot(Chariot chariot) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer le chariot ${chariot.numero} ?'),
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

    if (confirm == true && chariot.id != null) {
      try {
        await _tourneesService.deleteChariot(chariot.id!);
        _loadChariots();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chariot supprimé avec succès'),
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

  Future<void> _editVehicule(Vehicule vehicule) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateVehiculeScreen(vehicule: vehicule),
      ),
    );
    if (result == true) {
      _loadVehicules();
    }
  }

  Future<void> _deleteVehicule(Vehicule vehicule) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer le véhicule ${vehicule.immatriculation} ?'),
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

    if (confirm == true && vehicule.id != null) {
      try {
        await _tourneesService.deleteVehicule(vehicule.id!);
        _loadVehicules();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Véhicule supprimé avec succès'),
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

  Future<void> _editChauffeur(Chauffeur chauffeur) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateChauffeurScreen(chauffeur: chauffeur),
      ),
    );
    if (result == true) {
      _loadChauffeurs();
    }
  }

  Future<void> _deleteChauffeur(Chauffeur chauffeur) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer le chauffeur ${chauffeur.displayName} ?'),
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

    if (confirm == true && chauffeur.id != null) {
      try {
        await _tourneesService.deleteChauffeur(chauffeur.id!);
        _loadChauffeurs();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chauffeur supprimé avec succès'),
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
}
