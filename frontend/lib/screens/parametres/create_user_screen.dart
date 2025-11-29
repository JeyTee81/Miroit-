import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';
import '../../models/group_model.dart';

class CreateUserScreen extends StatefulWidget {
  final User? user;
  final List<Group> groups;

  const CreateUserScreen({
    super.key,
    this.user,
    required this.groups,
  });

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final UserService _userService = UserService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _selectedRole;
  String? _selectedGroupeId;
  bool _actif = true;

  final List<String> _roles = [
    'admin',
    'commercial',
    'atelier',
    'ouvrier',
    'logistique',
    'comptable',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _usernameController.text = widget.user!.username;
      _emailController.text = widget.user!.email ?? '';
      _nomController.text = widget.user!.nom ?? '';
      _prenomController.text = widget.user!.prenom ?? '';
      _selectedRole = widget.user!.role;
      _selectedGroupeId = widget.user!.groupeId;
      _actif = widget.user!.actif ?? true;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Vérifier le mot de passe si création
    if (widget.user == null) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Les mots de passe ne correspondent pas'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_passwordController.text.length < 8) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Le mot de passe doit contenir au moins 8 caractères'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = User(
        id: widget.user?.id,
        username: _usernameController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        nom: _nomController.text.trim().isEmpty
            ? null
            : _nomController.text.trim(),
        prenom: _prenomController.text.trim().isEmpty
            ? null
            : _prenomController.text.trim(),
        role: _selectedRole,
        groupeId: _selectedGroupeId,
        actif: _actif,
      );

      if (widget.user != null) {
        await _userService.updateUser(user);
      } else {
        await _userService.createUser(user, _passwordController.text);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.user != null
                  ? 'Utilisateur mis à jour avec succès'
                  : 'Utilisateur créé avec succès',
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
        title: Text(widget.user != null ? 'Modifier l\'utilisateur' : 'Nouvel utilisateur'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Informations de connexion
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Nom d\'utilisateur *',
                border: OutlineInputBorder(),
              ),
              enabled: widget.user == null, // Ne pas modifier le username
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nom d\'utilisateur est requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            if (widget.user == null) ...[
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Mot de passe *',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le mot de passe est requis';
                  }
                  if (value.length < 8) {
                    return 'Le mot de passe doit contenir au moins 8 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirmer le mot de passe *',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La confirmation est requise';
                  }
                  if (value != _passwordController.text) {
                    return 'Les mots de passe ne correspondent pas';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],
            // Informations personnelles
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nomController,
              decoration: const InputDecoration(
                labelText: 'Nom',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _prenomController,
              decoration: const InputDecoration(
                labelText: 'Prénom',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Rôle
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Rôle',
                border: OutlineInputBorder(),
              ),
              items: _roles.map((role) {
                String label;
                switch (role) {
                  case 'admin':
                    label = 'Administrateur';
                    break;
                  case 'commercial':
                    label = 'Commercial';
                    break;
                  case 'atelier':
                    label = 'Service technique';
                    break;
                  case 'ouvrier':
                    label = 'Ouvrier';
                    break;
                  case 'logistique':
                    label = 'Logistique';
                    break;
                  case 'comptable':
                    label = 'Comptable';
                    break;
                  default:
                    label = role;
                }
                return DropdownMenuItem(value: role, child: Text(label));
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedRole = value);
              },
            ),
            const SizedBox(height: 16),
            // Groupe
            DropdownButtonFormField<String>(
              value: _selectedGroupeId,
              decoration: const InputDecoration(
                labelText: 'Groupe',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Aucun groupe'),
                ),
                ...widget.groups.map((group) {
                  return DropdownMenuItem<String>(
                    value: group.id,
                    child: Text(group.nom),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() => _selectedGroupeId = value);
              },
            ),
            const SizedBox(height: 16),
            // Actif
            SwitchListTile(
              title: const Text('Utilisateur actif'),
              value: _actif,
              onChanged: (value) {
                setState(() => _actif = value);
              },
            ),
            const SizedBox(height: 32),
            // Bouton de sauvegarde
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveUser,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(widget.user != null ? 'Mettre à jour' : 'Créer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

