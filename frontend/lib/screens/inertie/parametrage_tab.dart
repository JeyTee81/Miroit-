import 'package:flutter/material.dart';
import '../../services/inertie_service.dart';
import '../../models/inertie/famille_materiau_model.dart';
import '../../models/inertie/profil_model.dart';
import '../../widgets/inertie/profil_visualization.dart';

class ParametrageTab extends StatefulWidget {
  const ParametrageTab({super.key});

  @override
  State<ParametrageTab> createState() => _ParametrageTabState();
}

class _ParametrageTabState extends State<ParametrageTab> {
  final InertieService _service = InertieService();
  List<FamilleMateriau> _familles = [];
  List<Profil> _profils = [];
  FamilleMateriau? _familleSelectionnee;
  Profil? _profilSelectionne;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final familles = await _service.getFamillesMateriaux();
      setState(() {
        _familles = familles;
        _familleSelectionnee = familles.isNotEmpty ? familles.first : null;
      });
      if (_familleSelectionnee != null && _familleSelectionnee!.id != null) {
        await _loadProfils(_familleSelectionnee!.id!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadProfils(String familleId) async {
    try {
      final profils = await _service.getProfils(familleMateriauId: familleId);
      setState(() => _profils = profils);
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Row(
      children: [
        // Panel gauche - Familles de matériaux
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Familles de matériaux',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _showAddFamilleDialog(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _familles.length,
                    itemBuilder: (context, index) {
                      final famille = _familles[index];
                      final isSelected = _familleSelectionnee?.id == famille.id;
                      return ListTile(
                        selected: isSelected,
                        title: Text(famille.nom),
                        subtitle: Text('Module: ${famille.moduleElasticite} daN/mm²'),
                        onTap: () {
                          setState(() => _familleSelectionnee = famille);
                          _loadProfils(famille.id!);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        // Panel droit - Profils
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _familleSelectionnee != null
                            ? 'Profils - ${_familleSelectionnee!.nom}'
                            : 'Sélectionnez une famille',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (_familleSelectionnee != null)
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => _showAddProfilDialog(),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: _familleSelectionnee == null
                      ? const Center(child: Text('Sélectionnez une famille de matériau'))
                      : _buildProfilsTable(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfilsTable() {
    return Row(
      children: [
        // Table des profils
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Code profil')),
                DataColumn(label: Text('Désignation')),
                DataColumn(label: Text('Ixx (cm⁴)')),
                DataColumn(label: Text('Iyy (cm⁴)')),
              ],
              rows: _profils.map((profil) {
                final isSelected = _profilSelectionne?.id == profil.id;
                return DataRow(
                  selected: isSelected,
                  onSelectChanged: (selected) {
                    if (selected == true) {
                      setState(() {
                        _profilSelectionne = profil;
                      });
                    }
                  },
                  cells: [
                    DataCell(Text(profil.codeProfil)),
                    DataCell(Text(profil.designation)),
                    DataCell(Text(profil.inertieIxx.toStringAsFixed(2))),
                    DataCell(Text(profil.inertieIyy.toStringAsFixed(2))),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        // Visualisation du profil sélectionné
        if (_profilSelectionne != null)
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Visualisation',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ProfilVisualization(
                    profil: _profilSelectionne,
                    width: 250,
                    height: 200,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _showAddFamilleDialog() {
    final nomController = TextEditingController();
    final moduleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle famille de matériau'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomController,
              decoration: const InputDecoration(labelText: 'Nom (ex: ACIER)'),
            ),
            TextField(
              controller: moduleController,
              decoration: const InputDecoration(labelText: 'Module d\'élasticité (daN/mm²)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _service.createFamilleMateriau(FamilleMateriau(
                  nom: nomController.text,
                  moduleElasticite: double.parse(moduleController.text),
                ));
                Navigator.pop(context);
                _loadData();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _showAddProfilDialog() {
    if (_familleSelectionnee == null) return;

    final codeController = TextEditingController();
    final designationController = TextEditingController();
    final ixxController = TextEditingController();
    final iyyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouveau profil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Code profil (ex: 100x50x3.2)'),
              ),
              TextField(
                controller: designationController,
                decoration: const InputDecoration(labelText: 'Désignation'),
              ),
              TextField(
                controller: ixxController,
                decoration: const InputDecoration(labelText: 'Inertie Ixx (cm⁴)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: iyyController,
                decoration: const InputDecoration(labelText: 'Inertie Iyy (cm⁴)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _service.createProfil(Profil(
                  familleMateriauId: _familleSelectionnee!.id!,
                  codeProfil: codeController.text,
                  designation: designationController.text,
                  inertieIxx: double.parse(ixxController.text),
                  inertieIyy: double.parse(iyyController.text),
                ));
                Navigator.pop(context);
                _loadProfils(_familleSelectionnee!.id!);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }
}

