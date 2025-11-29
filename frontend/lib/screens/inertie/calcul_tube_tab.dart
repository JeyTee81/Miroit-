import 'package:flutter/material.dart';
import '../../services/inertie_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/inertie/profil_visualization.dart';
import '../../widgets/inertie/drawing_tool.dart';

class CalculTubeTab extends StatefulWidget {
  const CalculTubeTab({super.key});

  @override
  State<CalculTubeTab> createState() => _CalculTubeTabState();
}

class _CalculTubeTabState extends State<CalculTubeTab> {
  final InertieService _service = InertieService();
  final _formKey = GlobalKey<FormState>();
  final _hauteurController = TextEditingController();
  final _largeurController = TextEditingController();
  final _epaisseurController = TextEditingController();
  
  double? _ixx;
  double? _iyy;
  bool _isCalculating = false;

  @override
  void dispose() {
    _hauteurController.dispose();
    _largeurController.dispose();
    _epaisseurController.dispose();
    super.dispose();
  }

  Future<void> _calculer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCalculating = true;
      _ixx = null;
      _iyy = null;
    });

    try {
      final result = await _service.calculerInertieTube(
        hauteurCm: double.parse(_hauteurController.text),
        largeurCm: double.parse(_largeurController.text),
        epaisseurCm: double.parse(_epaisseurController.text),
      );

      setState(() {
        _ixx = result['ixx'];
        _iyy = result['iyy'];
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

  void _nouveauCalcul() {
    _hauteurController.clear();
    _largeurController.clear();
    _epaisseurController.clear();
    setState(() {
      _ixx = null;
      _iyy = null;
    });
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
        child: Row(
          children: [
            // Panel gauche - Formulaire
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Calcul d\'inertie - Tube rectangulaire creux',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _hauteurController,
                    decoration: const InputDecoration(
                      labelText: 'Hauteur (cm)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez saisir la hauteur';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _largeurController,
                    decoration: const InputDecoration(
                      labelText: 'Largeur (cm)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez saisir la largeur';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _epaisseurController,
                    decoration: const InputDecoration(
                      labelText: 'Épaisseur (cm)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez saisir l\'épaisseur';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
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
                      const SizedBox(width: 16),
                      OutlinedButton(
                        onPressed: _nouveauCalcul,
                        child: const Text('Nouveau Calcul'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Panel droit - Résultats et Visualisation
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Visualisation du tube
                    if (_hauteurController.text.isNotEmpty &&
                        _largeurController.text.isNotEmpty &&
                        _epaisseurController.text.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Visualisation du profil',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            ProfilVisualization(
                              hauteurCm: double.tryParse(_hauteurController.text),
                              largeurCm: double.tryParse(_largeurController.text),
                              epaisseurCm: double.tryParse(_epaisseurController.text),
                              width: 300,
                              height: 250,
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Résultats
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Résultats',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 24),
                          if (_ixx != null && _iyy != null) ...[
                            _buildResultCard('Inertie Ixx', '${_ixx!.toStringAsFixed(2)} cm⁴'),
                            const SizedBox(height: 16),
                            _buildResultCard('Inertie Iyy', '${_iyy!.toStringAsFixed(2)} cm⁴'),
                          ] else
                            const Center(
                              child: Text(
                                'Remplissez le formulaire et cliquez sur "Calculer"',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Outil de dessin
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Outil de dessin',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          const DrawingTool(
                            width: 400,
                            height: 300,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryDark),
          ),
        ],
      ),
    );
  }
}

