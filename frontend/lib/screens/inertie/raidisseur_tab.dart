import 'package:flutter/material.dart';
import '../../services/inertie_service.dart';
import '../../models/inertie/calcul_raidisseur_model.dart';
import '../../models/inertie/projet_model.dart';
import '../../models/inertie/famille_materiau_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/inertie/calcul_schema.dart';

class RaidisseurTab extends StatefulWidget {
  const RaidisseurTab({super.key});

  @override
  State<RaidisseurTab> createState() => _RaidisseurTabState();
}

class _RaidisseurTabState extends State<RaidisseurTab> {
  final InertieService _service = InertieService();
  final _formKey = GlobalKey<FormState>();
  
  List<ProjetInertie> _projets = [];
  List<FamilleMateriau> _familles = [];
  
  String? _projetId;
  String _typeCharge = 'rectangulaire_2_appuis';
  String? _familleMateriauId;
  double? _moduleElasticite;
  final _porteeController = TextEditingController();
  final _trameController = TextEditingController();
  final _flecheController = TextEditingController(text: '15.0');
  String _regionVent = '01';
  String _categorieTerrain = '0';
  final _hauteurSolController = TextEditingController();
  final _penteToitureController = TextEditingController();
  final _penteObstaclesController = TextEditingController();
  bool _constructionsVoisines = false;
  String? _regionNeige;
  bool _calculAvecRenfort = false;
  bool _choixAutomatiqueProfil = false;
  
