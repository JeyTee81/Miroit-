import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tournees/tournee_model.dart';
import '../models/tournees/vehicule_model.dart';
import '../models/tournees/chauffeur_model.dart';
import '../models/tournees/livraison_model.dart';
import '../models/chantier_model.dart';
import '../services/tournees_service.dart';
import '../services/chantier_service.dart';
import '../services/facture_service.dart';
import '../models/facture_model.dart';
import 'create_livraison_screen.dart';

class CreateTourneeScreen extends StatefulWidget {
  final Tournee? tournee;

  const CreateTourneeScreen({super.key, this.tournee});

  @override
  State<CreateTourneeScreen> createState() => _CreateTourneeScreenState();
}

class _CreateTourneeScreenState extends State<CreateTourneeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tourneesService = TourneesService();
  final _chantierService = ChantierService();
  final _factureService = FactureService();
  
  bool _isLoading = false;
  bool _isSaving = false;

  final _numeroTourneeController = TextEditingController();
  DateTime _dateTournee = DateTime.now();
  String? _selectedVehiculeId;
  String? _selectedChauffeurId;
  String _statut = 'planifiee';
  
  List<Vehicule> _vehicules = [];
  List<Chauffeur> _chauffeurs = [];
  List<Livraison> _livraisons = [];
  List<Chantier> _chantiers = [];
  List<Facture> _factures = [];

  @override
  void initState() {
    super.initState();
    _loadVehicules();
    _loadChauffeurs();
    _loadChantiers();
    _loadFactures();
    
    if (widget.tournee != null) {
      _numeroTourneeController.text = widget.tournee!.numeroTournee;
      _dateTournee = widget.tournee!.dateTournee;
      _selectedVehiculeId = widget.tournee!.vehiculeId;
      _selectedChauffeurId = widget.tournee!.chauffeurId;
      _statut = widget.tournee!.statut;
      _livraisons = widget.tournee!.livraisons ?? [];
    }
  }

  @override
  void dispose() {
    _numeroTourneeController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicules() async {
    try {
      final vehicules = await _tourneesService.getVehicules(actif: true);
      setState(() => _vehicules = vehicules);
    } catch (e) {
      // Ignorer les erreurs
    }
  }

  Future<void> _loadChauffeurs() async {
    try {
      final chauffeurs = await _tourneesService.getChauffeurs(actif: true);
      setState(() => _chauffeurs = chauffeurs);
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

  Future<void> _loadFactures() async {
    try {
      final factures = await _factureService.getFactures();
      setState(() => _factures = factures);
    } catch (e) {
      // Ignorer les erreurs
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVehiculeId == null || _selectedChauffeurId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un véhicule et un chauffeur'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final tournee = Tournee(
        id: widget.tournee?.id,
        numeroTournee: _numeroTourneeController.text.trim(),
        dateTournee: _dateTournee,
        vehiculeId: _selectedVehiculeId!,
        chauffeurId: _selectedChauffeurId!,
        statut: _statut,
      );

      Tournee savedTournee;
      if (widget.tournee?.id != null) {
        savedTournee = await _tourneesService.updateTournee(widget.tournee!.id!, tournee);
      } else {
        savedTournee = await _tourneesService.createTournee(tournee);
      }

      // Créer les livraisons
      for (var livraison in _livraisons) {
        if (livraison.id == null) {
          final newLivraison = Livraison(
            tourneeId: savedTournee.id!,
            chantierId: livraison.chantierId,
            factureId: livraison.factureId,
            ordreLivraison: livraison.ordreLivraison,
            adresseLivraison: livraison.adresseLivraison,
            latitude: livraison.latitude,
            longitude: livraison.longitude,
            dateLivraisonPrevue: livraison.dateLivraisonPrevue,
            notes: livraison.notes,
          );
          await _tourneesService.createLivraison(newLivraison);
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.tournee != null
                ? 'Tournée modifiée avec succès'
                : 'Tournée créée avec succès'),
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
        title: Text(widget.tournee != null
            ? 'Modifier la tournée'
            : 'Nouvelle tournée'),
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
                    // Numéro tournée
                    TextFormField(
                      controller: _numeroTourneeController,
                      decoration: const InputDecoration(
                        labelText: 'Numéro de tournée',
                        border: OutlineInputBorder(),
                        helperText: 'Laissé vide pour génération automatique',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Date
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _dateTournee,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() => _dateTournee = date);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date de tournée *',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(DateFormat('dd/MM/yyyy').format(_dateTournee)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Véhicule
                    DropdownButtonFormField<String>(
                      value: _selectedVehiculeId,
                      decoration: const InputDecoration(
                        labelText: 'Véhicule *',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Sélectionner un véhicule')),
                        ..._vehicules.map((v) => DropdownMenuItem(
                          value: v.id,
                          child: Text('${v.immatriculation} - ${v.marque} ${v.modele}'),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedVehiculeId = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner un véhicule';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Chauffeur
                    DropdownButtonFormField<String>(
                      value: _selectedChauffeurId,
                      decoration: const InputDecoration(
                        labelText: 'Chauffeur *',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Sélectionner un chauffeur')),
                        ..._chauffeurs.map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.displayName),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedChauffeurId = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner un chauffeur';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Statut
                    DropdownButtonFormField<String>(
                      value: _statut,
                      decoration: const InputDecoration(
                        labelText: 'Statut',
                        border: OutlineInputBorder(),
                      ),
                      items: Tournee.statutOptions.map((statut) {
                        final t = Tournee(
                          numeroTournee: '',
                          dateTournee: DateTime.now(),
                          vehiculeId: '',
                          chauffeurId: '',
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
                                  color: t.statutColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(t.statutLabel),
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
                    
                    // Section livraisons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Livraisons',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateLivraisonScreen(
                                  tourneeId: widget.tournee?.id,
                                  chantiers: _chantiers,
                                  factures: _factures,
                                ),
                              ),
                            );
                            if (result != null && result is Livraison) {
                              setState(() {
                                _livraisons.add(result);
                                // Réordonner par ordre_livraison
                                _livraisons.sort((a, b) => a.ordreLivraison.compareTo(b.ordreLivraison));
                              });
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter une livraison'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Liste des livraisons
                    if (_livraisons.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Aucune livraison ajoutée',
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      ..._livraisons.asMap().entries.map((entry) {
                        final index = entry.key;
                        final livraison = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text('${livraison.ordreLivraison}'),
                            ),
                            title: Text(livraison.chantierNom ?? 'Chantier inconnu'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(livraison.adresseLivraison),
                                if (livraison.factureNumero != null)
                                  Text('Facture: ${livraison.factureNumero}'),
                                Text(
                                  DateFormat('dd/MM/yyyy HH:mm').format(livraison.dateLivraisonPrevue),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _livraisons.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      }),
                    
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

