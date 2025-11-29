import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/devis_model.dart';
import '../models/client_model.dart';
import '../models/article_model.dart';
import '../services/devis_service.dart';
import '../services/client_service.dart';
import '../services/article_service.dart';
import '../services/print_service.dart';
import '../pdf_generators/devis_pdf_generator.dart';

class CreateDevisScreen extends StatefulWidget {
  final Devis? devis; // Si fourni, on est en mode édition

  const CreateDevisScreen({super.key, this.devis});

  @override
  State<CreateDevisScreen> createState() => _CreateDevisScreenState();
}

class _CreateDevisScreenState extends State<CreateDevisScreen> {
  final _formKey = GlobalKey<FormState>();
  final _devisService = DevisService();
  final _clientService = ClientService();
  final _articleService = ArticleService();
  final _printService = PrintService();
  bool _isLoading = false;

  List<Client> _clients = [];
  Client? _selectedClient;
  List<Article> _articles = [];
  DateTime _dateValidite = DateTime.now().add(const Duration(days: 30));
  final _remiseController = TextEditingController(text: '0');
  final _notesController = TextEditingController();
  List<LigneDevis> _lignes = [];

  @override
  void initState() {
    super.initState();
    _loadClients();
    _loadArticles();
    if (widget.devis != null) {
      _selectedClient = widget.devis!.client;
      _dateValidite = widget.devis!.dateValidite;
      _remiseController.text = widget.devis!.remisePourcentage.toString();
      _notesController.text = widget.devis!.notes ?? '';
      _lignes = widget.devis!.lignes ?? [];
    }
  }

