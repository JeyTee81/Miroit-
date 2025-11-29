import 'package:flutter/material.dart';
import '../models/vitrages/calcul_vitrage_model.dart';
import '../models/vitrages/projet_vitrage_model.dart';
import '../models/vitrages/region_vent_neige_model.dart';
import '../models/vitrages/categorie_terrain_model.dart';
import '../services/vitrages_service.dart';

class CreateCalculVitrageScreen extends StatefulWidget {
  final CalculVitrage? calcul;
  final List<ProjetVitrage> projets;
  final List<RegionVentNeige> regions;
  final List<CategorieTerrain> categoriesTerrain;

  const CreateCalculVitrageScreen({
    super.key,
    this.calcul,
    required this.projets,
    required this.regions,
    required this.categoriesTerrain,
  });

  @override
  State<CreateCalculVitrageScreen> createState() => _CreateCalculVitrageScreenState();
}

class _CreateCalculVitrageScreenState extends State<CreateCalculVitrageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vitragesService = VitragesService();
  bool _isSaving = false;

  String? _selectedProjetId;
  final _largeurController = TextEditingController();
  final _hauteurController = TextEditingController();
  String _typeVitrage = 'monolithique';
  String? _selectedRegionVentId;
  String? _selectedRegionNeigeId;
  String? _selectedCategorieTerrainId;
  final _altitudeController = TextEditingController();
  final _pressionVentController = TextEditingController();
  final _chargeNeigeController = TextEditingController();
  final _coefficientSecuriteController = TextEditingController();
  final _normeController = TextEditingController();
  final _cahierCstbController = TextEditingController();
  final _enteteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _coefficientSecuriteController.text = '2.5';
    _normeController.text = 'NF DTU 39 P4';
    
    if (widget.calcul != null) {
      _selectedProjetId = widget.calcul!.projetId;
      _largeurController.text = widget.calcul!.largeur.toString();
      _hauteurController.text = widget.calcul!.hauteur.toString();
      _typeVitrage = widget.calcul!.typeVitrage;
      _selectedRegionVentId = widget.calcul!.regionVentId;
      _selectedRegionNeigeId = widget.calcul!.regionNeigeId;
      _selectedCategorieTerrainId = widget.calcul!.categorieTerrainId;
      _altitudeController.text = widget.calcul!.altitude.toString();
      _pressionVentController.text = widget.calcul!.pressionVent?.toString() ?? '';
      _chargeNeigeController.text = widget.calcul!.chargeNeige?.toString() ?? '';
      _coefficientSecuriteController.text = widget.calcul!.coefficientSecurite.toString();
      _normeController.text = widget.calcul!.normeUtilisee;
      _cahierCstbController.text = widget.calcul!.cahierCstb ?? '';
      _enteteController.text = widget.calcul!.entetePersonnalisee ?? '';
    } else if (widget.projets.isNotEmpty) {
      _selectedProjetId = widget.projets.first.id;
    }
  }

  @override
  void dispose() {
    _largeurController.dispose();
    _hauteurController.dispose();
    _altitudeController.dispose();
    _pressionVentController.dispose();
    _chargeNeigeController.dispose();
    _coefficientSecuriteController.dispose();
    _normeController.dispose();
    _cahierCstbController.dispose();
    _enteteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProjetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un projet'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final calcul = CalculVitrage(
        id: widget.calcul?.id,
        projetId: _selectedProjetId!,
        largeur: double.tryParse(_largeurController.text) ?? 0,
        hauteur: double.tryParse(_hauteurController.text) ?? 0,
        typeVitrage: _typeVitrage,
        regionVentId: _selectedRegionVentId,
        regionNeigeId: _selectedRegionNeigeId,
        categorieTerrainId: _selectedCategorieTerrainId,
        altitude: double.tryParse(_altitudeController.text) ?? 0,
        pressionVent: _pressionVentController.text.isNotEmpty
            ? double.tryParse(_pressionVentController.text)
            : null,
        chargeNeige: _chargeNeigeController.text.isNotEmpty
            ? double.tryParse(_chargeNeigeController.text)
            : null,
        coefficientSecurite: double.tryParse(_coefficientSecuriteController.text) ?? 2.5,
        normeUtilisee: _normeController.text.trim(),
        cahierCstb: _cahierCstbController.text.trim().isEmpty
            ? null
            : _cahierCstbController.text.trim(),
        entetePersonnalisee: _enteteController.text.trim().isEmpty
            ? null
            : _enteteController.text.trim(),
      );

      CalculVitrage savedCalcul;
      if (widget.calcul?.id != null) {
        savedCalcul = await _vitragesService.updateCalcul(widget.calcul!.id!, calcul);
      } else {
        savedCalcul = await _vitragesService.createCalcul(calcul);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.calcul != null
                  ? 'Calcul modifié avec succès'
                  : savedCalcul.epaisseurRecommandee != null
                      ? 'Calcul créé. Épaisseur recommandée: ${savedCalcul.epaisseurRecommandee!.toStringAsFixed(1)} mm'
                      : 'Calcul créé avec succès',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.calcul != null
            ? 'Modifier le calcul'
            : 'Nouveau calcul'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _save,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Projet
              DropdownButtonFormField<String>(
                value: _selectedProjetId,
                decoration: const InputDecoration(
                  labelText: 'Projet *',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Sélectionner un projet')),
                  ...widget.projets.map((p) => DropdownMenuItem(
                    value: p.id,
                    child: Text('${p.numeroProjet} - ${p.nom}'),
                  )),
                ],
                onChanged: (value) {
                  setState(() => _selectedProjetId = value);
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un projet';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Dimensions
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _largeurController,
                      decoration: const InputDecoration(
                        labelText: 'Largeur (mm) *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La largeur est requise';
                        }
                        if (double.tryParse(value) == null || double.parse(value) <= 0) {
                          return 'Veuillez entrer un nombre positif';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _hauteurController,
                      decoration: const InputDecoration(
                        labelText: 'Hauteur (mm) *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La hauteur est requise';
                        }
                        if (double.tryParse(value) == null || double.parse(value) <= 0) {
                          return 'Veuillez entrer un nombre positif';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Type de vitrage
              DropdownButtonFormField<String>(
                value: _typeVitrage,
                decoration: const InputDecoration(
                  labelText: 'Type de vitrage *',
                  border: OutlineInputBorder(),
                ),
                items: CalculVitrage.typeOptions.map((type) {
                  final c = CalculVitrage(
                    projetId: '',
                    largeur: 0,
                    hauteur: 0,
                    typeVitrage: type,
                  );
                  return DropdownMenuItem(
                    value: type,
                    child: Text(c.typeLabel),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _typeVitrage = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Région vent
              DropdownButtonFormField<String>(
                value: _selectedRegionVentId,
                decoration: const InputDecoration(
                  labelText: 'Région de vent',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Aucune région')),
                  ...widget.regions.map((r) => DropdownMenuItem(
                    value: r.id,
                    child: Text('${r.codeRegion} - ${r.nom}'),
                  )),
                ],
                onChanged: (value) {
                  setState(() => _selectedRegionVentId = value);
                  if (value != null) {
                    final region = widget.regions.firstWhere((r) => r.id == value);
                    _pressionVentController.text = region.pressionVentReference.toStringAsFixed(0);
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Région neige
              DropdownButtonFormField<String>(
                value: _selectedRegionNeigeId,
                decoration: const InputDecoration(
                  labelText: 'Région de neige',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Aucune région')),
                  ...widget.regions.map((r) => DropdownMenuItem(
                    value: r.id,
                    child: Text('${r.codeRegion} - ${r.nom}'),
                  )),
                ],
                onChanged: (value) {
                  setState(() => _selectedRegionNeigeId = value);
                  if (value != null) {
                    final region = widget.regions.firstWhere((r) => r.id == value);
                    _chargeNeigeController.text = region.chargeNeigeReference.toStringAsFixed(0);
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Catégorie de terrain
              DropdownButtonFormField<String>(
                value: _selectedCategorieTerrainId,
                decoration: const InputDecoration(
                  labelText: 'Catégorie de terrain',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Aucune catégorie')),
                  ...widget.categoriesTerrain.map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text('${c.code} - ${c.nom}'),
                  )),
                ],
                onChanged: (value) {
                  setState(() => _selectedCategorieTerrainId = value);
                },
              ),
              const SizedBox(height: 16),
              
              // Altitude
              TextFormField(
                controller: _altitudeController,
                decoration: const InputDecoration(
                  labelText: 'Altitude (mètres)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              
              // Pression vent
              TextFormField(
                controller: _pressionVentController,
                decoration: const InputDecoration(
                  labelText: 'Pression vent (Pa)',
                  border: OutlineInputBorder(),
                  helperText: 'Calculée automatiquement si région sélectionnée',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              
              // Charge neige
              TextFormField(
                controller: _chargeNeigeController,
                decoration: const InputDecoration(
                  labelText: 'Charge neige (Pa)',
                  border: OutlineInputBorder(),
                  helperText: 'Calculée automatiquement si région sélectionnée',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              
              // Coefficient de sécurité
              TextFormField(
                controller: _coefficientSecuriteController,
                decoration: const InputDecoration(
                  labelText: 'Coefficient de sécurité',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              
              // Norme utilisée
              TextFormField(
                controller: _normeController,
                decoration: const InputDecoration(
                  labelText: 'Norme utilisée',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              // Cahier CSTB
              TextFormField(
                controller: _cahierCstbController,
                decoration: const InputDecoration(
                  labelText: 'Cahier CSTB',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              // En-tête personnalisée
              TextFormField(
                controller: _enteteController,
                decoration: const InputDecoration(
                  labelText: 'En-tête personnalisée pour PDF',
                  border: OutlineInputBorder(),
                  helperText: 'Texte à afficher en en-tête de la note de calcul',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              
              // Bouton sauvegarder
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enregistrer et calculer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




