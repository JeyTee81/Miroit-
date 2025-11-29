import 'package:flutter/material.dart';
import '../models/menuiserie/article_model.dart';
import '../models/menuiserie/projet_model.dart';
import '../models/menuiserie/option_menuiserie_model.dart';
import '../services/menuiserie_service.dart';
import '../widgets/menuiserie/dessin_visualization.dart';

class CreateArticleMenuiserieScreen extends StatefulWidget {
  final Article? article;

  const CreateArticleMenuiserieScreen({super.key, this.article});

  @override
  State<CreateArticleMenuiserieScreen> createState() => _CreateArticleMenuiserieScreenState();
}

class _CreateArticleMenuiserieScreenState extends State<CreateArticleMenuiserieScreen> {
  final _formKey = GlobalKey<FormState>();
  final _menuiserieService = MenuiserieService();
  bool _isLoading = false;
  bool _isSaving = false;

  List<Projet> _projets = [];
  Projet? _selectedProjet;
  
  // Données de base
  final _designationBaseController = TextEditingController();
  String _typeArticle = 'fenetre';
  final _largeurController = TextEditingController();
  final _hauteurController = TextEditingController();
  final _profondeurController = TextEditingController();
  final _quantiteController = TextEditingController(text: '1');
  final _echelleController = TextEditingController(text: '1:1');
  
  // Tarif fournisseur
  List<Map<String, dynamic>> _tarifsFournisseurs = [];
  String? _selectedTarifId;
  double? _prixBaseHt;
  final _prixBaseController = TextEditingController();
  
  // Options
  List<OptionMenuiserie> _optionsObligatoires = [];
  List<OptionMenuiserie> _optionsFacultatives = [];
  List<String> _selectedOptionsObligatoires = [];
  List<String> _selectedOptionsFacultatives = [];
  
