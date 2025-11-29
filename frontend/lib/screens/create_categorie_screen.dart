import 'package:flutter/material.dart';
import '../models/categorie_model.dart';
import '../services/categorie_service.dart';

class CreateCategorieScreen extends StatefulWidget {
  final Categorie? categorie;

  const CreateCategorieScreen({super.key, this.categorie});

  @override
  State<CreateCategorieScreen> createState() => _CreateCategorieScreenState();
}

class _CreateCategorieScreenState extends State<CreateCategorieScreen> {
  final _formKey = GlobalKey<FormState>();
  final _categorieService = CategorieService();
  bool _isSaving = false;
  bool _isLoading = false;

  List<Categorie> _categories = [];
  Categorie? _selectedParent;
  final _nomController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.categorie != null) {
      _nomController.text = widget.categorie!.nom;
      _descriptionController.text = widget.categorie!.description ?? '';
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final categories = await _categorieService.getCategories();
      setState(() {
        _categories = categories.where((c) => c.id != widget.categorie?.id).toList();
        if (widget.categorie?.parentId != null) {
          try {
            _selectedParent = categories.firstWhere(
              (c) => c.id == widget.categorie!.parentId,
            );
          } catch (e) {
            // Parent introuvable
          }
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final categorie = Categorie(
        id: widget.categorie?.id,
        nom: _nomController.text.trim(),
        parentId: _selectedParent?.id,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
      );

      if (widget.categorie?.id != null) {
        await _categorieService.updateCategorie(widget.categorie!.id!, categorie);
      } else {
        await _categorieService.createCategorie(categorie);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.categorie != null 
                ? 'Catégorie modifiée avec succès' 
                : 'Catégorie créée avec succès'),
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
        title: Text(widget.categorie != null ? 'Modifier la catégorie' : 'Nouvelle catégorie'),
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
                    TextFormField(
                      controller: _nomController,
                      decoration: const InputDecoration(
                        labelText: 'Nom *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Categorie>(
                      value: _selectedParent,
                      decoration: const InputDecoration(
                        labelText: 'Catégorie parente',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<Categorie>(
                          value: null,
                          child: Text('Aucune (catégorie racine)'),
                        ),
                        ..._categories.map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat.nom),
                        )),
                      ],
                      onChanged: (categorie) => setState(() => _selectedParent = categorie),
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
                    const SizedBox(height: 24),
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
                                : Text(widget.categorie != null ? 'Modifier' : 'Créer'),
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

