import 'package:flutter/material.dart';
import '../../models/imprimante_model.dart';
import '../../services/imprimante_service.dart';

class CreateImprimanteScreen extends StatefulWidget {
  final Imprimante? imprimante;
  final Imprimante? imprimantePreRemplie;

  const CreateImprimanteScreen({super.key, this.imprimante, this.imprimantePreRemplie});

  @override
  State<CreateImprimanteScreen> createState() => _CreateImprimanteScreenState();
}

class _CreateImprimanteScreenState extends State<CreateImprimanteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imprimanteService = ImprimanteService();
  bool _isSaving = false;

  final _nomController = TextEditingController();
  String _typeImprimante = 'locale';
  final _nomSystemeController = TextEditingController();
  final _adresseIpController = TextEditingController();
  final _portController = TextEditingController(text: '9100');
  String _protocole = 'raw';
  final _nomReseauController = TextEditingController();
  String _formatPapier = 'A4';
  String _orientation = 'portrait';
  bool _actif = true;
  bool _imprimanteParDefaut = false;
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.imprimante != null) {
      _nomController.text = widget.imprimante!.nom;
      _typeImprimante = widget.imprimante!.typeImprimante;
      _nomSystemeController.text = widget.imprimante!.nomSysteme ?? '';
      _adresseIpController.text = widget.imprimante!.adresseIp ?? '';
      _portController.text = widget.imprimante!.port.toString();
      _protocole = widget.imprimante!.protocole;
      _nomReseauController.text = widget.imprimante!.nomReseau ?? '';
      _formatPapier = widget.imprimante!.formatPapier;
      _orientation = widget.imprimante!.orientation;
      _actif = widget.imprimante!.actif;
      _imprimanteParDefaut = widget.imprimante!.imprimanteParDefaut;
      _descriptionController.text = widget.imprimante!.description ?? '';
    } else if (widget.imprimantePreRemplie != null) {
      // Pré-remplir avec les données détectées
      _nomController.text = widget.imprimantePreRemplie!.nom;
      _typeImprimante = widget.imprimantePreRemplie!.typeImprimante;
      _nomSystemeController.text = widget.imprimantePreRemplie!.nomSysteme ?? '';
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _nomSystemeController.dispose();
    _adresseIpController.dispose();
    _portController.dispose();
    _nomReseauController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveImprimante() async {
    if (!_formKey.currentState!.validate()) return;

    // Validation spécifique selon le type
    if (_typeImprimante == 'locale' && _nomSystemeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le nom système est requis pour une imprimante locale'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_typeImprimante == 'reseau' && _adresseIpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('L\'adresse IP est requise pour une imprimante réseau'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final imprimante = Imprimante(
        id: widget.imprimante?.id,
        nom: _nomController.text,
        typeImprimante: _typeImprimante,
        nomSysteme: _nomSystemeController.text.isEmpty ? null : _nomSystemeController.text,
        adresseIp: _adresseIpController.text.isEmpty ? null : _adresseIpController.text,
        port: int.tryParse(_portController.text) ?? 9100,
        protocole: _protocole,
        nomReseau: _nomReseauController.text.isEmpty ? null : _nomReseauController.text,
        formatPapier: _formatPapier,
        orientation: _orientation,
        actif: _actif,
        imprimanteParDefaut: _imprimanteParDefaut,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      );

      if (widget.imprimante != null) {
        await _imprimanteService.updateImprimante(imprimante);
      } else {
        await _imprimanteService.createImprimante(imprimante);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.imprimante != null ? 'Imprimante modifiée' : 'Imprimante créée'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.imprimante != null ? 'Modifier l\'imprimante' : 'Nouvelle imprimante'),
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveImprimante,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Informations générales
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Informations générales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nomController,
                        decoration: const InputDecoration(
                          labelText: 'Nom *',
                          border: OutlineInputBorder(),
                          helperText: 'Nom d\'affichage de l\'imprimante',
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _typeImprimante,
                        decoration: const InputDecoration(
                          labelText: 'Type d\'imprimante *',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'locale', child: Text('Locale')),
                          DropdownMenuItem(value: 'reseau', child: Text('Réseau')),
                        ],
                        onChanged: (value) => setState(() => _typeImprimante = value ?? 'locale'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Paramètres selon le type
              if (_typeImprimante == 'locale')
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Paramètres imprimante locale', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nomSystemeController,
                          decoration: const InputDecoration(
                            labelText: 'Nom système *',
                            border: OutlineInputBorder(),
                            helperText: 'Nom de l\'imprimante dans le système (ex: HP LaserJet Pro)',
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Paramètres imprimante réseau', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _adresseIpController,
                          decoration: const InputDecoration(
                            labelText: 'Adresse IP *',
                            border: OutlineInputBorder(),
                            helperText: 'Adresse IP de l\'imprimante (ex: 192.168.1.100)',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _portController,
                                decoration: const InputDecoration(
                                  labelText: 'Port *',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<String>(
                                value: _protocole,
                                decoration: const InputDecoration(
                                  labelText: 'Protocole *',
                                  border: OutlineInputBorder(),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'raw', child: Text('RAW (Port 9100)')),
                                  DropdownMenuItem(value: 'lpr', child: Text('LPR/LPD (Port 515)')),
                                  DropdownMenuItem(value: 'ipp', child: Text('IPP (Port 631)')),
                                  DropdownMenuItem(value: 'http', child: Text('HTTP')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _protocole = value ?? 'raw';
                                    // Ajuster le port selon le protocole
                                    if (value == 'raw') {
                                      _portController.text = '9100';
                                    } else if (value == 'lpr') {
                                      _portController.text = '515';
                                    } else if (value == 'ipp') {
                                      _portController.text = '631';
                                    } else if (value == 'http') {
                                      _portController.text = '80';
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nomReseauController,
                          decoration: const InputDecoration(
                            labelText: 'Nom réseau',
                            border: OutlineInputBorder(),
                            helperText: 'Nom réseau de l\'imprimante (optionnel)',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              // Paramètres d'impression
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Paramètres d\'impression', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _formatPapier,
                              decoration: const InputDecoration(
                                labelText: 'Format papier',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'A4', child: Text('A4')),
                                DropdownMenuItem(value: 'A3', child: Text('A3')),
                                DropdownMenuItem(value: 'Letter', child: Text('Letter')),
                                DropdownMenuItem(value: 'Legal', child: Text('Legal')),
                              ],
                              onChanged: (value) => setState(() => _formatPapier = value ?? 'A4'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _orientation,
                              decoration: const InputDecoration(
                                labelText: 'Orientation',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'portrait', child: Text('Portrait')),
                                DropdownMenuItem(value: 'paysage', child: Text('Paysage')),
                              ],
                              onChanged: (value) => setState(() => _orientation = value ?? 'portrait'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Options
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Imprimante active'),
                        subtitle: const Text('L\'imprimante est disponible pour l\'impression'),
                        value: _actif,
                        onChanged: (value) => setState(() => _actif = value),
                      ),
                      SwitchListTile(
                        title: const Text('Imprimante par défaut'),
                        subtitle: const Text('Utilisée automatiquement si aucune imprimante n\'est sélectionnée'),
                        value: _imprimanteParDefaut,
                        onChanged: (value) => setState(() => _imprimanteParDefaut = value),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