  // Résultats calculés
  String _designationGeneree = '';
  double? _prixCalcule;

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.article != null) {
      _loadArticleData();
    }
  }

  @override
  void dispose() {
    _designationBaseController.dispose();
    _largeurController.dispose();
    _hauteurController.dispose();
    _profondeurController.dispose();
    _quantiteController.dispose();
    _echelleController.dispose();
    _prixBaseController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _loadProjets(),
        _loadTarifsFournisseurs(),
        _loadOptions(),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadProjets() async {
    final projets = await _menuiserieService.getProjets();
    setState(() {
      _projets = projets;
      if (widget.article?.projetId != null && projets.isNotEmpty) {
        try {
          _selectedProjet = projets.firstWhere(
            (p) => p.id == widget.article!.projetId,
          );
        } catch (e) {
          if (projets.isNotEmpty) {
            _selectedProjet = projets.first;
          }
        }
      }
    });
  }

  Future<void> _loadTarifsFournisseurs() async {
    final tarifs = await _menuiserieService.getTarifsFournisseurs();
    setState(() {
      _tarifsFournisseurs = tarifs;
    });
  }

  Future<void> _loadOptions() async {
    final options = await _menuiserieService.getOptions(typeArticle: _typeArticle);
    setState(() {
      _optionsObligatoires = options.where((o) => o.typeOption == 'obligatoire').toList();
      _optionsFacultatives = options.where((o) => o.typeOption == 'facultatif').toList();
    });
  }

  void _loadArticleData() {
    final article = widget.article!;
    _designationBaseController.text = article.designationBase ?? article.designation;
    _typeArticle = article.typeArticle;
    _largeurController.text = article.largeur.toString();
    _hauteurController.text = article.hauteur.toString();
    if (article.profondeur != null) {
      _profondeurController.text = article.profondeur!.toString();
    }
    _quantiteController.text = article.quantite.toString();
    _echelleController.text = article.echelleDessin ?? '1:1';
    _selectedTarifId = article.tarifFournisseurId;
    _prixBaseHt = article.prixBaseHt;
    if (_prixBaseHt != null) {
      _prixBaseController.text = _prixBaseHt!.toStringAsFixed(2);
    }
    _selectedOptionsObligatoires = article.optionsObligatoires ?? [];
    _selectedOptionsFacultatives = article.optionsFacultatives ?? [];
    _designationGeneree = article.designationGeneree ?? article.designation;
    _prixCalcule = article.prixCalcule ?? article.prixUnitaireHt;
  }

  Future<void> _updateCalculs() async {
    if (_largeurController.text.isEmpty || _hauteurController.text.isEmpty) {
      return;
    }

    try {
      final largeur = double.tryParse(_largeurController.text) ?? 0;
      final hauteur = double.tryParse(_hauteurController.text) ?? 0;

      // Générer la désignation
      final designation = await _menuiserieService.genererDesignation(
        designationBase: _designationBaseController.text.isEmpty 
            ? null 
            : _designationBaseController.text,
        typeArticle: _typeArticle,
        largeur: largeur,
        hauteur: hauteur,
        optionsObligatoires: _selectedOptionsObligatoires,
        optionsFacultatives: _selectedOptionsFacultatives,
      );

      // Calculer le prix
      double? prixCalcule;
      if (_selectedTarifId != null || _prixBaseHt != null) {
        prixCalcule = await _menuiserieService.calculerPrix(
          tarifFournisseurId: _selectedTarifId,
          prixBaseHt: _prixBaseHt,
          largeur: largeur,
          hauteur: hauteur,
          optionsObligatoires: _selectedOptionsObligatoires,
          optionsFacultatives: _selectedOptionsFacultatives,
        );
      }

      setState(() {
        _designationGeneree = designation;
        _prixCalcule = prixCalcule;
      });
    } catch (e) {
      // Ignorer les erreurs de calcul pour ne pas bloquer l'interface
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProjet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un projet'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final largeur = double.parse(_largeurController.text);
      final hauteur = double.parse(_hauteurController.text);
      final prixFinal = _prixCalcule ?? double.parse(_prixBaseController.text);

      final article = Article(
        id: widget.article?.id,
        projetId: _selectedProjet!.id!,
        designation: _designationGeneree.isNotEmpty 
            ? _designationGeneree 
            : _designationBaseController.text,
        designationBase: _designationBaseController.text.isEmpty 
            ? null 
            : _designationBaseController.text,
        typeArticle: _typeArticle,
        largeur: largeur,
        hauteur: hauteur,
        profondeur: _profondeurController.text.isEmpty 
            ? null 
            : double.tryParse(_profondeurController.text),
        quantite: int.parse(_quantiteController.text),
        prixUnitaireHt: prixFinal,
        prixBaseHt: _prixBaseHt,
        echelleDessin: _echelleController.text,
        optionsObligatoires: _selectedOptionsObligatoires.isEmpty 
            ? null 
            : _selectedOptionsObligatoires,
        optionsFacultatives: _selectedOptionsFacultatives.isEmpty 
            ? null 
            : _selectedOptionsFacultatives,
        tarifFournisseurId: _selectedTarifId,
      );

      if (widget.article?.id != null) {
        await _menuiserieService.updateArticle(widget.article!.id!, article);
      } else {
        await _menuiserieService.createArticle(article);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.article != null 
                ? 'Article modifié avec succès' 
                : 'Article créé avec succès'),
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
        title: Text(widget.article != null ? 'Modifier l\'article' : 'Nouvel article'),
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
                    // Projet
                    DropdownButtonFormField<Projet>(
                      value: _selectedProjet,
                      decoration: const InputDecoration(
                        labelText: 'Projet *',
                        border: OutlineInputBorder(),
                      ),
                      items: _projets.map((projet) => DropdownMenuItem(
                        value: projet,
                        child: Text('${projet.numeroProjet ?? projet.id} - ${projet.nom}'),
                      )).toList(),
                      onChanged: (projet) => setState(() => _selectedProjet = projet),
                      validator: (value) => value == null ? 'Requis' : null,
                    ),
                    const SizedBox(height: 16),

                    // Type d'article
                    DropdownButtonFormField<String>(
                      value: _typeArticle,
                      decoration: const InputDecoration(
                        labelText: 'Type d\'article *',
                        border: OutlineInputBorder(),
                      ),
                      items: Article.typeArticleOptions.map((type) {
                        final article = Article(
                          typeArticle: type,
                          projetId: '',
                          designation: '',
                          largeur: 0,
                          hauteur: 0,
                          prixUnitaireHt: 0,
                        );
                        return DropdownMenuItem(
                          value: type,
                          child: Text(article.typeArticleLabel),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _typeArticle = value!;
                          _selectedOptionsObligatoires.clear();
                          _selectedOptionsFacultatives.clear();
                        });
                        _loadOptions();
                        _updateCalculs();
                      },
                    ),
                    const SizedBox(height: 16),

                    // Dimensions
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _largeurController,
                            decoration: const InputDecoration(
                              labelText: 'Largeur (cm) *',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Requis';
                              if (double.tryParse(value) == null) return 'Nombre invalide';
                              return null;
                            },
                            onChanged: (_) => _updateCalculs(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _hauteurController,
                            decoration: const InputDecoration(
                              labelText: 'Hauteur (cm) *',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Requis';
                              if (double.tryParse(value) == null) return 'Nombre invalide';
                              return null;
                            },
                            onChanged: (_) => _updateCalculs(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Profondeur et quantité
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _profondeurController,
                            decoration: const InputDecoration(
                              labelText: 'Profondeur (cm)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (_) => _updateCalculs(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _quantiteController,
                            decoration: const InputDecoration(
                              labelText: 'Quantité *',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Requis';
                              if (int.tryParse(value) == null) return 'Nombre invalide';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Section Tarif Fournisseur
                    const Text(
                      'Tarif Fournisseur',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedTarifId,
                      decoration: const InputDecoration(
                        labelText: 'Tarif fournisseur',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Aucun')),
                        ..._tarifsFournisseurs.map((tarif) => DropdownMenuItem(
                          value: tarif['id']?.toString(),
                          child: Text('${tarif['fournisseur_nom']} - ${tarif['designation']} (${tarif['prix_unitaire_ht']} €/${tarif['unite']})'),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedTarifId = value;
                          _prixBaseHt = null;
                          _prixBaseController.clear();
                        });
                        _updateCalculs();
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _prixBaseController,
                            decoration: const InputDecoration(
                              labelText: 'Prix de base HT (€)',
                              border: OutlineInputBorder(),
                              hintText: 'Si pas de tarif fournisseur',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                _prixBaseHt = value.isEmpty ? null : double.tryParse(value);
                              });
                              _updateCalculs();
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (_prixCalcule != null)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Prix calculé HT',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  Text(
                                    '${_prixCalcule!.toStringAsFixed(2)} €',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Section Options Obligatoires
                    const Text(
                      'Options Obligatoires',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (_optionsObligatoires.isEmpty)
                      const Text('Aucune option obligatoire disponible', style: TextStyle(color: Colors.grey))
                    else
                      ..._optionsObligatoires.map((option) => CheckboxListTile(
                        title: Text(option.libelle),
                        subtitle: option.ajoutDesignation != null
                            ? Text(option.ajoutDesignation!)
                            : null,
                        secondary: option.impactPrixType != 'aucun'
                            ? Text(
                                option.impactPrixLabel,
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                              )
                            : null,
                        value: _selectedOptionsObligatoires.contains(option.id),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _selectedOptionsObligatoires.add(option.id!);
                            } else {
                              _selectedOptionsObligatoires.remove(option.id);
                            }
                          });
                          _updateCalculs();
                        },
                      )),
                    const SizedBox(height: 24),

                    // Section Options Facultatives
                    const Text(
                      'Options Facultatives',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (_optionsFacultatives.isEmpty)
                      const Text('Aucune option facultative disponible', style: TextStyle(color: Colors.grey))
                    else
                      ..._optionsFacultatives.map((option) => CheckboxListTile(
                        title: Text(option.libelle),
                        subtitle: option.ajoutDesignation != null
                            ? Text(option.ajoutDesignation!)
                            : null,
                        secondary: option.impactPrixType != 'aucun'
                            ? Text(
                                option.impactPrixLabel,
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                              )
                            : null,
                        value: _selectedOptionsFacultatives.contains(option.id),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _selectedOptionsFacultatives.add(option.id!);
                            } else {
                              _selectedOptionsFacultatives.remove(option.id);
                            }
                          });
                          _updateCalculs();
                        },
                      )),
                    const SizedBox(height: 24),

                    // Désignation générée
                    if (_designationGeneree.isNotEmpty) ...[
                      const Text(
                        'Désignation générée',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Text(
                          _designationGeneree,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Échelle du dessin
                    TextFormField(
                      controller: _echelleController,
                      decoration: const InputDecoration(
                        labelText: 'Échelle du dessin',
                        border: OutlineInputBorder(),
                        hintText: 'Ex: 1:1, 1:10, 1:50',
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Visualisation du dessin
                    if (_largeurController.text.isNotEmpty && _hauteurController.text.isNotEmpty)
                      DessinVisualization(
                        largeur: double.tryParse(_largeurController.text) ?? 0,
                        hauteur: double.tryParse(_hauteurController.text) ?? 0,
                        echelle: _echelleController.text,
                        optionsObligatoires: _selectedOptionsObligatoires,
                        optionsFacultatives: _selectedOptionsFacultatives,
                        optionsDetails: [..._optionsObligatoires, ..._optionsFacultatives],
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
                                : Text(widget.article != null ? 'Modifier' : 'Créer'),
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
