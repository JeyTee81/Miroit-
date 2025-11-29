import 'package:flutter/material.dart';
import '../models/tournees/vehicule_model.dart';
import '../services/tournees_service.dart';

class CreateVehiculeScreen extends StatefulWidget {
  final Vehicule? vehicule;

  const CreateVehiculeScreen({super.key, this.vehicule});

  @override
  State<CreateVehiculeScreen> createState() => _CreateVehiculeScreenState();
}

class _CreateVehiculeScreenState extends State<CreateVehiculeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tourneesService = TourneesService();
  bool _isSaving = false;

  final _immatriculationController = TextEditingController();
  final _marqueController = TextEditingController();
  final _modeleController = TextEditingController();
  String _type = 'utilitaire';
  final _capaciteController = TextEditingController();
  bool _actif = true;

  @override
  void initState() {
    super.initState();
    if (widget.vehicule != null) {
      _immatriculationController.text = widget.vehicule!.immatriculation;
      _marqueController.text = widget.vehicule!.marque;
      _modeleController.text = widget.vehicule!.modele;
      _type = widget.vehicule!.type;
      _capaciteController.text = widget.vehicule!.capaciteCharge?.toString() ?? '';
      _actif = widget.vehicule!.actif;
    }
  }

  @override
  void dispose() {
    _immatriculationController.dispose();
    _marqueController.dispose();
    _modeleController.dispose();
    _capaciteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final vehicule = Vehicule(
        id: widget.vehicule?.id,
        immatriculation: _immatriculationController.text.trim(),
        marque: _marqueController.text.trim(),
        modele: _modeleController.text.trim(),
        type: _type,
        capaciteCharge: _capaciteController.text.isNotEmpty
            ? double.tryParse(_capaciteController.text)
            : null,
        actif: _actif,
      );

      if (widget.vehicule?.id != null) {
        await _tourneesService.updateVehicule(widget.vehicule!.id!, vehicule);
      } else {
        await _tourneesService.createVehicule(vehicule);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.vehicule != null
                ? 'Véhicule modifié avec succès'
                : 'Véhicule créé avec succès'),
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
        title: Text(widget.vehicule != null
            ? 'Modifier le véhicule'
            : 'Nouveau véhicule'),
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
              // Immatriculation
              TextFormField(
                controller: _immatriculationController,
                decoration: const InputDecoration(
                  labelText: 'Immatriculation *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'L\'immatriculation est requise';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Marque
              TextFormField(
                controller: _marqueController,
                decoration: const InputDecoration(
                  labelText: 'Marque *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La marque est requise';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Modèle
              TextFormField(
                controller: _modeleController,
                decoration: const InputDecoration(
                  labelText: 'Modèle *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le modèle est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Type
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(
                  labelText: 'Type *',
                  border: OutlineInputBorder(),
                ),
                items: Vehicule.typeOptions.map((type) {
                  final v = Vehicule(
                    immatriculation: '',
                    marque: '',
                    modele: '',
                    type: type,
                  );
                  return DropdownMenuItem(
                    value: type,
                    child: Text(v.typeLabel),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _type = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Capacité de charge
              TextFormField(
                controller: _capaciteController,
                decoration: const InputDecoration(
                  labelText: 'Capacité de charge',
                  border: OutlineInputBorder(),
                  helperText: 'Capacité en kg',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (double.tryParse(value) == null) {
                      return 'Veuillez entrer un nombre valide';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Actif
              SwitchListTile(
                title: const Text('Actif'),
                value: _actif,
                onChanged: (value) {
                  setState(() => _actif = value);
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




