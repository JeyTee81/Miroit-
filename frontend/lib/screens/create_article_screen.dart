import 'package:flutter/material.dart';
import '../models/article_model.dart';
import '../models/categorie_model.dart';
import '../services/article_service.dart';
import '../services/categorie_service.dart';

class CreateArticleScreen extends StatefulWidget {
  final Article? article;

  const CreateArticleScreen({super.key, this.article});

  @override
  State<CreateArticleScreen> createState() => _CreateArticleScreenState();
}

class _CreateArticleScreenState extends State<CreateArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _articleService = ArticleService();
  final _categorieService = CategorieService();
  bool _isLoading = false;

  List<Categorie> _categories = [];
  Categorie? _selectedCategorie;
  
  final _referenceController = TextEditingController();
  final _designationController = TextEditingController();
  String _uniteMesure = 'unite';
  final _prixAchatController = TextEditingController();
  final _prixVenteController = TextEditingController();
  final _tauxTvaController = TextEditingController(text: '20');
  final _stockMinimumController = TextEditingController(text: '0');
  final _stockActuelController = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.article != null) {
      _referenceController.text = widget.article!.reference;
      _designationController.text = widget.article!.designation;
      _uniteMesure = widget.article!.uniteMesure;
      _prixAchatController.text = widget.article!.prixAchatHt.toString();
      _prixVenteController.text = widget.article!.prixVenteHt.toString();
      _tauxTvaController.text = widget.article!.tauxTva.toString();
      _stockMinimumController.text = widget.article!.stockMinimum.toString();
      _stockActuelController.text = widget.article!.stockActuel.toString();
    }
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _designationController.dispose();
    _prixAchatController.dispose();
    _prixVenteController.dispose();
    _tauxTvaController.dispose();
    _stockMinimumController.dispose();
    _stockActuelController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categorieService.getCategories();
      setState(() {
        _categories = categories;
        if (widget.article?.categorieId != null) {
          _selectedCategorie = categories.firstWhere(
            (c) => c.id == widget.article!.categorieId,
            orElse: () => categories.isNotEmpty ? categories.first : categories.first,
          );
        } else if (categories.isNotEmpty) {
          _selectedCategorie = categories.first;
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

  Future<void> _saveArticle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategorie == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une catégorie'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final article = Article(
        id: widget.article?.id,
        reference: _referenceController.text,
        designation: _designationController.text,
        categorieId: _selectedCategorie!.id,
        uniteMesure: _uniteMesure,
        prixAchatHt: double.parse(_prixAchatController.text),
        prixVenteHt: double.parse(_prixVenteController.text),
        tauxTva: double.tryParse(_tauxTvaController.text) ?? 20.0,
        stockMinimum: double.tryParse(_stockMinimumController.text) ?? 0.0,
        stockActuel: double.tryParse(_stockActuelController.text) ?? 0.0,
      );

      if (widget.article != null) {
        await _articleService.updateArticle(article);
      } else {
        await _articleService.createArticle(article);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.article != null
                ? 'Article modifié avec succès'
                : 'Article créé avec succès'),
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
        title: Text(widget.article != null ? 'Modifier l\'article' : 'Nouvel article'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveArticle,
          ),
        ],
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
                    // Référence
                    TextFormField(
                      controller: _referenceController,
                      decoration: const InputDecoration(
                        labelText: 'Référence *',
                        border: OutlineInputBorder(),
                        helperText: 'Code unique de l\'article',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La référence est obligatoire';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Désignation
                    TextFormField(
                      controller: _designationController,
                      decoration: const InputDecoration(
                        labelText: 'Désignation *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La désignation est obligatoire';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Catégorie
                    DropdownButtonFormField<Categorie>(
                      value: _selectedCategorie,
                      decoration: const InputDecoration(
                        labelText: 'Catégorie *',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((categorie) {
                        return DropdownMenuItem(
                          value: categorie,
                          child: Text(categorie.nom),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategorie = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner une catégorie';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Unité de mesure
                    DropdownButtonFormField<String>(
                      value: _uniteMesure,
                      decoration: const InputDecoration(
                        labelText: 'Unité de mesure *',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'unite', child: Text('Unité')),
                        DropdownMenuItem(value: 'm2', child: Text('m²')),
                        DropdownMenuItem(value: 'ml', child: Text('mètre linéaire')),
                        DropdownMenuItem(value: 'kg', child: Text('Kilogramme')),
                        DropdownMenuItem(value: 'm3', child: Text('m³')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _uniteMesure = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Prix d'achat HT
                    TextFormField(
                      controller: _prixAchatController,
                      decoration: const InputDecoration(
                        labelText: 'Prix d\'achat HT *',
                        border: OutlineInputBorder(),
                        suffixText: '€',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le prix d\'achat est obligatoire';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Prix invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Prix de vente HT
                    TextFormField(
                      controller: _prixVenteController,
                      decoration: const InputDecoration(
                        labelText: 'Prix de vente HT *',
                        border: OutlineInputBorder(),
                        suffixText: '€',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le prix de vente est obligatoire';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Prix invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Taux TVA
                    TextFormField(
                      controller: _tauxTvaController,
                      decoration: const InputDecoration(
                        labelText: 'Taux TVA (%)',
                        border: OutlineInputBorder(),
                        suffixText: '%',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // Stock minimum
                    TextFormField(
                      controller: _stockMinimumController,
                      decoration: const InputDecoration(
                        labelText: 'Stock minimum',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // Stock actuel
                    TextFormField(
                      controller: _stockActuelController,
                      decoration: const InputDecoration(
                        labelText: 'Stock actuel',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),

                    // Bouton Enregistrer
                    ElevatedButton(
                      onPressed: _saveArticle,
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






