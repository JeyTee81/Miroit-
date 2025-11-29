import 'package:flutter/material.dart';
import '../../services/inertie_service.dart';
import '../../models/inertie/calcul_traverse_model.dart';
import '../../models/inertie/projet_model.dart';
import '../../models/inertie/famille_materiau_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/inertie/calcul_schema.dart';

class TraverseTab extends StatefulWidget {
  const TraverseTab({super.key});

  @override
  State<TraverseTab> createState() => _TraverseTabState();
}

class _TraverseTabState extends State<TraverseTab> {
  final InertieService _service = InertieService();
  final _formKey = GlobalKey<FormState>();
  
  List<ProjetInertie> _projets = [];
  List<FamilleMateriau> _familles = [];
  
  String? _projetId;
  String? _familleMateriauId;
  double? _moduleElasticite;
  final _porteeController = TextEditingController();
  final _trameVerticaleController = TextEditingController();
  final _poidsRemplissageController = TextEditingController();
  final _poidsTraverseController = TextEditingController();
  final _distanceBlocageController = TextEditingController(text: '40');
  String _typeFleche = 'portee_200';
  final _flecheController = TextEditingController();
  bool _choixAutomatiqueProfil = false;
  
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
    _trameVerticaleController.dispose();
    _poidsRemplissageController.dispose();
    _poidsTraverseController.dispose();
    _distanceBlocageController.dispose();
    _flecheController.dispose();
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

  void _updateFleche() {
    if (_typeFleche == 'portee_200' && _porteeController.text.isNotEmpty) {
      final portee = double.parse(_porteeController.text);
      _flecheController.text = (portee / 200).toStringAsFixed(2);
    } else if (_typeFleche == 'portee_300' && _porteeController.text.isNotEmpty) {
      final portee = double.parse(_porteeController.text);
      _flecheController.text = (portee / 300).toStringAsFixed(2);
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
      final calcul = CalculTraverse(
        projetId: _projetId!,
        portee: double.parse(_porteeController.text),
        trameVerticale: double.parse(_trameVerticaleController.text),
        poidsRemplissage: double.parse(_poidsRemplissageController.text),
        poidsTraverse: double.parse(_poidsTraverseController.text),
        distanceBlocage: double.parse(_distanceBlocageController.text),
        familleMateriauId: _familleMateriauId!,
        moduleElasticite: _moduleElasticite!,
        typeFleche: _typeFleche,
        flecheAdmissible: double.parse(_flecheController.text),
        choixAutomatiqueProfil: _choixAutomatiqueProfil,
      );

      final result = await _service.calculerTraverse(calcul);
      
      setState(() {
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
                'Calcul Traverse - Poids',
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
                      onChanged: (_) => _updateFleche(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _trameVerticaleController,
                      decoration: const InputDecoration(
                        labelText: 'Trame verticale (mm)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _poidsRemplissageController,
                      decoration: const InputDecoration(
                        labelText: 'Poids remplissage (kg/m²)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _poidsTraverseController,
                      decoration: const InputDecoration(
                        labelText: 'Poids traverse (kg/m)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _distanceBlocageController,
                      decoration: const InputDecoration(
                        labelText: 'Distance blocage (mm)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Type de flèche', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: CalculTraverse.typeFlecheOptions.map((type) {
                  String label;
                  switch (type) {
                    case 'portee_200':
                      label = 'Portée / 200';
                      break;
                    case 'portee_300':
                      label = 'Portée / 300';
                      break;
                    case 'personnalise':
                      label = 'Personnalisée';
                      break;
                    default:
                      label = type;
                  }
                  return Expanded(
                    child: RadioListTile<String>(
                      title: Text(label),
                      value: type,
                      groupValue: _typeFleche,
                      onChanged: (value) {
                        setState(() {
                          _typeFleche = value!;
                          _updateFleche();
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _flecheController,
                decoration: const InputDecoration(
                  labelText: 'Flèche admissible (mm)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
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
              if (_inertieRequise != null) ...[
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
                      const Text('Résultat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Inertie Iy requise: ${_inertieRequise!.toStringAsFixed(2)} cm⁴'),
                    ],
                  ),
                ),
              ],
              // Schéma de calcul
              if (_porteeController.text.isNotEmpty) ...[
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
                        typeCalcul: 'traverse',
                        parametres: {
                          'portee': double.tryParse(_porteeController.text) ?? 0,
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

