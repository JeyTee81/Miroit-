import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/article_service.dart';
import '../services/categorie_service.dart';
import '../services/fournisseur_service.dart';
import '../services/mouvement_service.dart';
import '../models/article_model.dart';
import '../models/categorie_model.dart';
import '../models/fournisseur_model.dart';
import '../models/mouvement_model.dart';
import '../widgets/main_layout.dart';
import '../widgets/tab_button.dart';
import '../theme/app_theme.dart';
import 'create_article_screen.dart';
import 'create_categorie_screen.dart';
import 'create_fournisseur_screen.dart';
import 'create_mouvement_screen.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  final ArticleService _articleService = ArticleService();
  final CategorieService _categorieService = CategorieService();
  final FournisseurService _fournisseurService = FournisseurService();
  final MouvementService _mouvementService = MouvementService();
  int _selectedTab = 0; // 0: Articles, 1: Mouvements, 2: Fournisseurs, 3: Catégories
  List<Article> _articles = [];
  List<Article> _filteredArticles = [];
  List<Categorie> _categories = [];
  List<Fournisseur> _fournisseurs = [];
  List<Mouvement> _mouvements = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadArticles();
    _loadCategories();
    _loadFournisseurs();
    _loadMouvements();
    _searchController.addListener(_filterArticles);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadArticles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final articles = await _articleService.getArticles();
      setState(() {
        _articles = articles;
        _filteredArticles = articles;
        _isLoading = false;
      });
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

  Future<void> _loadCategories() async {
    try {
      final categories = await _categorieService.getCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      // Erreur silencieuse pour les catégories
    }
  }

  Future<void> _loadFournisseurs() async {
    try {
      final fournisseurs = await _fournisseurService.getFournisseurs();
      setState(() {
        _fournisseurs = fournisseurs;
      });
    } catch (e) {
      // Erreur silencieuse
    }
  }

  Future<void> _loadMouvements() async {
    try {
      final mouvements = await _mouvementService.getMouvements();
      setState(() {
        _mouvements = mouvements;
      });
    } catch (e) {
      // Erreur silencieuse
    }
  }

  void _filterArticles() {
    final query = _searchController.text.toLowerCase().trim();
    
    if (query.isEmpty) {
      setState(() {
        _filteredArticles = _articles;
      });
      return;
    }

    setState(() {
      _filteredArticles = _articles.where((article) {
        if (article.reference.toLowerCase().contains(query)) return true;
        if (article.designation.toLowerCase().contains(query)) return true;
        if (article.categorieNom != null && 
            article.categorieNom!.toLowerCase().contains(query)) return true;
        return false;
      }).toList();
    });
  }

  Future<void> _deleteArticle(Article article) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer ${article.designation} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && article.id != null) {
      try {
        await _articleService.deleteArticle(article.id!);
        _loadArticles();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Article supprimé avec succès'),
              backgroundColor: Colors.green,
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
  }

  void _navigateToCreateArticle() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateArticleScreen(),
      ),
    );

    if (result == true) {
      _loadArticles();
    }
  }

  void _navigateToEditArticle(Article article) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateArticleScreen(article: article),
      ),
    );

    if (result == true) {
      _loadArticles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentRoute: '/stock',
      title: 'Stocks',
      searchBar: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher...',
          prefixIcon: const Icon(Icons.search, color: AppTheme.textGrey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      tabs: [
        TabButton(
          label: 'Articles',
          isActive: _selectedTab == 0,
          onTap: () => setState(() => _selectedTab = 0),
        ),
        TabButton(
          label: 'Mouvements',
          isActive: _selectedTab == 1,
          onTap: () => setState(() => _selectedTab = 1),
        ),
        TabButton(
          label: 'Fournisseurs',
          isActive: _selectedTab == 2,
          onTap: () => setState(() => _selectedTab = 2),
        ),
        TabButton(
          label: 'Catégories',
          isActive: _selectedTab == 3,
          onTap: () => setState(() => _selectedTab = 3),
        ),
      ],
      child: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                _buildArticlesTab(),
                _buildMouvementsTab(),
                _buildFournisseursTab(),
                _buildCategoriesTab(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    if (_selectedTab == 0) {
                      _navigateToCreateArticle();
                    } else if (_selectedTab == 1) {
                      _navigateToCreateMouvement();
                    } else if (_selectedTab == 2) {
                      _navigateToCreateFournisseur();
                    } else if (_selectedTab == 3) {
                      _navigateToCreateCategorie();
                    }
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredArticles.isEmpty && _searchController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Aucun article',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _navigateToCreateArticle,
              child: const Text('Créer un article'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadArticles,
      child: _filteredArticles.isEmpty && _searchController.text.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun résultat pour "${_searchController.text}"',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _filteredArticles.length,
                itemBuilder: (context, index) {
                  final article = _filteredArticles[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: article.isStockFaible ? Colors.red.shade50 : null,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: article.isStockFaible
                            ? Colors.red
                            : AppTheme.primaryDark,
                        child: Text(
                          article.reference[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        article.designation,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Réf: ${article.reference}', style: const TextStyle(fontSize: 12)),
                          if (article.categorieNom != null)
                            Text('Catégorie: ${article.categorieNom}', style: const TextStyle(fontSize: 12)),
                          Text('Prix vente: ${article.prixVenteHt.toStringAsFixed(2)} € HT', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Stock: ${article.stockActuel.toStringAsFixed(2)} ${article.uniteMesure}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: article.isStockFaible
                                      ? Colors.red
                                      : Colors.black,
                                ),
                              ),
                              if (article.isStockFaible)
                                const Text(
                                  'Stock faible',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 8),
                                    Text('Modifier'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 20, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Supprimer', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _navigateToEditArticle(article);
                              } else if (value == 'delete') {
                                _deleteArticle(article);
                              }
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        _navigateToEditArticle(article);
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildMouvementsTab() {
    if (_mouvements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.swap_horiz, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Aucun mouvement',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _navigateToCreateMouvement,
              child: const Text('Créer un mouvement'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMouvements,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: _mouvements.length,
          itemBuilder: (context, index) {
            final mouvement = _mouvements[index];
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: mouvement.typeMouvementColor.withOpacity(0.1),
                  child: Icon(
                    mouvement.typeMouvement == 'entree' 
                        ? Icons.arrow_downward 
                        : mouvement.typeMouvement == 'sortie'
                            ? Icons.arrow_upward
                            : Icons.swap_horiz,
                    color: mouvement.typeMouvementColor,
                  ),
                ),
                title: Text(
                  mouvement.articleReference ?? 'Article',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${mouvement.typeMouvementLabel} - ${mouvement.quantite}'),
                    Text(DateFormat('dd/MM/yyyy').format(mouvement.dateMouvement)),
                    if (mouvement.referenceDocument != null)
                      Text('Ref: ${mouvement.referenceDocument}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (mouvement.prixUnitaireHt != null)
                      Text(
                        '${mouvement.prixUnitaireHt!.toStringAsFixed(2)} €',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    const SizedBox(width: 16),
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Modifier'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Supprimer', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _navigateToEditMouvement(mouvement);
                        } else if (value == 'delete') {
                          _deleteMouvement(mouvement);
                        }
                      },
                    ),
                  ],
                ),
                onTap: () => _navigateToEditMouvement(mouvement),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFournisseursTab() {
    if (_fournisseurs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.business, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Aucun fournisseur',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _navigateToCreateFournisseur,
              child: const Text('Créer un fournisseur'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFournisseurs,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: _fournisseurs.length,
          itemBuilder: (context, index) {
            final fournisseur = _fournisseurs[index];
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: fournisseur.actif 
                      ? AppTheme.primaryDark 
                      : Colors.grey,
                  child: Text(
                    fournisseur.raisonSociale[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  fournisseur.raisonSociale,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fournisseur.adresseComplete),
                    if (fournisseur.telephone != null)
                      Text('Tel: ${fournisseur.telephone}'),
                    if (fournisseur.email != null)
                      Text('Email: ${fournisseur.email}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!fournisseur.actif)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Inactif',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    const SizedBox(width: 16),
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Modifier'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Supprimer', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _navigateToEditFournisseur(fournisseur);
                        } else if (value == 'delete') {
                          _deleteFournisseur(fournisseur);
                        }
                      },
                    ),
                  ],
                ),
                onTap: () => _navigateToEditFournisseur(fournisseur),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoriesTab() {
    if (_categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.category, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Aucune catégorie',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _navigateToCreateCategorie,
              child: const Text('Créer une catégorie'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCategories,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final categorie = _categories[index];
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: ListTile(
                leading: const Icon(Icons.category, color: AppTheme.primaryDark),
                title: Text(
                  categorie.nom,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: categorie.description != null
                    ? Text(categorie.description!)
                    : null,
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Modifier'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Supprimer', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _navigateToEditCategorie(categorie);
                    } else if (value == 'delete') {
                      _deleteCategorie(categorie);
                    }
                  },
                ),
                onTap: () => _navigateToEditCategorie(categorie),
              ),
            );
          },
        ),
      ),
    );
  }

  void _navigateToCreateCategorie() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateCategorieScreen(),
      ),
    );

    if (result == true) {
      _loadCategories();
    }
  }

  void _navigateToEditCategorie(Categorie categorie) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateCategorieScreen(categorie: categorie),
      ),
    );

    if (result == true) {
      _loadCategories();
    }
  }

  void _navigateToCreateFournisseur() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateFournisseurScreen(),
      ),
    );

    if (result == true) {
      _loadFournisseurs();
    }
  }

  void _navigateToEditFournisseur(Fournisseur fournisseur) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateFournisseurScreen(fournisseur: fournisseur),
      ),
    );

    if (result == true) {
      _loadFournisseurs();
    }
  }

  void _navigateToCreateMouvement() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateMouvementScreen(),
      ),
    );

    if (result == true) {
      _loadMouvements();
      _loadArticles(); // Recharger pour mettre à jour les stocks
    }
  }

  void _navigateToEditMouvement(Mouvement mouvement) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateMouvementScreen(mouvement: mouvement),
      ),
    );

    if (result == true) {
      _loadMouvements();
      _loadArticles(); // Recharger pour mettre à jour les stocks
    }
  }

  Future<void> _deleteCategorie(Categorie categorie) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer la catégorie "${categorie.nom}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && categorie.id != null) {
      try {
        await _categorieService.deleteCategorie(categorie.id!);
        _loadCategories();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Catégorie supprimée avec succès'),
              backgroundColor: Colors.green,
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
  }

  Future<void> _deleteFournisseur(Fournisseur fournisseur) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${fournisseur.raisonSociale}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && fournisseur.id != null) {
      try {
        await _fournisseurService.deleteFournisseur(fournisseur.id!);
        _loadFournisseurs();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fournisseur supprimé avec succès'),
              backgroundColor: Colors.green,
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
  }

  Future<void> _deleteMouvement(Mouvement mouvement) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer ce mouvement ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mouvement.id != null) {
      try {
        await _mouvementService.deleteMouvement(mouvement.id!);
        _loadMouvements();
        _loadArticles(); // Recharger pour mettre à jour les stocks
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mouvement supprimé avec succès'),
              backgroundColor: Colors.green,
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
  }
}

