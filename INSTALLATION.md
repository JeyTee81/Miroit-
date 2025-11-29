# Guide d'Installation

## Prérequis

- Python 3.10 ou supérieur
- PostgreSQL 12 ou supérieur
- Flutter SDK 3.0 ou supérieur
- Node.js (optionnel, pour certains outils)

## Installation Backend (Django)

### 1. Créer l'environnement virtuel

```bash
python -m venv venv
```

### 2. Activer l'environnement virtuel

**Windows (CMD):**
```bash
venv\Scripts\activate
```

**Windows (PowerShell):**
```bash
venv\Scripts\Activate.ps1
```

**Linux/Mac:**
```bash
source venv/bin/activate
```

### 3. Installer les dépendances

```bash
cd backend
pip install -r requirements.txt
```

### 4. Configurer PostgreSQL

1. Créer une base de données:
```sql
CREATE DATABASE miroiterie_db;
```

2. Créer un utilisateur (optionnel):
```sql
CREATE USER miroiterie_user WITH PASSWORD 'votre_mot_de_passe';
GRANT ALL PRIVILEGES ON DATABASE miroiterie_db TO miroiterie_user;
```

### 5. Configurer les variables d'environnement

Créer un fichier `.env` dans le dossier `backend/`:

```
DB_NAME=miroiterie_db
DB_USER=postgres
DB_PASSWORD=votre_mot_de_passe
DB_HOST=localhost
DB_PORT=5432
SECRET_KEY=votre-secret-key-tres-longue-et-aleatoire
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1
```

### 6. Créer les migrations

```bash
python manage.py makemigrations
```

### 7. Appliquer les migrations

```bash
python manage.py migrate
```

### 8. Créer un superutilisateur

```bash
python manage.py createsuperuser
```

### 9. Lancer le serveur de développement

```bash
python manage.py runserver
```

Le serveur sera accessible sur `http://localhost:8000`

## Installation Frontend (Flutter)

### 1. Vérifier l'installation de Flutter

```bash
flutter doctor
```

### 2. Installer les dépendances

```bash
cd frontend
flutter pub get
```

### 3. Configurer l'URL de l'API

Modifier `frontend/lib/providers/auth_provider.dart` si nécessaire:
```dart
static const String baseUrl = 'http://localhost:8000/api';
```

### 4. Lancer l'application

**Windows:**
```bash
flutter run -d windows
```

**Développement:**
```bash
flutter run
```

## Génération du Script SQL

Pour générer le script SQL complet à partir des modèles Django:

```bash
cd backend
python manage.py sqlmigrate commerciale 0001 > schema_commerciale.sql
python manage.py sqlmigrate stock 0001 > schema_stock.sql
# Répéter pour chaque app
```

Ou utiliser le fichier `DATABASE_SCHEMA.md` comme référence pour créer manuellement le schéma.

## Commandes Utiles

### Django

- `python manage.py makemigrations` - Créer les migrations
- `python manage.py migrate` - Appliquer les migrations
- `python manage.py createsuperuser` - Créer un admin
- `python manage.py runserver` - Lancer le serveur
- `python manage.py collectstatic` - Collecter les fichiers statiques
- `python manage.py shell` - Shell Django interactif

### Flutter

- `flutter pub get` - Installer les dépendances
- `flutter run` - Lancer l'application
- `flutter build windows` - Build pour production
- `flutter clean` - Nettoyer le projet
- `flutter doctor` - Vérifier l'installation

### Tests

```bash
cd backend
pytest
pytest tests/test_commerciale.py -v
pytest tests/test_authentication.py -v
```

## Dépannage

### Problème de connexion à PostgreSQL

1. Vérifier que PostgreSQL est démarré
2. Vérifier les identifiants dans `.env`
3. Vérifier que la base de données existe

### Problème de migration Django

```bash
python manage.py migrate --fake-initial
```

### Problème Flutter

```bash
flutter clean
flutter pub get
flutter run
```

## Structure des Commandes SQL

Pour créer la base de données manuellement, exécutez les commandes dans cet ordre:

1. Créer la base de données
2. Créer les extensions (UUID)
3. Créer les tables dans l'ordre des dépendances:
   - users
   - clients
   - stock_categories
   - stock_fournisseurs
   - stock_articles
   - commerciale_chantiers
   - commerciale_devis
   - commerciale_lignes_devis
   - commerciale_factures
   - etc.

Voir `DATABASE_SCHEMA.md` pour l'ordre complet et les relations.






