import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chantier_model.dart';
import '../models/client_model.dart';
import '../services/chantier_service.dart';
import '../services/client_service.dart';

class CreateChantierScreen extends StatefulWidget {
  final Chantier? chantier; // Si fourni, on est en mode édition

  const CreateChantierScreen({super.key, this.chantier});

  @override
  State<CreateChantierScreen> createState() => _CreateChantierScreenState();
}

class _CreateChantierScreenState extends State<CreateChantierScreen> {
  final _formKey = GlobalKey<FormState>();
  final _chantierService = ChantierService();
  final _clientService = ClientService();
  bool _isLoading = false;
  bool _isSaving = false;

  List<Client> _clients = [];
  Client? _selectedClient;
  final _nomController = TextEditingController();
  final _adresseController = TextEditingController();
  DateTime _dateDebut = DateTime.now();
  DateTime _dateFinPrevue = DateTime.now().add(const Duration(days: 30));
  DateTime? _dateFinReelle;
  String _statut = 'planifie';

  @override
  void initState() {
    super.initState();
    _loadClients();
    if (widget.chantier != null) {
      _nomController.text = widget.chantier!.nom;
      _adresseController.text = widget.chantier!.adresseLivraison;
      _dateDebut = widget.chantier!.dateDebut;
      _dateFinPrevue = widget.chantier!.dateFinPrevue;
      _dateFinReelle = widget.chantier!.dateFinReelle;
      _statut = widget.chantier!.statut;
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  Future<void> _loadClients() async {
    try {
      final clients = await _clientService.getClients();
      setState(() {
        _clients = clients;
        if (widget.chantier?.clientId != null && clients.isNotEmpty) {
          try {
            _selectedClient = clients.firstWhere(
              (c) => c.id == widget.chantier!.clientId,
            );
          } catch (e) {
            _selectedClient = clients.first;
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
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un client'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final chantier = Chantier(
        id: widget.chantier?.id,
        nom: _nomController.text.trim(),
        clientId: _selectedClient!.id!,
        adresseLivraison: _adresseController.text.trim(),
        dateDebut: _dateDebut,
        dateFinPrevue: _dateFinPrevue,
        dateFinReelle: _dateFinReelle,
        statut: _statut,
      );

      if (widget.chantier?.id != null) {
        await _chantierService.updateChantier(widget.chantier!.id!, chantier);
      } else {
        await _chantierService.createChantier(chantier);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.chantier != null 
                ? 'Chantier modifié avec succès' 
                : 'Chantier créé avec succès'),
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
        title: Text(widget.chantier != null ? 'Modifier le chantier' : 'Nouveau chantier'),
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
                    // Nom
                    TextFormField(
                      controller: _nomController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du chantier *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // Client
                    DropdownButtonFormField<Client>(
                      value: _selectedClient,
                      decoration: const InputDecoration(
                        labelText: 'Client *',
                        border: OutlineInputBorder(),
                      ),
                      items: _clients.map((client) => DropdownMenuItem(
                        value: client,
                        child: Text(client.displayName),
                      )).toList(),
                      onChanged: (client) {
                        setState(() => _selectedClient = client);
                      },
                      validator: (value) => value == null ? 'Requis' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // Adresse de livraison
                    TextFormField(
                      controller: _adresseController,
                      decoration: const InputDecoration(
                        labelText: 'Adresse de livraison *',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
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
                                setState(() => _dateDebut = date);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Date de début *',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(DateFormat('dd/MM/yyyy').format(_dateDebut)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _dateFinPrevue,
                                firstDate: _dateDebut,
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setState(() => _dateFinPrevue = date);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Date de fin prévue *',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(DateFormat('dd/MM/yyyy').format(_dateFinPrevue)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Date de fin réelle (optionnelle)
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _dateFinReelle ?? _dateFinPrevue,
                          firstDate: _dateDebut,
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() => _dateFinReelle = date);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date de fin réelle (optionnel)',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_dateFinReelle != null 
                            ? DateFormat('dd/MM/yyyy').format(_dateFinReelle!)
                            : 'Non définie'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Statut
                    DropdownButtonFormField<String>(
                      value: _statut,
                      decoration: const InputDecoration(
                        labelText: 'Statut',
                        border: OutlineInputBorder(),
                      ),
                      items: Chantier.statutOptions.map((statut) {
                        final chantier = Chantier(
                          statut: statut,
                          nom: '',
                          clientId: '',
                          adresseLivraison: '',
                          dateDebut: DateTime.now(),
                          dateFinPrevue: DateTime.now(),
                        );
                        return DropdownMenuItem(
                          value: statut,
                          child: Text(chantier.statutLabel),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _statut = value!),
                    ),
                    const SizedBox(height: 24),
                    
                    // Boutons
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
                                : Text(widget.chantier != null ? 'Modifier' : 'Créer'),
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

