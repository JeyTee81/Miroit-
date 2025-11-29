# Règles de Développement - Application Miroiterie/Menuiserie

## 🎯 PRINCIPES FONDAMENTAUX

### 1. Architecture MVC
- **Modèle** : Définition des données (Django models, Flutter models)
- **Vue** : Interface utilisateur (Flutter screens)
- **Contrôleur** : Logique métier (Django views, Flutter services)

### 2. Séparation des responsabilités
- Chaque module a son app Django
- Chaque module a son service Flutter
- Les modèles sont partagés entre frontend et backend

---

## 📝 RÈGLES DE CODE

### Backend (Django)

#### Modèles
- Utiliser `UUIDField` comme clé primaire
- Toujours définir `__str__` pour l'affichage
- Utiliser `on_delete=models.PROTECT` pour les relations critiques
- Ajouter `created_at` et `updated_at` pour l'historique
- Documenter les champs dans `DATABASE_SCHEMA.md`

#### Serializers
- Toujours inclure les champs calculés en lecture seule
- Utiliser `source='relation.champ'` pour les champs liés
- Valider les données avec `validate_*` si nécessaire
- Gérer les créations/updates imbriquées proprement

#### Views
- Utiliser `ViewSet` pour les opérations CRUD standard
- Toujours utiliser `IsAuthenticated` pour les permissions
- Ajouter des actions personnalisées avec `@action`
- Gérer les erreurs proprement avec `Response`

#### Migrations
- **IMPORTANT** : Éviter les dépendances circulaires
- Si nécessaire, créer des migrations séparées :
  1. Migration sans la dépendance
  2. Migration avec la dépendance
- Toujours tester les migrations avant commit

### Frontend (Flutter)

#### Modèles
- Créer un fichier par modèle : `lib/models/[nom]_model.dart`
- Implémenter `fromJson` et `toJson`
- Ajouter les propriétés calculées si nécessaire
- Valider les données côté client

#### Services
- Créer un fichier par service : `lib/services/[nom]_service.dart`
- Toujours inclure la gestion du token d'authentification
- Gérer les erreurs HTTP proprement
- Retourner des exceptions claires

#### Écrans
- Un fichier par écran : `lib/screens/[nom]_screen.dart`
- Utiliser `StatefulWidget` pour les formulaires
- Gérer les états de chargement
- Afficher des messages de feedback (SnackBar)
- Valider les formulaires avant soumission

#### Widgets réutilisables
- Créer dans `lib/widgets/` si réutilisé plusieurs fois
- Documenter les paramètres

---

## 🔄 WORKFLOW DE DÉVELOPPEMENT

### 1. Créer une nouvelle fonctionnalité

#### Backend
1. Modifier/ajouter le modèle dans `models.py`
2. Créer la migration : `python manage.py makemigrations`
3. Appliquer la migration : `python manage.py migrate`
4. Créer/modifier le serializer
5. Créer/modifier la vue (ViewSet)
6. Ajouter les routes dans `urls.py`
7. Tester avec l'API (Postman/curl)

#### Frontend
1. Créer/modifier le modèle Flutter
2. Créer/modifier le service API
3. Créer/modifier l'écran
4. Ajouter la route dans `main.dart` si nouveau
5. Tester avec hot reload

### 2. Gérer les dépendances circulaires

**Problème** : App A dépend de App B, App B dépend de App A

**Solution** :
1. Identifier la dépendance la moins critique
2. Supprimer temporairement la relation
3. Créer la migration sans la dépendance
4. Créer une nouvelle migration pour ajouter la dépendance
5. Appliquer les migrations dans l'ordre

**Exemple** : Voir `commerciale/migrations/0003_add_compte_comptable.py`

### 3. Gérer les données imbriquées

**Cas** : Créer un Devis avec ses LignesDevis

**Solution** :
1. Dans le serializer, gérer manuellement les objets imbriqués
2. Exclure les champs de relation dans `toJson` du frontend
3. Le backend gère la création/update des objets liés

---

## 🚫 INTERDICTIONS

### 1. Terminal/PowerShell
- ❌ Ne JAMAIS utiliser `run_terminal_cmd` directement
- ✅ Fournir les commandes à l'utilisateur pour exécution manuelle
- ✅ Format : Commandes CMD (pas PowerShell)

