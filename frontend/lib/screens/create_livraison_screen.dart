import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tournees/livraison_model.dart';
import '../models/chantier_model.dart';
import '../models/facture_model.dart';
import '../services/tournees_service.dart';

class CreateLivraisonScreen extends StatefulWidget {
  final String? tourneeId;
  final List<Chantier> chantiers;
  final List<Facture> factures;
  final Livraison? livraison;

  const CreateLivraisonScreen({
    super.key,
    this.tourneeId,
    required this.chantiers,
    required this.factures,
    this.livraison,
  });

  @override
  State<CreateLivraisonScreen> createState() => _CreateLivraisonScreenState();
}

class _CreateLivraisonScreenState extends State<CreateLivraisonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tourneesService = TourneesService();
  bool _isSaving = false;

  String? _selectedChantierId;
  String? _selectedFactureId;
  final _adresseController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  DateTime _dateLivraisonPrevue = DateTime.now().add(const Duration(hours: 2));
  final _notesController = TextEditingController();
  int _ordreLivraison = 1;

  @override
  void initState() {
    super.initState();
    if (widget.livraison != null) {
      _selectedChantierId = widget.livraison!.chantierId;
      _selectedFactureId = widget.livraison!.factureId;
      _adresseController.text = widget.livraison!.adresseLivraison;
      _latitudeController.text = widget.livraison!.latitude?.toString() ?? '';
      _longitudeController.text = widget.livraison!.longitude?.toString() ?? '';
      _dateLivraisonPrevue = widget.livraison!.dateLivraisonPrevue;
      _notesController.text = widget.livraison!.notes ?? '';
      _ordreLivraison = widget.livraison!.ordreLivraison;
    } else if (widget.chantiers.isNotEmpty) {
      _selectedChantierId = widget.chantiers.first.id;
      final chantier = widget.chantiers.firstWhere((c) => c.id == _selectedChantierId);
      _adresseController.text = chantier.adresseLivraison ?? '';
    }
  }

  @override
  void dispose() {
    _adresseController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedChantierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un chantier'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final livraison = Livraison(
        id: widget.livraison?.id,
        tourneeId: widget.tourneeId ?? widget.livraison?.tourneeId ?? '',
        chantierId: _selectedChantierId!,
        factureId: _selectedFactureId,
        ordreLivraison: _ordreLivraison,
        adresseLivraison: _adresseController.text.trim(),
        latitude: _latitudeController.text.isNotEmpty
            ? double.tryParse(_latitudeController.text)
            : null,
        longitude: _longitudeController.text.isNotEmpty
            ? double.tryParse(_longitudeController.text)
            : null,
        dateLivraisonPrevue: _dateLivraisonPrevue,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context, livraison);
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
        title: Text(widget.livraison != null
            ? 'Modifier la livraison'
            : 'Nouvelle livraison'),
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
              // Chantier
              DropdownButtonFormField<String>(
                value: _selectedChantierId,
                decoration: const InputDecoration(
                  labelText: 'Chantier *',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Sélectionner un chantier')),
                  ...widget.chantiers.map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.nom),
                  )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedChantierId = value;
                    if (value != null) {
                      final chantier = widget.chantiers.firstWhere((c) => c.id == value);
                      _adresseController.text = chantier.adresseLivraison ?? '';
                    }
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un chantier';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Facture (optionnel)
              DropdownButtonFormField<String>(
                value: _selectedFactureId,
                decoration: const InputDecoration(
                  labelText: 'Facture (optionnel)',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Aucune facture')),
                  ...widget.factures.map((f) => DropdownMenuItem(
                    value: f.id,
                    child: Text('${f.numeroFacture} - ${f.clientNom ?? "N/A"}'),
                  )),
                ],
                onChanged: (value) {
                  setState(() => _selectedFactureId = value);
                },
              ),
              const SizedBox(height: 16),
              
              // Adresse
              TextFormField(
                controller: _adresseController,
                decoration: const InputDecoration(
                  labelText: 'Adresse de livraison *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'L\'adresse est requise';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Coordonnées GPS
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Date et heure de livraison prévue
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _dateLivraisonPrevue,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_dateLivraisonPrevue),
                    );
                    if (time != null) {
                      setState(() {
                        _dateLivraisonPrevue = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date et heure de livraison prévue *',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormat('dd/MM/yyyy HH:mm').format(_dateLivraisonPrevue)),
                ),
              ),
              const SizedBox(height: 16),
              
              // Ordre de livraison
              TextFormField(
                initialValue: _ordreLivraison.toString(),
                decoration: const InputDecoration(
                  labelText: 'Ordre de livraison',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _ordreLivraison = int.tryParse(value) ?? 1;
                },
              ),
              const SizedBox(height: 16),
              
              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
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




