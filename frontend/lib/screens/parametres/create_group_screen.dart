import 'package:flutter/material.dart';
import '../../services/group_service.dart';
import '../../models/group_model.dart';

class CreateGroupScreen extends StatefulWidget {
  final Group? group;

  const CreateGroupScreen({super.key, this.group});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _descriptionController = TextEditingController();
  final GroupService _groupService = GroupService();
  bool _isLoading = false;

  // Permissions par module
  bool _accesCommerciale = false;
  bool _accesMenuiserie = false;
  bool _accesVitrages = false;
  bool _accesOptimisation = false;
  bool _accesStock = false;
  bool _accesTravaux = false;
  bool _accesPlanning = false;
  bool _accesTournees = false;
  bool _accesCrm = false;
  bool _accesInertie = false;
  bool _accesParametres = false;
  bool _accesLogs = false;
  bool _actif = true;

  @override
  void initState() {
    super.initState();
    if (widget.group != null) {
      _nomController.text = widget.group!.nom;
      _descriptionController.text = widget.group!.description ?? '';
      _accesCommerciale = widget.group!.accesCommerciale;
      _accesMenuiserie = widget.group!.accesMenuiserie;
      _accesVitrages = widget.group!.accesVitrages;
      _accesOptimisation = widget.group!.accesOptimisation;
      _accesStock = widget.group!.accesStock;
      _accesTravaux = widget.group!.accesTravaux;
      _accesPlanning = widget.group!.accesPlanning;
      _accesTournees = widget.group!.accesTournees;
      _accesCrm = widget.group!.accesCrm;
      _accesInertie = widget.group!.accesInertie;
      _accesParametres = widget.group!.accesParametres;
      _accesLogs = widget.group!.accesLogs;
      _actif = widget.group!.actif;
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveGroup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final group = Group(
        id: widget.group?.id ?? '',
        nom: _nomController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        accesCommerciale: _accesCommerciale,
        accesMenuiserie: _accesMenuiserie,
        accesVitrages: _accesVitrages,
        accesOptimisation: _accesOptimisation,
        accesStock: _accesStock,
        accesTravaux: _accesTravaux,
        accesPlanning: _accesPlanning,
        accesTournees: _accesTournees,
        accesCrm: _accesCrm,
        accesInertie: _accesInertie,
        accesParametres: _accesParametres,
        accesLogs: _accesLogs,
        actif: _actif,
        modulesAccessibles: [],
        nombreUtilisateurs: 0,
      );

      if (widget.group != null) {
        await _groupService.updateGroup(group);
      } else {
        await _groupService.createGroup(group);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.group != null
                  ? 'Groupe mis à jour avec succès'
                  : 'Groupe créé avec succès',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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
        title: Text(widget.group != null ? 'Modifier le groupe' : 'Nouveau groupe'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Informations générales
            TextFormField(
              controller: _nomController,
              decoration: const InputDecoration(
                labelText: 'Nom du groupe *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nom est requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Groupe actif'),
              value: _actif,
              onChanged: (value) {
                setState(() {
                  _actif = value;
                });
              },
            ),
            const Divider(height: 32),
            // Permissions par module
            const Text(
              'Permissions par module',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildModuleCheckbox('Commerciale', _accesCommerciale, (value) {
              setState(() => _accesCommerciale = value);
            }),
            _buildModuleCheckbox('Menuiserie', _accesMenuiserie, (value) {
              setState(() => _accesMenuiserie = value);
            }),
            _buildModuleCheckbox('Vitrages', _accesVitrages, (value) {
              setState(() => _accesVitrages = value);
            }),
            _buildModuleCheckbox('Débit', _accesOptimisation, (value) {
              setState(() => _accesOptimisation = value);
            }),
            _buildModuleCheckbox('Stock', _accesStock, (value) {
              setState(() => _accesStock = value);
            }),
            _buildModuleCheckbox('Travaux', _accesTravaux, (value) {
              setState(() => _accesTravaux = value);
            }),
            _buildModuleCheckbox('Planning', _accesPlanning, (value) {
              setState(() => _accesPlanning = value);
            }),
            _buildModuleCheckbox('Tournées', _accesTournees, (value) {
              setState(() => _accesTournees = value);
            }),
            _buildModuleCheckbox('CRM', _accesCrm, (value) {
              setState(() => _accesCrm = value);
            }),
            _buildModuleCheckbox('Inertie', _accesInertie, (value) {
              setState(() => _accesInertie = value);
            }),
            _buildModuleCheckbox('Paramètres', _accesParametres, (value) {
              setState(() => _accesParametres = value);
            }),
            _buildModuleCheckbox('Logs', _accesLogs, (value) {
              setState(() => _accesLogs = value);
            }),
            const SizedBox(height: 32),
            // Bouton de sauvegarde
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveGroup,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(widget.group != null ? 'Mettre à jour' : 'Créer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCheckbox(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return CheckboxListTile(
      title: Text(label),
      value: value,
      onChanged: (newValue) => onChanged(newValue ?? false),
    );
  }
}

