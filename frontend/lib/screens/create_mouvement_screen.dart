import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mouvement_model.dart';
import '../models/article_model.dart';
import '../models/chantier_model.dart';
import '../services/mouvement_service.dart';
import '../services/article_service.dart';
import '../services/chantier_service.dart';

class CreateMouvementScreen extends StatefulWidget {
  final Mouvement? mouvement;

  const CreateMouvementScreen({super.key, this.mouvement});

  @override
  State<CreateMouvementScreen> createState() => _CreateMouvementScreenState();
}

class _CreateMouvementScreenState extends State<CreateMouvementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mouvementService = MouvementService();
  final _articleService = ArticleService();
  final _chantierService = ChantierService();
  bool _isSaving = false;
  bool _isLoading = false;

  List<Article> _articles = [];
  List<Chantier> _chantiers = [];
  Article? _selectedArticle;
  Chantier? _selectedChantier;
  String _typeMouvement = 'entree';
  final _quantiteController = TextEditingController();
  final _prixUnitaireController = TextEditingController();
  DateTime _dateMouvement = DateTime.now();
  final _referenceDocumentController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.mouvement != null) {
      _loadMouvementData();
    }
  }

  @override
  void dispose() {
    _quantiteController.dispose();
    _prixUnitaireController.dispose();
    _referenceDocumentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _loadArticles(),
        _loadChantiers(),
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

  Future<void> _loadArticles() async {
    final articles = await _articleService.getArticles();
    setState(() {
      _articles = articles;
      if (widget.mouvement?.articleId != null && articles.isNotEmpty) {
        try {
          _selectedArticle = articles.firstWhere(
            (a) => a.id == widget.mouvement!.articleId,
          );
        } catch (e) {
          // Article introuvable
        }
      }
    });
  }

  Future<void> _loadChantiers() async {
    final chantiers = await _chantierService.getChantiers();
    setState(() {
      _chantiers = chantiers;
      if (widget.mouvement?.chantierId != null && chantiers.isNotEmpty) {
        try {
          _selectedChantier = chantiers.firstWhere(
            (c) => c.id == widget.mouvement!.chantierId,
          );
        } catch (e) {
          // Chantier introuvable
        }
      }
    });
  }

  void _loadMouvementData() {
    final mouvement = widget.mouvement!;
    _typeMouvement = mouvement.typeMouvement;
    _quantiteController.text = mouvement.quantite.toString();
    if (mouvement.prixUnitaireHt != null) {
      _prixUnitaireController.text = mouvement.prixUnitaireHt!.toStringAsFixed(2);
    }
    _dateMouvement = mouvement.dateMouvement;
    _referenceDocumentController.text = mouvement.referenceDocument ?? '';
    _notesController.text = mouvement.notes ?? '';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateMouvement,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dateMouvement = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedArticle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un article'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final mouvement = Mouvement(
        id: widget.mouvement?.id,
        articleId: _selectedArticle!.id!,
        typeMouvement: _typeMouvement,
        quantite: double.parse(_quantiteController.text),
        prixUnitaireHt: _prixUnitaireController.text.isEmpty 
            ? null 
            : double.tryParse(_prixUnitaireController.text),
        dateMouvement: _dateMouvement,
        referenceDocument: _referenceDocumentController.text.trim().isEmpty 
            ? null 
            : _referenceDocumentController.text.trim(),
        chantierId: _selectedChantier?.id,
        notes: _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim(),
      );

      if (widget.mouvement?.id != null) {
        await _mouvementService.updateMouvement(widget.mouvement!.id!, mouvement);
      } else {
        await _mouvementService.createMouvement(mouvement);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.mouvement != null 
                ? 'Mouvement modifié avec succès' 
                : 'Mouvement créé avec succès'),
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
        title: Text(widget.mouvement != null ? 'Modifier le mouvement' : 'Nouveau mouvement'),
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
                    DropdownButtonFormField<Article>(
                      value: _selectedArticle,
                      decoration: const InputDecoration(
                        labelText: 'Article *',
                        border: OutlineInputBorder(),
                      ),
                      items: _articles.map((article) => DropdownMenuItem(
                        value: article,
                        child: Text('${article.reference} - ${article.designation}'),
                      )).toList(),
                      onChanged: (article) => setState(() => _selectedArticle = article),
                      validator: (value) => value == null ? 'Requis' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _typeMouvement,
                      decoration: const InputDecoration(
                        labelText: 'Type de mouvement *',
                        border: OutlineInputBorder(),
                      ),
                      items: Mouvement.typeMouvementOptions.map((type) {
                        final mouvement = Mouvement(
                          articleId: '',
                          typeMouvement: type,
                          quantite: 0,
                          dateMouvement: DateTime.now(),
                        );
                        return DropdownMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: mouvement.typeMouvementColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(mouvement.typeMouvementLabel),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _typeMouvement = value!),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
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
                              if (double.tryParse(value) == null) return 'Nombre invalide';
                              if (double.parse(value) <= 0) return 'Doit être > 0';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _prixUnitaireController,
                            decoration: const InputDecoration(
                              labelText: 'Prix unitaire HT (€)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date du mouvement *',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(DateFormat('dd/MM/yyyy').format(_dateMouvement)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _referenceDocumentController,
                      decoration: const InputDecoration(
                        labelText: 'Référence document',
                        border: OutlineInputBorder(),
                        hintText: 'Ex: BL-2024-001, Facture...',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Chantier>(
                      value: _selectedChantier,
                      decoration: const InputDecoration(
                        labelText: 'Chantier (optionnel)',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<Chantier>(
                          value: null,
                          child: Text('Aucun'),
                        ),
                        ..._chantiers.map((chantier) => DropdownMenuItem(
                          value: chantier,
                          child: Text('${chantier.nom} - ${chantier.clientNom ?? ''}'),
                        )),
                      ],
                      onChanged: (chantier) => setState(() => _selectedChantier = chantier),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
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
                                : Text(widget.mouvement != null ? 'Modifier' : 'Créer'),
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




