import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tournees/chauffeur_model.dart';
import '../services/tournees_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class CreateChauffeurScreen extends StatefulWidget {
  final Chauffeur? chauffeur;

  const CreateChauffeurScreen({super.key, this.chauffeur});

  @override
  State<CreateChauffeurScreen> createState() => _CreateChauffeurScreenState();
}

class _CreateChauffeurScreenState extends State<CreateChauffeurScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tourneesService = TourneesService();
  final _userService = UserService();
  bool _isSaving = false;
  bool _isLoading = false;

  String? _selectedUserId;
  final _numeroPermisController = TextEditingController();
  DateTime _dateExpirationPermis = DateTime.now().add(const Duration(days: 365));
  bool _actif = true;

  List<User> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
    if (widget.chauffeur != null) {
      _selectedUserId = widget.chauffeur!.userId;
      _numeroPermisController.text = widget.chauffeur!.numeroPermis;
      _dateExpirationPermis = widget.chauffeur!.dateExpirationPermis;
      _actif = widget.chauffeur!.actif;
    }
  }

  @override
  void dispose() {
    _numeroPermisController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _userService.getUsers();
      setState(() => _users = users);
    } catch (e) {
      // Ignorer les erreurs
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un utilisateur'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final chauffeur = Chauffeur(
        id: widget.chauffeur?.id,
        userId: _selectedUserId!,
        numeroPermis: _numeroPermisController.text.trim(),
        dateExpirationPermis: _dateExpirationPermis,
        actif: _actif,
      );

      if (widget.chauffeur?.id != null) {
        await _tourneesService.updateChauffeur(widget.chauffeur!.id!, chauffeur);
      } else {
        await _tourneesService.createChauffeur(chauffeur);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.chauffeur != null
                ? 'Chauffeur modifié avec succès'
                : 'Chauffeur créé avec succès'),
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
        title: Text(widget.chauffeur != null
            ? 'Modifier le chauffeur'
            : 'Nouveau chauffeur'),
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
                    // Utilisateur
                    DropdownButtonFormField<String>(
                      value: _selectedUserId,
                      decoration: const InputDecoration(
                        labelText: 'Utilisateur *',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Sélectionner un utilisateur')),
                        ..._users.map((u) => DropdownMenuItem(
                          value: u.id,
                          child: Text('${u.prenom ?? ""} ${u.nom ?? ""} (${u.username})'.trim()),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedUserId = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner un utilisateur';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Numéro de permis
                    TextFormField(
                      controller: _numeroPermisController,
                      decoration: const InputDecoration(
                        labelText: 'Numéro de permis *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le numéro de permis est requis';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Date d'expiration du permis
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _dateExpirationPermis,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() => _dateExpirationPermis = date);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date d\'expiration du permis *',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(DateFormat('dd/MM/yyyy').format(_dateExpirationPermis)),
                      ),
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

