import 'package:flutter/material.dart';
import '../models/menuiserie/projet_model.dart';
import '../models/devis_model.dart';
import '../services/menuiserie_service.dart';
import '../services/devis_service.dart';

class CreateProjetScreen extends StatefulWidget {
  final Projet? projet;

  const CreateProjetScreen({super.key, this.projet});

  @override
  State<CreateProjetScreen> createState() => _CreateProjetScreenState();
}

class _CreateProjetScreenState extends State<CreateProjetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _menuiserieService = MenuiserieService();
  final _devisService = DevisService();
  bool _isLoading = false;
  bool _isSaving = false;

  List<Devis> _devis = [];
  Devis? _selectedDevis;
  final _nomController = TextEditingController();
  String _statut = 'brouillon';
  String? _chantierId;

  @override
  void initState() {
    super.initState();
    _loadDevis();
    if (widget.projet != null) {
      _nomController.text = widget.projet!.nom;
      _statut = widget.projet!.statut;
      _chantierId = widget.projet!.chantierId;
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    super.dispose();
  }

  Future<void> _loadDevis() async {
    try {
      final devis = await _devisService.getDevis();
      setState(() {
        _devis = devis;
        if (widget.projet?.devisId != null && devis.isNotEmpty) {
          try {
            _selectedDevis = devis.firstWhere(
              (d) => d.id == widget.projet!.devisId,
            );
            _chantierId = _selectedDevis?.chantierId;
          } catch (e) {
            if (devis.isNotEmpty) {
              _selectedDevis = devis.first;
            }
          }
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDevis == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un devis'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final projet = Projet(
        id: widget.projet?.id,
        nom: _nomController.text.trim(),
        devisId: _selectedDevis!.id,
        chantierId: _chantierId,
        statut: _statut,
      );

      if (widget.projet?.id != null) {
        await _menuiserieService.updateProjet(widget.projet!.id!, projet);
      } else {
        await _menuiserieService.createProjet(projet);
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
        title: Text(widget.projet != null ? 'Modifier le projet' : 'Nouveau projet'),
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
                    TextFormField(
                      controller: _nomController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du projet *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Devis>(
                      value: _selectedDevis,
                      decoration: const InputDecoration(
                        labelText: 'Devis *',
                        border: OutlineInputBorder(),
                      ),
                      items: _devis.map((devis) => DropdownMenuItem(
                        value: devis,
                        child: Text('${devis.numeroDevis ?? devis.id} - ${devis.client?.displayName ?? ''}'),
                      )).toList(),
                      onChanged: (devis) {
                        setState(() {
                          _selectedDevis = devis;
                          _chantierId = devis?.chantierId;
                        });
                      },
                      validator: (value) => value == null ? 'Requis' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _statut,
                      decoration: const InputDecoration(
                        labelText: 'Statut',
                        border: OutlineInputBorder(),
                      ),
                      items: Projet.statutOptions.map((statut) {
                        final projet = Projet(statut: statut, nom: '', devisId: '');
                        return DropdownMenuItem(
                          value: statut,
                          child: Text(projet.statutLabel),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _statut = value!),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Annuler'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _save,
                            child: _isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(widget.projet != null ? 'Modifier' : 'Créer'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

