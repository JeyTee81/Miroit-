import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../widgets/main_layout.dart';
import '../widgets/tab_button.dart';
import '../models/vitrages/projet_vitrage_model.dart';
import '../models/vitrages/calcul_vitrage_model.dart';
import '../models/vitrages/region_vent_neige_model.dart';
import '../models/vitrages/categorie_terrain_model.dart';
import '../services/vitrages_service.dart';
import '../services/print_service.dart';
import '../pdf_generators/note_calcul_vitrage_pdf_generator.dart';
import 'create_projet_vitrage_screen.dart';
import 'create_calcul_vitrage_screen.dart';

class VitragesScreen extends StatefulWidget {
  const VitragesScreen({super.key});

  @override
  State<VitragesScreen> createState() => _VitragesScreenState();
}

class _VitragesScreenState extends State<VitragesScreen> {
  final VitragesService _vitragesService = VitragesService();
  final PrintService _printService = PrintService();
  
  int _selectedTab = 0; // 0: Projets, 1: Calculs, 2: Carte régions, 3: Catégories terrain
  List<ProjetVitrage> _projets = [];
  List<CalculVitrage> _calculs = [];
  List<RegionVentNeige> _regions = [];
  List<CategorieTerrain> _categoriesTerrain = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProjets();
    _loadRegions();
    _loadCategoriesTerrain();
  }

  Future<void> _loadProjets() async {
    setState(() => _isLoading = true);
    try {
      final projets = await _vitragesService.getProjets();
      setState(() => _projets = projets);
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

  Future<void> _loadRegions() async {
    try {
      final regions = await _vitragesService.getRegionsVentNeige(actif: true);
      setState(() => _regions = regions);
    } catch (e) {
      // Ignorer les erreurs silencieusement
    }
  }

  Future<void> _loadCategoriesTerrain() async {
    try {
      final categories = await _vitragesService.getCategoriesTerrain(actif: true);
      setState(() => _categoriesTerrain = categories);
    } catch (e) {
      // Ignorer les erreurs silencieusement
    }
  }

  Future<void> _loadCalculs(String projetId) async {
    try {
      final calculs = await _vitragesService.getCalculs(projetId: projetId);
      setState(() => _calculs = calculs);
    } catch (e) {
      // Ignorer les erreurs silencieusement
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentRoute: '/vitrages',
      title: 'Vitrages',
      tabs: [
        TabButton(
          label: 'Projets',
          isActive: _selectedTab == 0,
          onTap: () => setState(() => _selectedTab = 0),
        ),
        TabButton(
          label: 'Calculs',
          isActive: _selectedTab == 1,
          onTap: () => setState(() => _selectedTab = 1),
        ),
        TabButton(
          label: 'Carte régions',
          isActive: _selectedTab == 2,
          onTap: () => setState(() => _selectedTab = 2),
        ),
        TabButton(
          label: 'Catégories terrain',
          isActive: _selectedTab == 3,
          onTap: () => setState(() => _selectedTab = 3),
        ),
      ],
      child: IndexedStack(
        index: _selectedTab,
        children: [
          _buildProjetsTab(),
          _buildCalculsTab(),
          _buildCarteRegionsTab(),
          _buildCategoriesTerrainTab(),
        ],
      ),
    );
  }

  Widget _buildProjetsTab() {
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
                onPressed: _loadProjets,
                tooltip: 'Actualiser',
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateProjetVitrageScreen(),
                    ),
                  );
                  if (result == true) {
                    _loadProjets();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Nouveau projet'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _projets.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.window, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'Aucun projet',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CreateProjetVitrageScreen(),
                                ),
                              );
                              if (result == true) {
                                _loadProjets();
                              }
                            },
                            child: const Text('Créer un projet'),
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
                        itemCount: _projets.length,
                        itemBuilder: (context, index) {
                          final projet = _projets[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const Icon(Icons.folder, size: 32),
                              title: Text(
                                projet.numeroProjet,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(projet.nom),
                                  if (projet.chantierNom != null)
                                    Text('Chantier: ${projet.chantierNom}'),
                                  Text(DateFormat('dd/MM/yyyy').format(projet.dateCreation)),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.arrow_forward),
                                onPressed: () {
                                  _loadCalculs(projet.id!);
                                  setState(() => _selectedTab = 1);
                                },
                              ),
                              onTap: () {
                                _loadCalculs(projet.id!);
                                setState(() => _selectedTab = 1);
                              },
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildCalculsTab() {
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
                onPressed: () {
                  if (_projets.isNotEmpty) {
                    _loadCalculs(_projets.first.id!);
                  }
                },
                tooltip: 'Actualiser',
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  if (_projets.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Veuillez d\'abord créer un projet'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    setState(() => _selectedTab = 0);
                    return;
                  }
                  
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateCalculVitrageScreen(
                        projets: _projets,
                        regions: _regions,
                        categoriesTerrain: _categoriesTerrain,
                      ),
                    ),
                  );
                  if (result == true) {
                    if (_projets.isNotEmpty) {
                      _loadCalculs(_projets.first.id!);
                    }
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Nouveau calcul'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _calculs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calculate, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Aucun calcul',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (_projets.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Veuillez d\'abord créer un projet'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            setState(() => _selectedTab = 0);
                            return;
                          }
                          
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateCalculVitrageScreen(
                                projets: _projets,
                                regions: _regions,
                                categoriesTerrain: _categoriesTerrain,
                              ),
                            ),
                          );
                          if (result == true) {
                            if (_projets.isNotEmpty) {
                              _loadCalculs(_projets.first.id!);
                            }
                          }
                        },
                        child: const Text('Créer un calcul'),
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
                    itemCount: _calculs.length,
                    itemBuilder: (context, index) {
                      final calcul = _calculs[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.cyan.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.calculate, color: Colors.cyan),
                          ),
                          title: Text(
                            calcul.typeLabel,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Dimensions: ${calcul.largeur} x ${calcul.hauteur} mm'),
                              if (calcul.epaisseurRecommandee != null)
                                Text(
                                  'Épaisseur recommandée: ${calcul.epaisseurRecommandee!.toStringAsFixed(1)} mm',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              if (calcul.regionVentDetail != null)
                                Text('Région vent: ${calcul.regionVentDetail!.nom}'),
                              if (calcul.categorieTerrainDetail != null)
                                Text('Terrain: ${calcul.categorieTerrainDetail!.nom}'),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'recalculer',
                                child: Row(
                                  children: [
                                    Icon(Icons.refresh, size: 20),
                                    SizedBox(width: 8),
                                    Text('Recalculer'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'pdf',
                                child: Row(
                                  children: [
                                    Icon(Icons.picture_as_pdf, size: 20),
                                    SizedBox(width: 8),
                                    Text('Note de calcul PDF'),
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
                            ],
                            onSelected: (value) {
                              if (value == 'recalculer') {
                                _recalculer(calcul);
                              } else if (value == 'pdf') {
                                _genererPDF(calcul);
                              } else if (value == 'edit') {
                                _editCalcul(calcul);
                              }
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

  Widget _buildCarteRegionsTab() {
    // Créer des polygones pour chaque région
    final polygons = <Polygon>[];
    final markers = <Marker>[];
    
    for (var region in _regions) {
      if (region.latitudeMin != null && region.latitudeMax != null &&
          region.longitudeMin != null && region.longitudeMax != null) {
        // Créer un rectangle pour la région
        final points = [
          LatLng(region.latitudeMin!, region.longitudeMin!),
          LatLng(region.latitudeMax!, region.longitudeMin!),
          LatLng(region.latitudeMax!, region.longitudeMax!),
          LatLng(region.latitudeMin!, region.longitudeMax!),
        ];
        
        polygons.add(
          Polygon(
            points: points,
            color: Colors.blue.withOpacity(0.3),
            borderColor: Colors.blue,
            borderStrokeWidth: 2,
            isFilled: true,
          ),
        );
        
        // Marqueur au centre
        final centerLat = (region.latitudeMin! + region.latitudeMax!) / 2;
        final centerLon = (region.longitudeMin! + region.longitudeMax!) / 2;
        
        markers.add(
          Marker(
            point: LatLng(centerLat, centerLon),
            width: 100,
            height: 50,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${region.codeRegion}\n${region.nom}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
      ),
    );
  }
}

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
                onPressed: _loadRegions,
                tooltip: 'Actualiser',
              ),
              const Expanded(
                child: Text(
                  'Régions de vent et de neige en France',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Card(
            margin: const EdgeInsets.all(16),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(46.6034, 1.8883), // Centre de la France
                initialZoom: 6.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.miroiterie.app',
                ),
                PolygonLayer(polygons: polygons),
                MarkerLayer(markers: markers),
              ],
            ),
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
                'Légende',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._regions.take(5).map((region) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.3),
                          border: Border.all(color: Colors.blue),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${region.codeRegion} - ${region.nom}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Text(
                        'Vent: ${region.pressionVentReference.toStringAsFixed(0)} Pa',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesTerrainTab() {
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
                onPressed: _loadCategoriesTerrain,
                tooltip: 'Actualiser',
              ),
              const Expanded(
                child: Text(
                  'Catégories de terrain',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _categoriesTerrain.isEmpty
              ? const Center(
                  child: Text(
                    'Aucune catégorie de terrain disponible',
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
                    itemCount: _categoriesTerrain.length,
                    itemBuilder: (context, index) {
                      final categorie = _categoriesTerrain[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ExpansionTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              categorie.code,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ),
                          title: Text(
                            categorie.nom,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Coefficient: ${categorie.coefficientExposition.toStringAsFixed(2)}',
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    categorie.description,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  if (categorie.photoPath != null) ...[
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Photo:',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Image.network(
                                      categorie.photoPath!,
                                      height: 200,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Text(
                                          'Photo non disponible',
                                          style: TextStyle(color: Colors.grey),
                                        );
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _recalculer(CalculVitrage calcul) async {
    if (calcul.id == null) return;
    
    try {
      final updated = await _vitragesService.recalculer(calcul.id!);
      if (_projets.isNotEmpty) {
        _loadCalculs(_projets.first.id!);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updated.epaisseurRecommandee != null
                  ? 'Recalcul effectué. Épaisseur recommandée: ${updated.epaisseurRecommandee!.toStringAsFixed(1)} mm'
                  : 'Recalcul effectué',
            ),
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

  Future<void> _genererPDF(CalculVitrage calcul) async {
    if (calcul.id == null) return;
    
    try {
      // Récupérer les données complètes
      final noteCalculData = await _vitragesService.getNoteCalcul(calcul.id!);
      final calculComplet = CalculVitrage.fromJson(noteCalculData['calcul']);
      
      // Trouver le projet associé
      ProjetVitrage? projet;
      if (calculComplet.projetId.isNotEmpty) {
        try {
          final projets = await _vitragesService.getProjets();
          projet = projets.firstWhere((p) => p.id == calculComplet.projetId);
        } catch (e) {
          // Projet non trouvé, continuer sans
        }
      }
      
      // Générer le PDF
      final pdfDoc = NoteCalculVitragePdfGenerator.generateNoteCalcul(
        calcul: calculComplet,
        projet: projet,
        entetePersonnalisee: noteCalculData['entete'] as String?,
      );
      
      // Imprimer ou sauvegarder
      final success = await _printService.imprimerAvecSelection(pdfDoc);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Note de calcul générée' : 'Erreur lors de la génération'),
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

  Future<void> _editCalcul(CalculVitrage calcul) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateCalculVitrageScreen(
          calcul: calcul,
          projets: _projets,
          regions: _regions,
          categoriesTerrain: _categoriesTerrain,
        ),
      ),
    );
    if (result == true) {
      if (_projets.isNotEmpty) {
        _loadCalculs(_projets.first.id!);
      }
    }
  }
}
