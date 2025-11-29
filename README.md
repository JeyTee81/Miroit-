# Application de Gestion Miroiterie/Menuiserie

Application Windows complète pour la gestion d'une miroiterie/menuiserie avec 10 modules fonctionnels.

## Architecture

- **Backend**: Django 4.2 avec API REST
- **Frontend**: Flutter (Windows)
- **Base de données**: PostgreSQL

## Structure du projet

```
.
├── backend/              # Projet Django
│   ├── apps/           # Applications métier
│   ├── miroiterie/     # Configuration Django
│   ├── tests/          # Tests unitaires
│   └── requirements.txt
├── frontend/            # Application Flutter
│   └── lib/
│       ├── screens/    # Écrans de l'application
│       ├── providers/  # Gestion d'état
│       ├── widgets/    # Composants réutilisables
│       └── theme/      # Thème de l'application
├── DATABASE_SCHEMA.md   # Documentation du schéma de base de données
├── DEPLOIEMENT.md       # Guide complet de déploiement
├── INSTALLATION_RAPIDE.md # Guide d'installation rapide
├── CHECKLIST_DEPLOIEMENT.md # Checklist de déploiement
├── ETAT_APPLICATION.md  # État actuel de l'application
├── install.ps1          # Script d'installation automatique
└── README.md
```

## Modules

1. **Gestion Commerciale / Affaires** - Devis, factures, chantiers, paiements
2. **Menuiserie** - Chiffrage, dessins, tarifs fournisseurs
3. **Stock** - Gestion articles, mouvements, fournisseurs
4. **Gestion Travaux et Heures** - Saisie heures, bilans chantiers
5. **Planning** - Rendez-vous commerciaux et travaux
6. **Tournées (Livraison)** - Optimisation itinéraires, gestion véhicules
7. **Suivi Client (CRM)** - Historique, visites, statistiques
8. **Gestion Vitrages** - Calculs NF DTU 39, notes de calcul
9. **Optimisation de Débits** - Plans de coupe, gestion chutes
10. **Calcul d'Inertie** - Calculs NF EN 1991, profils

## Installation

> **Pour un déploiement en production chez un client, consultez le guide complet : [DEPLOIEMENT.md](DEPLOIEMENT.md)**

## Installation (Développement)

### Backend (Django)

1. Créer un environnement virtuel:
```bash
python -m venv venv
venv\Scripts\activate
```

2. Installer les dépendances:
```bash
cd backend
pip install -r requirements.txt
```

3. Configurer la base de données PostgreSQL dans `backend/miroiterie/settings.py` ou créer un fichier `.env`:
```
DB_NAME=miroiterie_db
DB_USER=postgres
DB_PASSWORD=postgres
DB_HOST=localhost
DB_PORT=5432
SECRET_KEY=your-secret-key-here
DEBUG=True
```

4. Créer les migrations:
```bash
python manage.py makemigrations
python manage.py migrate
```

5. Créer un superutilisateur:
```bash
python manage.py createsuperuser
```

6. Lancer le serveur:
```bash
python manage.py runserver
```

### Frontend (Flutter)

1. Installer Flutter SDK (version >=3.0.0)

2. Installer les dépendances:
```bash
cd frontend
flutter pub get
```

3. Lancer l'application:
```bash
flutter run -d windows
```

## Génération du script SQL

Pour générer le script SQL complet de la base de données:

```bash
cd backend
python manage.py sqlmigrate --all > schema.sql
```

Ou utiliser le fichier `DATABASE_SCHEMA.md` comme référence pour créer manuellement le schéma.

## Tests

Les tests unitaires sont dans le dossier `backend/tests/`.

Pour exécuter les tests:
```bash
cd backend
pytest
```

## Configuration

### Rôles utilisateurs

- **admin**: Accès complet à tous les modules
- **commercial**: Accès aux modules commerciaux, CRM, planning
- **atelier**: Accès aux modules menuiserie, stock, travaux, optimisation
- **logistique**: Accès aux modules tournées, stock
- **comptable**: Accès aux modules commerciale, comptabilité

## Fonctionnalités principales

- Authentification multi-utilisateurs avec rôles
- Gestion complète des devis et factures
- Suivi des stocks en temps réel
- Planning intégré
- Optimisation des tournées de livraison
- Calculs techniques (vitrages, inertie)
- Génération automatique de PDF
- Archivage des documents
- Statistiques et rapports

## Développement

### Structure des modèles

Tous les modèles Django sont organisés par module dans `backend/apps/`. Chaque module contient:
- `models.py`: Modèles de données
- `views.py`: Vues API (à implémenter)
- `serializers.py`: Sérialiseurs DRF (à implémenter)
- `urls.py`: Routes API
- `admin.py`: Configuration admin Django

### Structure Flutter

L'application Flutter est organisée en:
- `screens/`: Écrans de l'application
- `providers/`: Gestion d'état avec Provider
- `widgets/`: Composants réutilisables
- `services/`: Services API (à implémenter)
- `models/`: Modèles de données (à implémenter)

## Notes

- Le backend Django doit être démarré avant le frontend Flutter
- L'URL de l'API par défaut est `http://localhost:8000/api`
- La base de données PostgreSQL doit être créée et accessible
- Les fichiers PDF sont stockés dans `backend/media/pdfs/`

## Commandes utiles

### Django
- `python manage.py makemigrations` - Créer les migrations
- `python manage.py migrate` - Appliquer les migrations
- `python manage.py createsuperuser` - Créer un admin
- `python manage.py runserver` - Lancer le serveur

### Flutter
- `flutter pub get` - Installer les dépendances
- `flutter run -d windows` - Lancer sur Windows
- `flutter build windows` - Build pour production

## Licence

Propriétaire - Tous droits réservés