### 2. Duplication de code
- ❌ Ne pas copier/coller du code
- ✅ Créer des fonctions/services réutilisables
- ✅ Utiliser des widgets réutilisables

### 3. Variables temporaires
- ❌ Éviter les variables inutiles
- ✅ Utiliser des noms explicites
- ✅ Préférer la composition à l'accumulation

### 4. Documentation non demandée
- ❌ Ne pas créer de fichiers .md sans demande
- ✅ Exception : Documentation technique nécessaire (DATABASE_SCHEMA.md)

### 5. Modifications non testées
- ❌ Ne pas modifier sans vérifier les impacts
- ✅ Toujours tester après modification
- ✅ Vérifier les linters

---

## ✅ BONNES PRATIQUES

### 1. Gestion d'erreurs
```python
# Backend
try:
    # Code
except Exception as e:
    return Response({'error': str(e)}, status=400)
```

```dart
// Frontend
try {
  await service.createItem(item);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Succès'), backgroundColor: Colors.green),
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
  );
}
```

### 2. Validation des formulaires
```dart
// Toujours valider avant soumission
if (!_formKey.currentState!.validate()) {
  return;
}
```

### 3. États de chargement
```dart
// Toujours afficher un indicateur de chargement
if (_isLoading) {
  return Center(child: CircularProgressIndicator());
}
```

### 4. Recherche
```dart
// Implémenter une barre de recherche pour les listes importantes
TextField(
  controller: _searchController,
  decoration: InputDecoration(
    hintText: 'Rechercher...',
    prefixIcon: Icon(Icons.search),
  ),
)
```

### 5. Navigation
```dart
// Utiliser Navigator.push avec MaterialPageRoute
final result = await Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => CreateScreen()),
);
if (result == true) {
  _loadData(); // Recharger les données
}
```

---

## 🧪 TESTS

### Backend
- Créer des tests dans `backend/tests/test_[module].py`
- Utiliser pytest
- Tester les modèles, serializers, et vues

### Frontend
- Tester les widgets critiques
- Tester les services API avec des mocks
- Vérifier les validations de formulaires

---

## 📦 GESTION DES DÉPENDANCES

### Backend
- Toutes les dépendances dans `requirements.txt`
- Utiliser des versions spécifiques si nécessaire
- Mettre à jour régulièrement

### Frontend
- Toutes les dépendances dans `pubspec.yaml`
- Vérifier les conflits de versions
- Utiliser `flutter pub outdated` pour vérifier les mises à jour

---

## 🔐 SÉCURITÉ

### Backend
- Toujours authentifier les requêtes (`IsAuthenticated`)
- Valider toutes les données d'entrée
- Ne jamais exposer les tokens ou mots de passe

### Frontend
- Stocker le token dans `SharedPreferences`
- Ne jamais hardcoder de credentials
- Valider les données avant envoi

---

## 📊 PERFORMANCE

### Backend
- Utiliser la pagination pour les grandes listes
- Optimiser les requêtes avec `select_related` et `prefetch_related`
- Indexer les champs fréquemment recherchés

### Frontend
- Utiliser `ListView.builder` pour les longues listes
- Implémenter le lazy loading si nécessaire
- Éviter les rebuilds inutiles

---

## 🎨 INTERFACE UTILISATEUR

### Design
- Utiliser le thème défini dans `app_theme.dart`
- Maintenir la cohérence visuelle
- Utiliser les Material Design components

### Navigation
- Utiliser les routes définies dans `main.dart`
- Implémenter un retour arrière logique
- Gérer les états de navigation

### Feedback
- Toujours informer l'utilisateur des actions
- Messages de succès en vert
- Messages d'erreur en rouge
- Indicateurs de chargement

---

## 📝 DOCUMENTATION

### Code
- Commenter les fonctions complexes
- Documenter les paramètres et retours
- Expliquer les choix de design

### Projet
- Mettre à jour `ETAT_APPLICATION.md` après chaque grande fonctionnalité
- Documenter les changements de schéma dans `DATABASE_SCHEMA.md`
- Maintenir la liste des prochaines étapes

---

**Ces règles doivent être respectées à chaque étape du développement pour maintenir la cohérence et la qualité du code.**