  double? _pressionVent;
  double? _inertieRequise;
  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _porteeController.dispose();
    _trameController.dispose();
    _flecheController.dispose();
    _hauteurSolController.dispose();
    _penteToitureController.dispose();
    _penteObstaclesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final projets = await _service.getProjets();
      final familles = await _service.getFamillesMateriaux();
      setState(() {
        _projets = projets;
        _familles = familles;
        if (familles.isNotEmpty) {
          _familleMateriauId = familles.first.id;
          _moduleElasticite = familles.first.moduleElasticite;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _calculer() async {
    if (!_formKey.currentState!.validate() || _projetId == null || _familleMateriauId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isCalculating = true);

    try {
      final calcul = CalculRaidisseur(
        projetId: _projetId!,
        typeCharge: _typeCharge,
        familleMateriauId: _familleMateriauId!,
        moduleElasticite: _moduleElasticite!,
        portee: double.parse(_porteeController.text),
        trame: double.parse(_trameController.text),
        flecheAdmissible: double.parse(_flecheController.text),
        regionVent: _regionVent,
        categorieTerrain: _categorieTerrain,
        hauteurSol: _hauteurSolController.text.isNotEmpty ? double.parse(_hauteurSolController.text) : null,
        penteToiture: _penteToitureController.text.isNotEmpty ? double.parse(_penteToitureController.text) : null,
        penteObstacles: _penteObstaclesController.text.isNotEmpty ? double.parse(_penteObstaclesController.text) : null,
        constructionsVoisines: _constructionsVoisines,
        regionNeige: _regionNeige,
        calculAvecRenfort: _calculAvecRenfort,
        choixAutomatiqueProfil: _choixAutomatiqueProfil,
      );

      final result = await _service.calculerRaidisseur(calcul);
      
      setState(() {
        _pressionVent = result['pression_vent']?.toDouble();
        _inertieRequise = result['inertie_requise']?.toDouble();
        _isCalculating = false;
      });
    } catch (e) {
      setState(() => _isCalculating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Calcul Raidisseur - Vent et/ou Neige',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _projetId,
                      decoration: const InputDecoration(
                        labelText: 'Projet',
                        border: OutlineInputBorder(),
                      ),
                      items: _projets.map((p) => DropdownMenuItem(
                        value: p.id,
                        child: Text(p.nom),
                      )).toList(),
                      onChanged: (value) => setState(() => _projetId = value),
                      validator: (value) => value == null ? 'Sélectionnez un projet' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _typeCharge,
                      decoration: const InputDecoration(
                        labelText: 'Type de charge',
                        border: OutlineInputBorder(),
                      ),
                      items: CalculRaidisseur.typeChargeOptions.map((type) {
                        String label;
                        switch (type) {
                          case 'rectangulaire_2_appuis':
                            label = 'Rectangulaire sur 2 appuis';
                            break;
                          case 'encastrement_appui':
                            label = '1 encastrement et 1 appui';
                            break;
                          case 'rectangulaire_3_appuis':
                            label = 'Rectangulaire sur 3 appuis';
                            break;
                          case 'trapezoidale':
                            label = 'Trapézoïdale';
                            break;
                          default:
                            label = type;
                        }
                        return DropdownMenuItem(
                          value: type,
                          child: Text(label),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _typeCharge = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _familleMateriauId,
                      decoration: const InputDecoration(
                        labelText: 'Matériau',
                        border: OutlineInputBorder(),
                      ),
                      items: _familles.map((f) => DropdownMenuItem(
                        value: f.id,
                        child: Text(f.nom),
                      )).toList(),
                      onChanged: (value) {
                        setState(() {
                          _familleMateriauId = value;
                          _moduleElasticite = _familles.firstWhere((f) => f.id == value).moduleElasticite;
                        });
                      },
                      validator: (value) => value == null ? 'Sélectionnez un matériau' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: _moduleElasticite?.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Module d\'élasticité (daN/mm²)',
                        border: OutlineInputBorder(),
                        enabled: false,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _porteeController,
                      decoration: const InputDecoration(
                        labelText: 'Portée (mm)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _trameController,
                      decoration: const InputDecoration(
                        labelText: 'Trame (mm)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _flecheController,
                      decoration: const InputDecoration(
                        labelText: 'Flèche admissible (mm)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Régions Vent', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: ['01', '02', '03', '04'].map((region) {
                  return Expanded(
                    child: RadioListTile<String>(
                      title: Text(region),
                      value: region,
                      groupValue: _regionVent,
                      onChanged: (value) => setState(() => _regionVent = value!),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Catégorie de terrain', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: ['0', 'I', 'II', 'III', 'IV'].map((cat) {
                  return Expanded(
                    child: RadioListTile<String>(
                      title: Text(cat),
                      value: cat,
                      groupValue: _categorieTerrain,
                      onChanged: (value) => setState(() => _categorieTerrain = value!),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _hauteurSolController,
                      decoration: const InputDecoration(
                        labelText: 'Hauteur au dessus du sol (m)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _penteToitureController,
                      decoration: const InputDecoration(
                        labelText: 'Pente de toiture (degrés)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _penteObstaclesController,
                      decoration: const InputDecoration(
                        labelText: 'Pente d\'obstacles (m)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Constructions avoisinantes > 20m'),
                value: _constructionsVoisines,
                onChanged: (value) => setState(() => _constructionsVoisines = value ?? false),
              ),
              CheckboxListTile(
                title: const Text('Calcul avec renfort'),
                value: _calculAvecRenfort,
                onChanged: (value) => setState(() => _calculAvecRenfort = value ?? false),
              ),
              CheckboxListTile(
                title: const Text('Choix automatique du profil adapté'),
                value: _choixAutomatiqueProfil,
                onChanged: (value) => setState(() => _choixAutomatiqueProfil = value ?? false),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isCalculating ? null : _calculer,
                child: _isCalculating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Calculer'),
              ),
              if (_pressionVent != null || _inertieRequise != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Résultats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      if (_pressionVent != null) ...[
                        const SizedBox(height: 8),
                        Text('Pression au vent: ${_pressionVent!.toStringAsFixed(2)} Pa'),
                      ],
                      if (_inertieRequise != null) ...[
                        const SizedBox(height: 8),
                        Text('Inertie Ixx requise: ${_inertieRequise!.toStringAsFixed(2)} cm⁴'),
                      ],
                    ],
                  ),
                ),
              ],
              // Schéma de calcul
              if (_porteeController.text.isNotEmpty && _trameController.text.isNotEmpty) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Schéma de calcul',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      CalculSchema(
                        typeCalcul: 'raidisseur',
                        parametres: {
                          'portee': double.tryParse(_porteeController.text) ?? 0,
                          'trame': double.tryParse(_trameController.text) ?? 0,
                          'type_charge': _typeCharge,
                        },
                        resultats: {
                          'fleche': double.tryParse(_flecheController.text),
                        },
                        width: 400,
                        height: 250,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

