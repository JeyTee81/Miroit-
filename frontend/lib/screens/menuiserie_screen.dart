import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/menuiserie_service.dart';
import '../models/menuiserie/projet_model.dart';
import '../models/menuiserie/article_model.dart';
import '../widgets/main_layout.dart';
import '../widgets/tab_button.dart';
import '../theme/app_theme.dart';
import 'create_projet_screen.dart';
import 'create_article_menuiserie_screen.dart';

class MenuiserieScreen extends StatefulWidget {
  const MenuiserieScreen({super.key});

  @override
  State<MenuiserieScreen> createState() => _MenuiserieScreenState();
}

class _MenuiserieScreenState extends State<MenuiserieScreen> {
  final MenuiserieService _menuiserieService = MenuiserieService();
  int _selectedTab = 0; // 0: Projets, 1: Articles
  List<Projet> _projets = [];
  List<Article> _articles = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProjets();
    _loadArticles();
    _searchController.addListener(_filterProjets);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProjets() {
    // Filtrage côté client si nécessaire
  }

  Future<void> _loadProjets() async {
    setState(() => _isLoading = true);
    try {
      final projets = await _menuiserieService.getProjets();
      setState(() {
        _projets = projets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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

  Future<void> _loadArticles() async {
    try {
      final articles = await _menuiserieService.getArticles();
      setState(() {
        _articles = articles;
      });
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
    return MainLayout(
      currentRoute: '/menuiserie',
      title: 'Menuiserie',
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
          label: 'Projets',
          isActive: _selectedTab == 0,
          onTap: () => setState(() => _selectedTab = 0),
        ),
        TabButton(
          label: 'Articles',
          isActive: _selectedTab == 1,
          onTap: () => setState(() => _selectedTab = 1),
        ),
      ],
      child: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                _buildProjetsTab(),
                _buildArticlesTab(),
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
                      _navigateToCreateProjet();
                    } else if (_selectedTab == 1) {
                      _navigateToCreateArticle();
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

  Widget _buildProjetsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_projets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Aucun projet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _navigateToCreateProjet,
              child: const Text('Créer un projet'),
            ),
          ],
        ),
      );
    }

    final sortedProjets = List<Projet>.from(_projets)
      ..sort((a, b) {
        if (a.dateCreation == null || b.dateCreation == null) return 0;
        return b.dateCreation!.compareTo(a.dateCreation!);
      });

    return RefreshIndicator(
      onRefresh: _loadProjets,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: sortedProjets.length,
          itemBuilder: (context, index) {
            final projet = sortedProjets[index];
            return _buildProjetTableRow(projet);
          },
        ),
      ),
    );
  }

  Widget _buildProjetTableRow(Projet projet) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: projet.statutColor.withOpacity(0.1),
          child: Icon(
            Icons.construction,
            color: projet.statutColor,
          ),
        ),
        title: Text(
          projet.nom,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (projet.numeroProjet != null)
              Text('${projet.numeroProjet}', style: const TextStyle(fontSize: 12)),
            if (projet.devisNumero != null)
              Text('Devis: ${projet.devisNumero}', style: const TextStyle(fontSize: 12)),
            if (projet.dateCreation != null)
              Text(DateFormat('dd/MM/yyyy').format(projet.dateCreation!), style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: projet.statutColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                projet.statutLabel,
                style: TextStyle(
                  color: projet.statutColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
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
                  _navigateToEditProjet(projet);
                } else if (value == 'delete') {
                  _deleteProjet(projet);
                }
              },
            ),
          ],
        ),
        onTap: () {
          _navigateToEditProjet(projet);
        },
      ),
    );
  }

  Widget _buildArticlesTab() {
    if (_articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.window_outlined, size: 64, color: Colors.grey),
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
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: _articles.length,
          itemBuilder: (context, index) {
            final article = _articles[index];
            return _buildArticleTableRow(article);
          },
        ),
      ),
    );
  }

  Widget _buildArticleTableRow(Article article) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: ListTile(
        leading: Icon(
          _getArticleIcon(article.typeArticle),
          color: Colors.blue,
        ),
        title: Text(
          article.designation,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${article.typeArticleLabel} - ${article.largeur} x ${article.hauteur} cm'),
            Text('Quantité: ${article.quantite}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${article.montantTotalHt.toStringAsFixed(2)} €',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
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
  }

  IconData _getArticleIcon(String type) {
    switch (type) {
      case 'fenetre':
        return Icons.window;
      case 'porte':
        return Icons.door_front_door;
      case 'baie':
        return Icons.view_in_ar;
      default:
        return Icons.category;
    }
  }

  Future<void> _deleteProjet(Projet projet) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer le projet "${projet.nom}" ?'),
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

    if (confirm == true && projet.id != null) {
      try {
        await _menuiserieService.deleteProjet(projet.id!);
        _loadProjets();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Projet supprimé avec succès'),
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

  Future<void> _deleteArticle(Article article) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${article.designation}" ?'),
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
        await _menuiserieService.deleteArticle(article.id!);
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

  void _navigateToCreateProjet() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateProjetScreen(),
      ),
    );

    if (result == true) {
      _loadProjets();
    }
  }

  void _navigateToEditProjet(Projet projet) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateProjetScreen(projet: projet),
      ),
    );

    if (result == true) {
      _loadProjets();
    }
  }

  void _navigateToCreateArticle() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateArticleMenuiserieScreen(),
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
        builder: (context) => CreateArticleMenuiserieScreen(article: article),
      ),
    );

    if (result == true) {
      _loadArticles();
    }
  }
}
