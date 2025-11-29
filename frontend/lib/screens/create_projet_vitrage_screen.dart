import 'package:flutter/material.dart';
import '../models/vitrages/projet_vitrage_model.dart';
import '../services/vitrages_service.dart';
import '../services/chantier_service.dart';
import '../models/chantier_model.dart';

class CreateProjetVitrageScreen extends StatefulWidget {
  final ProjetVitrage? projet;

  const CreateProjetVitrageScreen({super.key, this.projet});

  @override
  State<CreateProjetVitrageScreen> createState() => _CreateProjetVitrageScreenState();
}

class _CreateProjetVitrageScreenState extends State<CreateProjetVitrageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vitragesService = VitragesService();
  final _chantierService = ChantierService();
  bool _isSaving = false;
  bool _isLoading = false;

  final _numeroProjetController = TextEditingController();
  final _nomController = TextEditingController();
  String? _selectedChantierId;
  
  List<Chantier> _chantiers = [];

  @override
  void initState() {
    super.initState();
    _loadChantiers();
    
    if (widget.projet != null) {
      _numeroProjetController.text = widget.projet!.numeroProjet;
      _nomController.text = widget.projet!.nom;
      _selectedChantierId = widget.projet!.chantierId;
    }
  }

  @override
  void dispose() {
    _numeroProjetController.dispose();
    _nomController.dispose();
    super.dispose();
  }

  Future<void> _loadChantiers() async {
    setState(() => _isLoading = true);
    try {
      final chantiers = await _chantierService.getChantiers();
      setState(() => _chantiers = chantiers);
    } catch (e) {
      // Ignorer les erreurs
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final projet = ProjetVitrage(
        id: widget.projet?.id,
        numeroProjet: _numeroProjetController.text.trim(),
        chantierId: _selectedChantierId,
        nom: _nomController.text.trim(),
        dateCreation: widget.projet?.dateCreation ?? DateTime.now(),
      );

      if (widget.projet?.id != null) {
        await _vitragesService.updateProjet(widget.projet!.id!, projet);
      } else {
        await _vitragesService.createProjet(projet);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.projet != null
                ? 'Projet modifié avec succès'
                : 'Projet créé avec succès'),
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
        title: Text(widget.projet != null
            ? 'Modifier le projet'
            : 'Nouveau projet'),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Numéro projet
                    TextFormField(
                      controller: _numeroProjetController,
                      decoration: const InputDecoration(
                        labelText: 'Numéro de projet',
                        border: OutlineInputBorder(),
                        helperText: 'Laissé vide pour génération automatique',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Nom
                    TextFormField(
                      controller: _nomController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du projet *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le nom est requis';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Chantier (optionnel)
                    DropdownButtonFormField<String>(
                      value: _selectedChantierId,
                      decoration: const InputDecoration(
                        labelText: 'Chantier (optionnel)',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Aucun chantier')),
                        ..._chantiers.map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.nom),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedChantierId = value);
                      },
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
                          : const Text('Enregistrer'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}




