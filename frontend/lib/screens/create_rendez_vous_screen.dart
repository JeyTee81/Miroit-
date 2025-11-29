import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/planning/rendez_vous_model.dart';
import '../models/client_model.dart';
import '../models/chantier_model.dart';
import '../services/rendez_vous_service.dart';
import '../services/client_service.dart';
import '../services/chantier_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CreateRendezVousScreen extends StatefulWidget {
  final RendezVous? rendezVous;
  final DateTime? dateInitiale;

  const CreateRendezVousScreen({
    super.key,
    this.rendezVous,
    this.dateInitiale,
  });

  @override
  State<CreateRendezVousScreen> createState() => _CreateRendezVousScreenState();
}

class _CreateRendezVousScreenState extends State<CreateRendezVousScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rendezVousService = RendezVousService();
  final _clientService = ClientService();
  final _chantierService = ChantierService();
  
  bool _isLoading = false;
  bool _isSaving = false;

  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _lieuController = TextEditingController();
  
  String _type = 'commercial';
  DateTime _dateDebut = DateTime.now();
  DateTime _dateFin = DateTime.now().add(const Duration(hours: 1));
  String _statut = 'planifie';
  String? _selectedClientId;
  String? _selectedChantierId;
  String? _utilisateurId;
  
  List<Client> _clients = [];
  List<Chantier> _chantiers = [];

  @override
  void initState() {
    super.initState();
    _loadClients();
    _loadChantiers();
    _loadCurrentUser();
    
    if (widget.rendezVous != null) {
      _titreController.text = widget.rendezVous!.titre;
      _descriptionController.text = widget.rendezVous!.description ?? '';
      _lieuController.text = widget.rendezVous!.lieu ?? '';
      _type = widget.rendezVous!.type;
      _dateDebut = widget.rendezVous!.dateDebut;
      _dateFin = widget.rendezVous!.dateFin;
      _statut = widget.rendezVous!.statut;
      _selectedClientId = widget.rendezVous!.clientId;
      _selectedChantierId = widget.rendezVous!.chantierId;
      _utilisateurId = widget.rendezVous!.utilisateurId;
    } else if (widget.dateInitiale != null) {
      _dateDebut = widget.dateInitiale!;
      _dateFin = widget.dateInitiale!.add(const Duration(hours: 1));
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      // Récupérer l'ID utilisateur depuis AuthProvider ou les préférences
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      if (userData != null) {
        final userJson = jsonDecode(userData);
        if (userJson['id'] != null && _utilisateurId == null) {
          setState(() => _utilisateurId = userJson['id']);
        }
      }
    } catch (e) {
      // Ignorer les erreurs
    }
  }

  Future<void> _loadClients() async {
    try {
      final clients = await _clientService.getClients();
      setState(() => _clients = clients);
    } catch (e) {
      // Ignorer les erreurs
    }
  }

  Future<void> _loadChantiers() async {
    try {
      final chantiers = await _chantierService.getChantiers();
      setState(() => _chantiers = chantiers);
    } catch (e) {
      // Ignorer les erreurs
    }
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _lieuController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_utilisateurId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur: Utilisateur non identifié'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final rendezVous = RendezVous(
        id: widget.rendezVous?.id,
        titre: _titreController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        dateDebut: _dateDebut,
        dateFin: _dateFin,
        type: _type,
        utilisateurId: _utilisateurId!,
        clientId: _selectedClientId,
        chantierId: _selectedChantierId,
        lieu: _lieuController.text.trim().isEmpty
            ? null
            : _lieuController.text.trim(),
        statut: _statut,
      );

      if (widget.rendezVous?.id != null) {
        await _rendezVousService.updateRendezVous(widget.rendezVous!.id!, rendezVous);
      } else {
        await _rendezVousService.createRendezVous(rendezVous);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.rendezVous != null
                ? 'Rendez-vous modifié avec succès'
                : 'Rendez-vous créé avec succès'),
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
        title: Text(widget.rendezVous != null
            ? 'Modifier le rendez-vous'
            : 'Nouveau rendez-vous'),
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
                    // Titre
                    TextFormField(
                      controller: _titreController,
                      decoration: const InputDecoration(
                        labelText: 'Titre *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le titre est requis';
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
                      items: RendezVous.typeOptions.map((type) {
                        final rdv = RendezVous(
                          titre: '',
                          dateDebut: DateTime.now(),
                          dateFin: DateTime.now(),
                          type: type,
                          utilisateurId: '',
                        );
                        return DropdownMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: rdv.typeColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(rdv.typeLabel),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _type = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Dates
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _dateDebut,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(_dateDebut),
                                );
                                if (time != null) {
                                  setState(() {
                                    _dateDebut = DateTime(
                                      date.year,
                                      date.month,
                                      date.day,
                                      time.hour,
                                      time.minute,
                                    );
                                    if (_dateFin.isBefore(_dateDebut)) {
                                      _dateFin = _dateDebut.add(const Duration(hours: 1));
                                    }
                                  });
                                }
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Date et heure de début *',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(DateFormat('dd/MM/yyyy HH:mm').format(_dateDebut)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _dateFin,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(_dateFin),
                                );
                                if (time != null) {
                                  setState(() {
                                    _dateFin = DateTime(
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
                                labelText: 'Date et heure de fin *',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(DateFormat('dd/MM/yyyy HH:mm').format(_dateFin)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Client
                    DropdownButtonFormField<String>(
                      value: _selectedClientId,
                      decoration: const InputDecoration(
                        labelText: 'Client',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Aucun client')),
                        ..._clients.map((client) => DropdownMenuItem(
                          value: client.id,
                          child: Text(client.displayName),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedClientId = value;
                          // Réinitialiser le chantier si le client change
                          if (value != null) {
                            _selectedChantierId = null;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Chantier
                    DropdownButtonFormField<String>(
                      value: _selectedChantierId,
                      decoration: const InputDecoration(
                        labelText: 'Chantier',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Aucun chantier')),
                        ..._chantiers
                            .where((c) => _selectedClientId == null || c.clientId == _selectedClientId)
                            .map((chantier) => DropdownMenuItem(
                          value: chantier.id,
                          child: Text(chantier.nom),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedChantierId = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Lieu
                    TextFormField(
                      controller: _lieuController,
                      decoration: const InputDecoration(
                        labelText: 'Lieu',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    
                    // Statut
                    DropdownButtonFormField<String>(
                      value: _statut,
                      decoration: const InputDecoration(
                        labelText: 'Statut',
                        border: OutlineInputBorder(),
                      ),
                      items: RendezVous.statutOptions.map((statut) {
                        final rdv = RendezVous(
                          titre: '',
                          dateDebut: DateTime.now(),
                          dateFin: DateTime.now(),
                          type: 'commercial',
                          utilisateurId: '',
                          statut: statut,
                        );
                        return DropdownMenuItem(
                          value: statut,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: rdv.statutColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(rdv.statutLabel),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _statut = value);
                        }
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