  @override
  void dispose() {
    _remiseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadClients() async {
    try {
      final clients = await _clientService.getClients();
      setState(() {
        _clients = clients;
        if (widget.devis?.clientId != null) {
          _selectedClient = clients.firstWhere(
            (c) => c.id == widget.devis!.clientId,
            orElse: () => clients.first,
          );
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

  Future<void> _loadArticles() async {
    try {
      final articles = await _articleService.getArticles();
      setState(() {
        _articles = articles;
      });
    } catch (e) {
      // Erreur silencieuse
    }
  }

  void _addLigne() {
    setState(() {
      _lignes.add(LigneDevis(
        designation: '',
        quantite: 1,
        prixUnitaireHt: 0,
        ordre: _lignes.length,
      ));
    });
  }

  void _addLigneFromArticle(Article article) {
    setState(() {
      _lignes.add(LigneDevis(
        articleId: article.id,
        designation: article.designation,
        quantite: 1,
        prixUnitaireHt: article.prixVenteHt,
        tauxTva: article.tauxTva,
        ordre: _lignes.length,
      ));
    });
  }

  Future<void> _selectArticleForLigne(int index) async {
    final article = await showDialog<Article>(
      context: context,
      builder: (context) => _ArticleSelectionDialog(articles: _articles),
    );

    if (article != null) {
      setState(() {
        final ligne = _lignes[index];
        _lignes[index] = LigneDevis(
          id: ligne.id,
          articleId: article.id,
          designation: article.designation,
          quantite: ligne.quantite,
          prixUnitaireHt: article.prixVenteHt,
          tauxTva: article.tauxTva,
          remisePourcentage: ligne.remisePourcentage,
          ordre: index,
        );
      });
    }
  }

  void _removeLigne(int index) {
    setState(() {
      _lignes.removeAt(index);
      // Réorganiser les ordres
      for (int i = 0; i < _lignes.length; i++) {
        _lignes[i] = LigneDevis(
          id: _lignes[i].id,
          articleId: _lignes[i].articleId,
          designation: _lignes[i].designation,
          quantite: _lignes[i].quantite,
          prixUnitaireHt: _lignes[i].prixUnitaireHt,
          tauxTva: _lignes[i].tauxTva,
          remisePourcentage: _lignes[i].remisePourcentage,
          ordre: i,
        );
      }
    });
  }

  void _updateLigne(int index, LigneDevis ligne) {
    setState(() {
      _lignes[index] = ligne;
    });
  }

  double _calculateTotalHt() {
    double total = 0;
    for (var ligne in _lignes) {
      total += ligne.montantHt;
    }
    final remise = double.tryParse(_remiseController.text) ?? 0;
    return total * (1 - remise / 100);
  }

  double _calculateTotalTtc() {
    double totalHt = _calculateTotalHt();
    double totalTva = 0;
    for (var ligne in _lignes) {
      totalTva += ligne.montantTva;
    }
    return totalHt + totalTva;
  }

  Future<void> _saveDevis() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un client'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_lignes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez ajouter au moins une ligne'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final devis = Devis(
        id: widget.devis?.id,
        numeroDevis: widget.devis?.numeroDevis,
        clientId: _selectedClient!.id,
        dateValidite: _dateValidite,
        montantHt: _calculateTotalHt(),
        montantTtc: _calculateTotalTtc(),
        statut: widget.devis?.statut ?? 'brouillon',
        remisePourcentage: double.tryParse(_remiseController.text) ?? 0,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        lignes: _lignes,
      );

      if (widget.devis != null) {
        await _devisService.updateDevis(devis);
      } else {
        await _devisService.createDevis(devis);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.devis != null
                ? 'Devis modifié avec succès'
                : 'Devis créé avec succès'),
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

  Future<void> _imprimerDevis() async {
    if (widget.devis == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez d\'abord sauvegarder le devis'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Charger le devis complet avec le client
      final devisComplet = await _devisService.getDevisById(widget.devis!.id!);
      Client? client;
      if (devisComplet.clientId != null) {
        try {
          client = await _clientService.getClient(devisComplet.clientId!);
        } catch (e) {
          // Client non trouvé, continuer sans
        }
      }

      // Générer le PDF
      final pdfDoc = DevisPdfGenerator.generateDevis(devisComplet, client: client);

      // Imprimer
      final success = await _printService.imprimerAvecSelection(pdfDoc);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Impression lancée' : 'Erreur lors de l\'impression'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.devis != null ? 'Modifier le devis' : 'Nouveau devis'),
        actions: [
          if (widget.devis != null)
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: _imprimerDevis,
              tooltip: 'Imprimer le devis',
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDevis,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Client
                          DropdownButtonFormField<Client>(
                            value: _selectedClient,
                            decoration: const InputDecoration(
                              labelText: 'Client *',
                              border: OutlineInputBorder(),
                            ),
                            items: _clients.map((client) {
                              return DropdownMenuItem(
                                value: client,
                                child: Text(client.displayName),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedClient = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Veuillez sélectionner un client';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Date de validité
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _dateValidite,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (date != null) {
                                setState(() {
                                  _dateValidite = date;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Date de validité *',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                DateFormat('dd/MM/yyyy').format(_dateValidite),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Remise globale
                          TextFormField(
                            controller: _remiseController,
                            decoration: const InputDecoration(
                              labelText: 'Remise globale (%)',
                              border: OutlineInputBorder(),
                              suffixText: '%',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final remise = double.tryParse(value);
                                if (remise == null || remise < 0 || remise > 100) {
                                  return 'Remise invalide (0-100)';
                                }
                              }
                              return null;
                            },
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

                          // Lignes de devis
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Lignes de devis',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final article = await showDialog<Article>(
                                        context: context,
                                        builder: (context) => _ArticleSelectionDialog(articles: _articles),
                                      );
                                      if (article != null) {
                                        _addLigneFromArticle(article);
                                      }
                                    },
                                    icon: const Icon(Icons.inventory),
                                    label: const Text('Du stock'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: _addLigne,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Manuelle'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          if (_lignes.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Text(
                                  'Aucune ligne. Cliquez sur "Du stock" pour sélectionner un article ou "Manuelle" pour saisir manuellement.',
                                  style: TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          else
                            ..._lignes.asMap().entries.map((entry) {
                              final index = entry.key;
                              final ligne = entry.value;
                              return _buildLigneCard(index, ligne);
                            }),

                          const SizedBox(height: 16),

                          // Totaux
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Total HT:'),
                                      Text(
                                        '${_calculateTotalHt().toStringAsFixed(2)} €',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('TVA:'),
                                      Text(
                                        '${(_calculateTotalTtc() - _calculateTotalHt()).toStringAsFixed(2)} €',
                                      ),
                                    ],
                                  ),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total TTC:',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${_calculateTotalTtc().toStringAsFixed(2)} €',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLigneCard(int index, LigneDevis ligne) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Ligne ${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeLigne(index),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: ligne.designation,
                    decoration: InputDecoration(
                      labelText: 'Désignation *',
                      border: const OutlineInputBorder(),
                      suffixIcon: ligne.articleId == null
                          ? IconButton(
                              icon: const Icon(Icons.search),
                              tooltip: 'Sélectionner depuis le stock',
                              onPressed: () => _selectArticleForLigne(index),
                            )
                          : const Icon(Icons.check_circle, color: Colors.green),
                    ),
                    onChanged: (value) {
                      _updateLigne(
                        index,
                        LigneDevis(
                          id: ligne.id,
                          articleId: ligne.articleId,
                          designation: value,
                          quantite: ligne.quantite,
                          prixUnitaireHt: ligne.prixUnitaireHt,
                          tauxTva: ligne.tauxTva,
                          remisePourcentage: ligne.remisePourcentage,
                          ordre: index,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: ligne.quantite.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Quantité *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final qty = double.tryParse(value) ?? 0;
                      _updateLigne(
                        index,
                        LigneDevis(
                          id: ligne.id,
                          articleId: ligne.articleId,
                          designation: ligne.designation,
                          quantite: qty,
                          prixUnitaireHt: ligne.prixUnitaireHt,
                          tauxTva: ligne.tauxTva,
                          remisePourcentage: ligne.remisePourcentage,
                          ordre: index,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: ligne.prixUnitaireHt.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Prix unitaire HT *',
                      border: OutlineInputBorder(),
                      suffixText: '€',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final prix = double.tryParse(value) ?? 0;
                      _updateLigne(
                        index,
                        LigneDevis(
                          id: ligne.id,
                          articleId: ligne.articleId,
                          designation: ligne.designation,
                          quantite: ligne.quantite,
                          prixUnitaireHt: prix,
                          tauxTva: ligne.tauxTva,
                          remisePourcentage: ligne.remisePourcentage,
                          ordre: index,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: ligne.tauxTva.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Taux TVA (%)',
                      border: OutlineInputBorder(),
                      suffixText: '%',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final tva = double.tryParse(value) ?? 20;
                      _updateLigne(
                        index,
                        LigneDevis(
                          id: ligne.id,
                          articleId: ligne.articleId,
                          designation: ligne.designation,
                          quantite: ligne.quantite,
                          prixUnitaireHt: ligne.prixUnitaireHt,
                          tauxTva: tva,
                          remisePourcentage: ligne.remisePourcentage,
                          ordre: index,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: ligne.remisePourcentage.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Remise (%)',
                      border: OutlineInputBorder(),
                      suffixText: '%',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final remise = double.tryParse(value) ?? 0;
                      _updateLigne(
                        index,
                        LigneDevis(
                          id: ligne.id,
                          articleId: ligne.articleId,
                          designation: ligne.designation,
                          quantite: ligne.quantite,
                          prixUnitaireHt: ligne.prixUnitaireHt,
                          tauxTva: ligne.tauxTva,
                          remisePourcentage: remise,
                          ordre: index,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total ligne:'),
                  Text(
                    '${ligne.montantTtc.toStringAsFixed(2)} € TTC',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleSelectionDialog extends StatefulWidget {
  final List<Article> articles;

  const _ArticleSelectionDialog({required this.articles});

  @override
  State<_ArticleSelectionDialog> createState() => _ArticleSelectionDialogState();
}

class _ArticleSelectionDialogState extends State<_ArticleSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Article> _filteredArticles = [];

  @override
  void initState() {
    super.initState();
    _filteredArticles = widget.articles;
    _searchController.addListener(_filterArticles);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterArticles() {
    final query = _searchController.text.toLowerCase().trim();
    
    if (query.isEmpty) {
      setState(() {
        _filteredArticles = widget.articles;
      });
      return;
    }

    setState(() {
      _filteredArticles = widget.articles.where((article) {
        if (article.reference.toLowerCase().contains(query)) return true;
        if (article.designation.toLowerCase().contains(query)) return true;
        return false;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        height: 600,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Titre et barre de recherche
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Sélectionner un article',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un article...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Liste des articles
            Expanded(
              child: _filteredArticles.isEmpty
                  ? const Center(child: Text('Aucun article trouvé'))
                  : ListView.builder(
                      itemCount: _filteredArticles.length,
                      itemBuilder: (context, index) {
                        final article = _filteredArticles[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(article.reference[0].toUpperCase()),
                            ),
                            title: Text(
                              article.designation,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Réf: ${article.reference}'),
                                if (article.categorieNom != null)
                                  Text('Catégorie: ${article.categorieNom}'),
                                Text(
                                  'Prix: ${article.prixVenteHt.toStringAsFixed(2)} € HT',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_forward),
                            onTap: () {
                              Navigator.pop(context, article);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
