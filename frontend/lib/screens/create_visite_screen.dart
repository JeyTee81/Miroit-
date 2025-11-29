import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/crm/visite_model.dart';
import '../models/client_model.dart';
import '../services/crm_service.dart';
import '../services/client_service.dart';

class CreateVisiteScreen extends StatefulWidget {
  final Visite? visite;

  const CreateVisiteScreen({super.key, this.visite});

  @override
  State<CreateVisiteScreen> createState() => _CreateVisiteScreenState();
}

class _CreateVisiteScreenState extends State<CreateVisiteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _crmService = CrmService();
  final _clientService = ClientService();
  bool _isSaving = false;
  bool _isLoading = false;

  String? _selectedClientId;
  String? _selectedCommercialId;
  DateTime _dateVisite = DateTime.now();
  String _typeVisite = 'prise_contact';
  final _notesController = TextEditingController();
  final _resultatController = TextEditingController();
  
  List<Client> _clients = [];

  @override
  void initState() {
    super.initState();
    _loadClients();
    _loadCurrentUser();
    
    if (widget.visite != null) {
      _selectedClientId = widget.visite!.clientId;
      _selectedCommercialId = widget.visite!.commercialId;
      _dateVisite = widget.visite!.dateVisite;
      _typeVisite = widget.visite!.typeVisite;
      _notesController.text = widget.visite!.notes;
      _resultatController.text = widget.visite!.resultat ?? '';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _resultatController.dispose();
    super.dispose();
  }

  Future<void> _loadClients() async {
    setState(() => _isLoading = true);
    try {
      final clients = await _clientService.getClients();
      setState(() => _clients = clients);
    } catch (e) {
      // Ignorer les erreurs
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId != null && _selectedCommercialId == null) {
        setState(() => _selectedCommercialId = userId);
      }
    } catch (e) {
      // Ignorer les erreurs
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClientId == null) {
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
      final visite = Visite(
        id: widget.visite?.id,
        clientId: _selectedClientId!,
        commercialId: _selectedCommercialId,
        dateVisite: _dateVisite,
        typeVisite: _typeVisite,
        notes: _notesController.text.trim(),
        resultat: _resultatController.text.trim().isEmpty
            ? null
            : _resultatController.text.trim(),
      );

      if (widget.visite?.id != null) {
        await _crmService.updateVisite(widget.visite!.id!, visite);
      } else {
        await _crmService.createVisite(visite);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.visite != null
                ? 'Visite modifiée avec succès'
                : 'Visite créée avec succès'),
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
        title: Text(widget.visite != null
            ? 'Modifier la visite'
            : 'Nouvelle visite'),
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
                    // Client
                    DropdownButtonFormField<String>(
                      value: _selectedClientId,
                      decoration: const InputDecoration(
                        labelText: 'Client *',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Sélectionner un client')),
                        ..._clients.map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.displayName),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedClientId = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner un client';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Date de visite
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _dateVisite,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() => _dateVisite = date);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date de visite *',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(DateFormat('dd/MM/yyyy').format(_dateVisite)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Type de visite
                    DropdownButtonFormField<String>(
                      value: _typeVisite,
                      decoration: const InputDecoration(
                        labelText: 'Type de visite *',
                        border: OutlineInputBorder(),
                      ),
                      items: Visite.typeOptions.map((type) {
                        final v = Visite(
                          clientId: '',
                          dateVisite: DateTime.now(),
                          typeVisite: type,
                          notes: '',
                        );
                        return DropdownMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: v.typeColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(v.typeLabel),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _typeVisite = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes *',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Les notes sont requises';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Résultat
                    TextFormField(
                      controller: _resultatController,
                      decoration: const InputDecoration(
                        labelText: 'Résultat',
                        border: OutlineInputBorder(),
                        helperText: 'Résultat de la visite (optionnel)',
                      ),
                      maxLines: 2,
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




