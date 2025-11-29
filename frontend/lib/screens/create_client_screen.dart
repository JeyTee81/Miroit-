import 'package:flutter/material.dart';
import '../models/client_model.dart';
import '../services/client_service.dart';

class CreateClientScreen extends StatefulWidget {
  final Client? client; // Si fourni, on est en mode édition

  const CreateClientScreen({super.key, this.client});

  @override
  State<CreateClientScreen> createState() => _CreateClientScreenState();
}

class _CreateClientScreenState extends State<CreateClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientService = ClientService();
  bool _isLoading = false;

  // Contrôleurs
  late String _type;
  final _raisonSocialeController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _siretController = TextEditingController();
  final _adresseController = TextEditingController();
  final _codePostalController = TextEditingController();
  final _villeController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _zoneGeographiqueController = TextEditingController();
  final _familleClientController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _type = widget.client?.type ?? 'particulier';
    
    if (widget.client != null) {
      _raisonSocialeController.text = widget.client!.raisonSociale ?? '';
      _nomController.text = widget.client!.nom;
      _prenomController.text = widget.client!.prenom ?? '';
      _siretController.text = widget.client!.siret ?? '';
      _adresseController.text = widget.client!.adresse;
      _codePostalController.text = widget.client!.codePostal;
      _villeController.text = widget.client!.ville;
      _telephoneController.text = widget.client!.telephone ?? '';
      _emailController.text = widget.client!.email ?? '';
      _zoneGeographiqueController.text = widget.client!.zoneGeographique ?? '';
      _familleClientController.text = widget.client!.familleClient ?? '';
      _notesController.text = widget.client!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _raisonSocialeController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _siretController.dispose();
    _adresseController.dispose();
    _codePostalController.dispose();
    _villeController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _zoneGeographiqueController.dispose();
    _familleClientController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveClient() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final client = Client(
        id: widget.client?.id,
        type: _type,
        raisonSociale: _raisonSocialeController.text.isEmpty
            ? null
            : _raisonSocialeController.text,
        nom: _nomController.text,
        prenom: _prenomController.text.isEmpty ? null : _prenomController.text,
        siret: _siretController.text.isEmpty ? null : _siretController.text,
        adresse: _adresseController.text,
        codePostal: _codePostalController.text,
        ville: _villeController.text,
        telephone:
            _telephoneController.text.isEmpty ? null : _telephoneController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        zoneGeographique: _zoneGeographiqueController.text.isEmpty
            ? null
            : _zoneGeographiqueController.text,
        familleClient: _familleClientController.text.isEmpty
            ? null
            : _familleClientController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      if (widget.client != null) {
        await _clientService.updateClient(client);
      } else {
        await _clientService.createClient(client);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                widget.client != null
                    ? 'Client modifié avec succès'
                    : 'Client créé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client != null ? 'Modifier le client' : 'Nouveau client'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Type de client
                    DropdownButtonFormField<String>(
                      value: _type,
                      decoration: const InputDecoration(
                        labelText: 'Type de client *',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'particulier',
                          child: Text('Particulier'),
                        ),
                        DropdownMenuItem(
                          value: 'professionnel',
                          child: Text('Professionnel'),
                        ),
                        DropdownMenuItem(
                          value: 'entreprise',
                          child: Text('Entreprise'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _type = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Raison sociale (si entreprise/professionnel)
                    if (_type == 'entreprise' || _type == 'professionnel')
                      TextFormField(
                        controller: _raisonSocialeController,
                        decoration: const InputDecoration(
                          labelText: 'Raison sociale',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    if (_type == 'entreprise' || _type == 'professionnel')
                      const SizedBox(height: 16),

                    // Nom
                    TextFormField(
                      controller: _nomController,
                      decoration: const InputDecoration(
                        labelText: 'Nom *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le nom est obligatoire';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Prénom
                    TextFormField(
                      controller: _prenomController,
                      decoration: const InputDecoration(
                        labelText: 'Prénom',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // SIRET
                    if (_type == 'entreprise' || _type == 'professionnel')
                      TextFormField(
                        controller: _siretController,
                        decoration: const InputDecoration(
                          labelText: 'SIRET',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    if (_type == 'entreprise' || _type == 'professionnel')
                      const SizedBox(height: 16),

                    // Adresse
                    TextFormField(
                      controller: _adresseController,
                      decoration: const InputDecoration(
                        labelText: 'Adresse *',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'L\'adresse est obligatoire';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Code postal
                    TextFormField(
                      controller: _codePostalController,
                      decoration: const InputDecoration(
                        labelText: 'Code postal *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le code postal est obligatoire';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Ville
                    TextFormField(
                      controller: _villeController,
                      decoration: const InputDecoration(
                        labelText: 'Ville *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La ville est obligatoire';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Téléphone
                    TextFormField(
                      controller: _telephoneController,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            !value.contains('@')) {
                          return 'Email invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Zone géographique
                    TextFormField(
                      controller: _zoneGeographiqueController,
                      decoration: const InputDecoration(
                        labelText: 'Zone géographique',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Famille client
                    TextFormField(
                      controller: _familleClientController,
                      decoration: const InputDecoration(
                        labelText: 'Famille client',
                        border: OutlineInputBorder(),
                      ),
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

                    // Bouton Enregistrer
                    ElevatedButton(
                      onPressed: _saveClient,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Enregistrer'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}






