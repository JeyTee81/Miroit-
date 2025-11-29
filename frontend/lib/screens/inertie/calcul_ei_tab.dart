import 'package:flutter/material.dart';
import '../../services/inertie_service.dart';
import '../../models/inertie/calcul_ei_model.dart';
import '../../models/inertie/projet_model.dart';
import '../../models/inertie/famille_materiau_model.dart';
import '../../widgets/inertie/calcul_schema.dart';

class CalculEITab extends StatefulWidget {
  const CalculEITab({super.key});

  @override
  State<CalculEITab> createState() => _CalculEITabState();
}

class _CalculEITabState extends State<CalculEITab> {
  final InertieService _service = InertieService();
  final _formKey = GlobalKey<FormState>();
  
  List<ProjetInertie> _projets = [];
  List<FamilleMateriau> _familles = [];
  ProjetInertie? _projetSelectionne;
  FamilleMateriau? _familleSelectionnee;
  String _typeCharge = 'type1';
  String _categorieTerrain = '0';
  
  // Contrôleurs pour les dimensions selon le type
  final _s1Controller = TextEditingController();
  final _s2Controller = TextEditingController();
  final _s3Controller = TextEditingController();
  final _qController = TextEditingController();
  final _iReelController = TextEditingController();
  
  bool _isLoading = false;
  bool _isCalculating = false;
  Map<String, dynamic>? _resultats;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _s1Controller.dispose();
    _s2Controller.dispose();
    _s3Controller.dispose();
    _qController.dispose();
    _iReelController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final projets = await _service.getProjets();
      final familles = await _service.getFamillesMateriaux();
      setState(() {
        _projets = projets;
        _familles = familles;
        _projetSelectionne = projets.isNotEmpty ? projets.first : null;
        _familleSelectionnee = familles.isNotEmpty ? familles.first : null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _calculer() async {
    if (!_formKey.currentState!.validate()) return;
    if (_projetSelectionne == null || _familleSelectionnee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un projet et une famille de matériau'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isCalculating = true);

    try {
      // Construire les dimensions selon le type de charge
      Map<String, dynamic> dimensions = {};
      if (_s1Controller.text.isNotEmpty) {
        dimensions['S1'] = double.parse(_s1Controller.text);
      }
      if (_s2Controller.text.isNotEmpty) {
        dimensions['S2'] = double.parse(_s2Controller.text);
      }
      if (_s3Controller.text.isNotEmpty) {
        dimensions['S3'] = double.parse(_s3Controller.text);
      }
      if (_qController.text.isNotEmpty) {
        dimensions['Q'] = double.parse(_qController.text);
      }
      
      // Ajouter i_reel dans les dimensions pour l'envoyer au backend
      if (_iReelController.text.isNotEmpty) {
        final iReel = double.tryParse(_iReelController.text);
        if (iReel != null) {
          dimensions['i_reel'] = iReel;
        }
      }

      final calcul = CalculEI(
        projetId: _projetSelectionne!.id!,
        typeCharge: _typeCharge,
        familleMateriauId: _familleSelectionnee!.id!,
        moduleElasticite: _familleSelectionnee!.moduleElasticite,
        dimensions: dimensions,
        categorieTerrain: _categorieTerrain,
      );

      final resultats = await _service.calculerEI(calcul);
      setState(() => _resultats = resultats);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Calcul effectué avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du calcul: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCalculating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sélection projet et famille
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<ProjetInertie>(
                    value: _projetSelectionne,
                    decoration: const InputDecoration(
                      labelText: 'Projet',
                      border: OutlineInputBorder(),
                    ),
                    items: _projets.map((projet) => DropdownMenuItem(
                      value: projet,
                      child: Text('${projet.numeroProjet} - ${projet.nom}'),
                    )).toList(),
                    onChanged: (value) => setState(() => _projetSelectionne = value),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<FamilleMateriau>(
                    value: _familleSelectionnee,
                    decoration: const InputDecoration(
                      labelText: 'Famille de matériau',
                      border: OutlineInputBorder(),
                    ),
                    items: _familles.map((famille) => DropdownMenuItem(
                      value: famille,
                      child: Text(famille.nom),
                    )).toList(),
                    onChanged: (value) => setState(() => _familleSelectionnee = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Type de charge
            DropdownButtonFormField<String>(
              value: _typeCharge,
              decoration: const InputDecoration(
                labelText: 'Type de charge',
                border: OutlineInputBorder(),
              ),
              items: CalculEI.typeChargeOptions.map((type) {
                String label;
                switch (type) {
                  case 'type1':
                    label = 'Type 1';
                    break;
                  case 'type2':
                    label = 'Type 2';
                    break;
                  case 'type3':
                    label = 'Type 3';
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
            const SizedBox(height: 16),
            
            // Catégorie terrain
            DropdownButtonFormField<String>(
              value: _categorieTerrain,
              decoration: const InputDecoration(
                labelText: 'Catégorie de terrain',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: '0', child: Text('Catégorie 0')),
                DropdownMenuItem(value: 'I', child: Text('Catégorie I')),
                DropdownMenuItem(value: 'II', child: Text('Catégorie II')),
                DropdownMenuItem(value: 'III', child: Text('Catégorie III')),
                DropdownMenuItem(value: 'IV', child: Text('Catégorie IV')),
              ],
              onChanged: (value) => setState(() => _categorieTerrain = value!),
            ),
            const SizedBox(height: 24),
            
            // Dimensions
            const Text('Dimensions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _s1Controller,
                    decoration: const InputDecoration(
                      labelText: 'S1 (mm)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _s2Controller,
                    decoration: const InputDecoration(
                      labelText: 'S2 (mm)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _s3Controller,
                    decoration: const InputDecoration(
                      labelText: 'S3 (mm)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _qController,
                    decoration: const InputDecoration(
                      labelText: 'Q (daN/m²)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _iReelController,
                    decoration: const InputDecoration(
                      labelText: 'I réel (cm⁴)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Bouton calculer
            ElevatedButton.icon(
              onPressed: _isCalculating ? null : _calculer,
              icon: _isCalculating 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.calculate),
              label: Text(_isCalculating ? 'Calcul en cours...' : 'Calculer'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            // Schéma et Résultats
            if (_resultats != null) ...[
              const SizedBox(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Schéma
                  Expanded(
                    child: Container(
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
                            typeCalcul: 'ei',
                            parametres: {
                              'type_charge': _typeCharge,
                            },
                            resultats: _resultats,
                            width: 400,
                            height: 300,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Résultats
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Résultats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _buildResultCard('E1', _resultats!['e1']),
                        _buildResultCard('E2', _resultats!['e2']),
                        _buildResultCard('E3', _resultats!['e3']),
                        _buildResultCard('Charge exercée', _resultats!['charge_exercee']),
                        _buildResultCard('Charge admissible', _resultats!['charge_admissible']),
                        _buildResultCard('I mini (cm⁴)', _resultats!['i_mini']),
                        _buildResultCard('I besoin (cm⁴)', _resultats!['i_besoin']),
                        _buildResultCard('Pression de calcul (daN/m²)', _resultats!['pression_calcul']),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(String label, dynamic value) {
    if (value == null) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(label),
        trailing: Text(
          value is num ? value.toStringAsFixed(2) : value.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
