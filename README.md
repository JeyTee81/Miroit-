# 🪟 Miroît+ Expert - Application de Gestion Miroiterie/Menuiserie

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Django](https://img.shields.io/badge/Django-4.2-092E20?logo=django)](https://www.djangoproject.com)
[![Python](https://img.shields.io/badge/Python-3.10+-3776AB?logo=python)](https://www.python.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Miroît+ Expert** est une application Windows complète et professionnelle pour la gestion d'une miroiterie/menuiserie. Elle offre une solution intégrée couvrant tous les aspects de la gestion d'entreprise : commercial, production, stock, planning, et bien plus encore.

## 📋 Table des matières

- [Fonctionnalités](#-fonctionnalités)
- [Architecture](#-architecture)
- [Technologies](#-technologies)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Utilisation](#-utilisation)
- [Structure du projet](#-structure-du-projet)
- [Modules détaillés](#-modules-détaillés)
- [Développement](#-développement)
- [Contribution](#-contribution)
- [Licence](#-licence)

## ✨ Fonctionnalités

### 🎯 Modules principaux (10 modules)

1. **💼 Gestion Commerciale** - Clients, devis, factures, chantiers, paiements
2. **🪚 Menuiserie** - Chiffrage, dessins techniques, tarifs fournisseurs
3. **📦 Stock** - Gestion des articles, mouvements, fournisseurs, alertes
4. **🔧 Travaux** - Suivi des heures, bilans chantiers, commandes travaux
5. **📅 Planning** - Rendez-vous commerciaux et planification des interventions
6. **🚚 Tournées** - Optimisation des itinéraires de livraison, gestion véhicules
7. **👥 CRM** - Suivi client, historique des interactions, statistiques
8. **🪟 Vitrages** - Calculs normatifs (NF DTU 39), notes de calcul
9. **✂️ Optimisation Débits** - Plans de coupe optimisés, gestion des chutes
10. **📐 Calcul d'Inertie** - Calculs normatifs (NF EN 1991), profils

### 🚀 Fonctionnalités avancées

- ✅ **Génération PDF** - Devis, factures, articles menuiserie
- ✅ **Gestion des permissions** - Système de rôles et accès personnalisés
- ✅ **Console de logs** - Suivi des erreurs et événements système
- ✅ **Interface moderne** - Design professionnel inspiré des applications Windows
- ✅ **API REST complète** - Architecture backend modulaire et extensible
- ✅ **Authentification sécurisée** - Token-based authentication
- ✅ **Configuration serveur** - Configuration flexible du backend

## 🏗️ Architecture

L'application suit une architecture **client-serveur** moderne :

```
┌─────────────────────────────────────────────────────────┐
│                    Frontend (Flutter)                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Screens    │  │   Services   │  │   Providers  │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                        ↕ HTTP/REST API
┌─────────────────────────────────────────────────────────┐
│                  Backend (Django REST)                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │    Views     │  │  Serializers │  │    Models    │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                        ↕ ORM
┌─────────────────────────────────────────────────────────┐
│              Base de données (PostgreSQL)                 │
└─────────────────────────────────────────────────────────┘
```

### Composants

- **Frontend** : Application Flutter Desktop (Windows) avec interface utilisateur moderne
- **Backend** : API REST Django avec architecture modulaire par applications
- **Base de données** : PostgreSQL (production) / SQLite (développement)
- **Authentification** : Token-based avec gestion des rôles et permissions

## 🛠️ Technologies

### Frontend
- **Flutter** 3.0+ - Framework UI multiplateforme
- **Provider** - Gestion d'état
- **HTTP** - Communication avec l'API
- **PDF** - Génération de documents
- **Printing** - Impression des documents

### Backend
- **Django** 4.2 - Framework web Python
- **Django REST Framework** - API REST
- **PostgreSQL** - Base de données relationnelle
- **Python** 3.10+ - Langage de programmation

## 📦 Installation

### Prérequis

- **Windows** 10/11
- **Python** 3.10 ou supérieur
- **Flutter SDK** 3.0 ou supérieur
- **PostgreSQL** 12+ (pour la production)
- **Git**

### Installation rapide

1. **Cloner le dépôt**
   ```bash
   git clone https://github.com/votre-username/miroiterie-app.git
   cd miroiterie-app
   ```

2. **Installer le backend**
   ```bash
   cd backend
   python -m venv venv
   venv\Scripts\activate
   pip install -r requirements.txt
   python manage.py migrate
   python manage.py createsuperuser
   ```

3. **Installer le frontend**
   ```bash
   cd frontend
   flutter pub get
   ```

4. **Lancer l'application**
   ```bash
   # Terminal 1 - Backend
   cd backend
   python manage.py runserver
   
   # Terminal 2 - Frontend
   cd frontend
   flutter run -d windows
   ```

> 📖 **Guide complet** : Consultez [DEPLOIEMENT.md](DataLocal/DEPLOIEMENT.md) pour un guide détaillé de déploiement en production.

## ⚙️ Configuration

### Configuration du serveur backend

Lors du premier lancement, l'application vous demandera de configurer l'adresse du serveur backend. Vous pouvez également modifier cette configuration dans les paramètres.

**Configuration par défaut** : `http://localhost:8000`

### Variables d'environnement (Backend)

Créez un fichier `.env` dans le dossier `backend/` :

```env
SECRET_KEY=votre-secret-key
DEBUG=True
DATABASE_URL=postgresql://user:password@localhost:5432/miroiterie
ALLOWED_HOSTS=localhost,127.0.0.1
```

## 🎮 Utilisation

### Premier lancement

1. **Démarrer le serveur backend**
   ```bash
   cd backend
   python manage.py runserver
   ```

2. **Lancer l'application Flutter**
   ```bash
   cd frontend
   flutter run -d windows
   ```

3. **Configurer le serveur** (première fois)
   - Entrez l'adresse du serveur backend
   - Testez la connexion
   - Sauvegardez la configuration

4. **Se connecter**
   - Utilisez les identifiants créés avec `createsuperuser`
   - Ou créez un utilisateur via l'interface d'administration Django

### Navigation

L'interface principale offre :
- **Barre de menu** - Accès rapide aux modules principaux
- **Sidebar** - Navigation détaillée par module
- **Zone de contenu** - Affichage des données et formulaires
- **Barre de statut** - Informations système et utilisateur

## 📁 Structure du projet

```
miroiterie-app/
├── backend/                 # Projet Django
│   ├── apps/               # Applications métier
│   │   ├── authentication/ # Authentification
│   │   ├── commerciale/    # Module commercial
│   │   ├── menuiserie/     # Module menuiserie
│   │   ├── stock/          # Module stock
│   │   ├── travaux/        # Module travaux
│   │   ├── planning/       # Module planning
│   │   ├── tournees/        # Module tournées
│   │   ├── crm/            # Module CRM
│   │   ├── vitrages/       # Module vitrages
│   │   ├── optimisation/   # Module optimisation
│   │   ├── inertie/        # Module inertie
│   │   ├── system_logs/    # Système de logs
│   │   └── parametres/     # Paramètres système
│   ├── miroiterie/         # Configuration Django
│   ├── tests/              # Tests unitaires
│   └── requirements.txt    # Dépendances Python
│
├── frontend/                # Application Flutter
│   ├── lib/
│   │   ├── screens/        # Écrans de l'application
│   │   ├── services/       # Services API
│   │   ├── models/         # Modèles de données
│   │   ├── providers/      # Gestion d'état
│   │   ├── widgets/        # Composants réutilisables
│   │   ├── theme/          # Thème de l'application
│   │   └── pdf_generators/ # Générateurs PDF
│   └── pubspec.yaml        # Dépendances Flutter
│
├── DataLocal/              # Documentation
│   ├── DEPLOIEMENT.md      # Guide de déploiement
│   ├── ETAT_APPLICATION.md # État de l'application
│   └── ...
│
└── README.md               # Ce fichier
```

## 📚 Modules détaillés

### 💼 Gestion Commerciale

Gestion complète du cycle commercial :
- **Clients** : CRUD, recherche, annuaire alphabétique
- **Chantiers** : Suivi des projets clients
- **Devis** : Création, modification, génération PDF
- **Factures** : Génération depuis devis, suivi paiements
- **Paiements** : Enregistrement, suivi des impayés

### 🪚 Menuiserie

Chiffrage et gestion de la production menuiserie :
- **Articles** : Création avec options obligatoires/facultatives
- **Dessins** : Visualisation à l'échelle
- **Tarifs fournisseurs** : Gestion des tarifs
- **Génération PDF** : Fiches articles complètes

### 📦 Stock

Gestion complète du stock :
- **Articles** : CRUD, catégorisation
- **Mouvements** : Entrées, sorties, transferts
- **Fournisseurs** : Gestion des fournisseurs
- **Alertes** : Stocks faibles automatiques

### 🔧 Travaux

Suivi des heures et travaux :
- **Devis travaux** : Création et gestion
- **Commandes travaux** : Suivi des commandes
- **Heures** : Saisie et suivi
- **Bilans chantiers** : Statistiques par chantier

### 📅 Planning

Planification des interventions :
- **Rendez-vous** : Gestion des rendez-vous commerciaux
- **Interventions** : Planification des travaux
- **Calendrier** : Vue calendrier interactive

### 🚚 Tournées

Optimisation des livraisons :
- **Véhicules** : Gestion de la flotte
- **Chauffeurs** : Gestion des équipes
- **Tournées** : Création et optimisation
- **Livraisons** : Suivi des livraisons

### 👥 CRM

Relation client :
- **Visites** : Suivi des visites commerciales
- **Historique** : Historique des interactions
- **Statistiques** : Analyses commerciales

### 🪟 Vitrages

Calculs normatifs vitrages :
- **Projets** : Gestion des projets vitrages
- **Calculs** : Calculs NF DTU 39
- **Notes de calcul** : Génération automatique

### ✂️ Optimisation Débits

Optimisation des découpes :
- **Plans de coupe** : Optimisation automatique
- **Chutes** : Gestion des chutes
- **Bibliothèque** : Historique des opérations

### 📐 Calcul d'Inertie

Calculs normatifs inertie :
- **Projets** : Gestion des projets
- **Profils** : Gestion des profils
- **Calculs** : Calculs NF EN 1991

## 🔧 Développement

### Structure du code

- **Backend** : Architecture modulaire Django avec séparation claire des responsabilités
- **Frontend** : Architecture Flutter avec providers pour la gestion d'état
- **API** : RESTful API avec serializers Django REST Framework

### Tests

```bash
# Backend
cd backend
python manage.py test

# Frontend
cd frontend
flutter test
```

### Contribution au code

1. Fork le projet
2. Créez une branche pour votre fonctionnalité (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

### Standards de code

- **Python** : PEP 8
- **Dart** : Effective Dart guidelines
- **Commits** : Messages clairs et descriptifs

## 📝 Documentation

- [Guide de déploiement](DataLocal/DEPLOIEMENT.md) - Déploiement en production
- [État de l'application](DataLocal/ETAT_APPLICATION.md) - État actuel des modules
- [Schéma de base de données](DataLocal/DATABASE_SCHEMA.md) - Documentation du schéma
- [Installation rapide](DataLocal/INSTALLATION_RAPIDE.md) - Installation rapide

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer :

1. **Signaler un bug** : Ouvrez une issue avec une description détaillée
2. **Proposer une fonctionnalité** : Ouvrez une issue avec le label "enhancement"
3. **Soumettre du code** : Suivez le processus de Pull Request

### Guidelines

- Respectez les standards de code existants
- Ajoutez des tests pour les nouvelles fonctionnalités
- Documentez les changements majeurs
- Assurez-vous que tous les tests passent

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 👤 Auteur

**Votre Nom**

- GitHub: [@votre-username](https://github.com/votre-username)
- Email: votre.email@example.com

## 🙏 Remerciements

- Django et Flutter pour les frameworks exceptionnels
- La communauté open source pour les outils et bibliothèques utilisés
- Tous les contributeurs qui ont aidé à améliorer ce projet

---

⭐ Si ce projet vous a été utile, n'hésitez pas à lui donner une étoile !
