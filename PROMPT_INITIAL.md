# Prompt Initial - Application Gestion Miroiterie/Menuiserie

## 📋 PROMPT COMPLET ORIGINAL

**Demande** : Générer une application Windows complète pour la gestion d'une miroiterie/menuiserie.

## 🎯 OBJECTIFS

L'application doit comporter **10 modules principaux** et respecter les fonctionnalités détaillées ci-dessous. Le code doit être structuré avec un **frontend en Flutter (Win32 ou Windows UWP)** et un **backend Django**, avec une **base de données PostgreSQL**.

## 📦 MODULES PRINCIPAUX (10 modules)

### 1. Module Commerciale
- **Clients** : Gestion complète (CRUD), annuaire alphabétique, recherche
- **Chantiers** : Gestion des chantiers clients
- **Devis** : Création, modification, liste, lignes de devis
- **Factures** : Génération, gestion, suivi
- **Paiements** : Enregistrement, suivi des impayés
- **Ventes comptoir** : Gestion des ventes directes
- **Caisse** : Gestion de la caisse
- **Relances** : Suivi des relances clients

### 2. Module Menuiserie
- Gestion de la production de menuiserie
- Ordres de fabrication
- Suivi de production
- Liaison avec les devis/factures

### 3. Module Stock
- **Articles** : Gestion complète (CRUD), recherche
- **Catégories** : Organisation des articles
- **Fournisseurs** : Gestion des fournisseurs
- **Mouvements** : Entrées/sorties de stock
- **Commandes fournisseurs** : Gestion des commandes
- **Alertes** : Stocks faibles

### 4. Module Travaux & Heures
- Suivi des heures de travail
- Planning des équipes
- Gestion des tâches
- Liaison avec menuiserie

### 5. Module Planning
- Gestion des plannings de production
- Planning des interventions
- Optimisation des ressources

### 6. Module Tournées
- Optimisation des tournées de livraison
- Gestion des tournées
- Intégration cartographie
- Calcul des distances/temps

### 7. Module CRM
- Gestion de la relation client
- Suivi des contacts
- Historique des interactions
- Opportunités commerciales

### 8. Module Vitrages
- Gestion spécifique des vitrages
- Calculs techniques
- Bibliothèque de produits vitrages

### 9. Module Optimisation
- Optimisation des découpes
- Calcul des chutes
- Bibliothèque de profils

### 10. Module Inertie
- Calculs d'inertie thermique
- Études thermiques
- Bibliothèque de matériaux

## 🔗 INTERACTIONS ENTRE MODULES

- **Commerciale ↔ Stock** : Les devis/factures utilisent les articles du stock
- **Commerciale ↔ Menuiserie** : Les devis génèrent des ordres de fabrication
- **Stock ↔ Menuiserie** : Les articles sont consommés lors de la production
- **Menuiserie ↔ Travaux** : Suivi des heures de production
- **Planning ↔ Tournées** : Les plannings alimentent les tournées
- **Commerciale ↔ CRM** : Les clients sont gérés dans le CRM

## 💻 EXIGENCES TECHNIQUES

### Frontend (Flutter)
- **Plateforme** : Windows (Win32 ou UWP)
- **Architecture** : MVC
- **State Management** : Provider
- **Navigation** : Routes nommées
- **UI** : Material Design, interface moderne et intuitive

### Backend (Django)
- **Framework** : Django REST Framework
- **API** : RESTful API
- **WebSocket** : Pour les mises à jour en temps réel (optionnel)
- **Authentification** : Token-based
- **Permissions** : Multi-utilisateurs avec rôles

### Base de données
- **Type** : PostgreSQL
- **Schéma** : Documenté par module
- **Migrations** : Gestion automatique

### Fonctionnalités transversales
- **Multi-utilisateurs** : Gestion des rôles (admin, commercial, production, etc.)
- **Génération PDF** : Devis, factures, bons de commande
- **Archivage** : Archivage automatique des documents
- **Offline** : Fonctionnalité offline avec synchronisation
- **Cartographie** : Intégration pour les tournées
- **Calculs techniques** : Intégrés dans l'application
- **Bibliothèque** : Produits, matériaux, profils, chutes
- **Historique** : Historique des opérations
- **Export** : CSV, Excel pour tous les modules

## 📋 LIVRABLES ATTENDUS

1. **Projet Flutter** compilable avec toutes les dépendances
2. **Projet Django** avec API REST fonctionnelle
3. **Schéma PostgreSQL** documenté
4. **Fonctions clés** implémentées
5. **Interface utilisateur** fonctionnelle
6. **Génération PDF** opérationnelle

## 🚫 CONTRAINTES DE DÉVELOPPEMENT

### Interdictions
- ❌ **Pas d'utilisation du terminal/PowerShell** : Fournir les commandes à l'utilisateur
- ❌ **Pas de duplication de code** : Réutiliser les composants
- ❌ **Pas de variables temporaires inutiles** : Code propre
- ❌ **Pas de création de documentation .md** sauf si demandé

### Règles
- ✅ **Architecture MVC** : Respecter la séparation des responsabilités
- ✅ **Tests unitaires** : Créer des tests pour chaque module
- ✅ **Documentation schéma** : Documenter le schéma par module
- ✅ **Gestion d'erreurs** : Toujours gérer les erreurs
- ✅ **Imports propres** : Organiser les imports

## 🎨 INTERFACE UTILISATEUR

### Fonctionnalités spécifiques demandées
1. **Clients** : Annuaire alphabétique avec onglets (A-Z) et barre de recherche
2. **Devis** : Création avec lignes dynamiques, calculs automatiques
3. **Stock** : Intégration avec les devis pour sélection d'articles

### Design
- Interface moderne et intuitive
- Navigation claire entre les modules
- Feedback utilisateur (messages de succès/erreur)
- Responsive (adapté à Windows)

## 🔄 WORKFLOW DE DÉVELOPPEMENT

### Ordre de développement suggéré
1. **Authentification** : Utilisateurs, rôles, connexion
2. **Stock** : Base pour tous les autres modules
3. **Commerciale** : Clients, devis, factures
4. **Menuiserie** : Production
5. **Autres modules** : Selon les priorités

### Priorités
- **Priorité 1** : Stock (nécessaire pour les devis)
- **Priorité 2** : Commerciale (clients, devis)
- **Priorité 3** : Menuiserie (production)
- **Priorité 4** : Autres modules

---

**Ce prompt initial doit être conservé pour faciliter la reprise du développement et comprendre les objectifs originaux du projet.**






