import 'package:flutter/material.dart';
import '../models/fournisseur_model.dart';
import '../services/fournisseur_service.dart';

class CreateFournisseurScreen extends StatefulWidget {
  final Fournisseur? fournisseur;

  const CreateFournisseurScreen({super.key, this.fournisseur});

  @override
  State<CreateFournisseurScreen> createState() => _CreateFournisseurScreenState();
}

class _CreateFournisseurScreenState extends State<CreateFournisseurScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fournisseurService = FournisseurService();
  bool _isSaving = false;

  final _raisonSocialeController = TextEditingController();
  final _siretController = TextEditingController();
  final _adresseController = TextEditingController();
  final _codePostalController = TextEditingController();
  final _villeController = TextEditingController();
  final _paysController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  bool _actif = true;

  @override
  void initState() {
    super.initState();
    if (widget.fournisseur != null) {
      final f = widget.fournisseur!;
      _raisonSocialeController.text = f.raisonSociale;
      _siretController.text = f.siret ?? '';
      _adresseController.text = f.adresse;
      _codePostalController.text = f.codePostal;
      _villeController.text = f.ville;
      _paysController.text = f.pays;
      _telephoneController.text = f.telephone ?? '';
      _emailController.text = f.email ?? '';
      _contactController.text = f.contact ?? '';
      _actif = f.actif;
    } else {
      _paysController.text = 'France';
    }
  }

  @override
  void dispose() {
    _raisonSocialeController.dispose();
    _siretController.dispose();
    _adresseController.dispose();
    _codePostalController.dispose();
    _villeController.dispose();
    _paysController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final fournisseur = Fournisseur(
        id: widget.fournisseur?.id,
        raisonSociale: _raisonSocialeController.text.trim(),
        siret: _siretController.text.trim().isEmpty ? null : _siretController.text.trim(),
        adresse: _adresseController.text.trim(),
        codePostal: _codePostalController.text.trim(),
        ville: _villeController.text.trim(),
        pays: _paysController.text.trim(),
        telephone: _telephoneController.text.trim().isEmpty 
            ? null 
            : _telephoneController.text.trim(),
        email: _emailController.text.trim().isEmpty 
            ? null 
            : _emailController.text.trim(),
        contact: _contactController.text.trim().isEmpty 
            ? null 
            : _contactController.text.trim(),
        actif: _actif,
      );

      if (widget.fournisseur?.id != null) {
        await _fournisseurService.updateFournisseur(widget.fournisseur!.id!, fournisseur);
      } else {
        await _fournisseurService.createFournisseur(fournisseur);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.fournisseur != null 
                ? 'Fournisseur modifié avec succès' 
                : 'Fournisseur créé avec succès'),
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
        title: Text(widget.fournisseur != null ? 'Modifier le fournisseur' : 'Nouveau fournisseur'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _raisonSocialeController,
                decoration: const InputDecoration(
                  labelText: 'Raison sociale *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _siretController,
                decoration: const InputDecoration(
                  labelText: 'SIRET',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 14,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _adresseController,
                decoration: const InputDecoration(
                  labelText: 'Adresse *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _codePostalController,
                      decoration: const InputDecoration(
                        labelText: 'Code postal *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _villeController,
                      decoration: const InputDecoration(
                        labelText: 'Ville *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _paysController,
                decoration: const InputDecoration(
                  labelText: 'Pays *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _telephoneController,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (!value.contains('@')) {
                            return 'Email invalide';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(
                  labelText: 'Contact',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Actif'),
                value: _actif,
                onChanged: (value) => setState(() => _actif = value),
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
                          : Text(widget.fournisseur != null ? 'Modifier' : 'Créer'),
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




