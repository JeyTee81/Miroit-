import 'package:flutter/material.dart';
import '../models/tournees/chariot_model.dart';
import '../services/tournees_service.dart';

class CreateChariotScreen extends StatefulWidget {
  final Chariot? chariot;

  const CreateChariotScreen({super.key, this.chariot});

  @override
  State<CreateChariotScreen> createState() => _CreateChariotScreenState();
}

class _CreateChariotScreenState extends State<CreateChariotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tourneesService = TourneesService();
  bool _isSaving = false;

  final _numeroController = TextEditingController();
  final _typeController = TextEditingController();
  final _capaciteController = TextEditingController();
  bool _actif = true;

  @override
  void initState() {
    super.initState();
    if (widget.chariot != null) {
      _numeroController.text = widget.chariot!.numero;
      _typeController.text = widget.chariot!.type;
      _capaciteController.text = widget.chariot!.capacite?.toString() ?? '';
      _actif = widget.chariot!.actif;
    }
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _typeController.dispose();
    _capaciteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final chariot = Chariot(
        id: widget.chariot?.id,
        numero: _numeroController.text.trim(),
        type: _typeController.text.trim(),
        capacite: _capaciteController.text.isNotEmpty
            ? double.tryParse(_capaciteController.text)
            : null,
        actif: _actif,
      );

      if (widget.chariot?.id != null) {
        await _tourneesService.updateChariot(widget.chariot!.id!, chariot);
      } else {
        await _tourneesService.createChariot(chariot);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.chariot != null
                ? 'Chariot modifié avec succès'
                : 'Chariot créé avec succès'),
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
        title: Text(widget.chariot != null
            ? 'Modifier le chariot'
            : 'Nouveau chariot'),
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
              // Numéro
              TextFormField(
                controller: _numeroController,
                decoration: const InputDecoration(
                  labelText: 'Numéro *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le numéro est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Type
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Type *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le type est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Capacité
              TextFormField(
                controller: _capaciteController,
                decoration: const InputDecoration(
                  labelText: 'Capacité',
                  border: OutlineInputBorder(),
                  helperText: 'Capacité en kg ou unités',
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




