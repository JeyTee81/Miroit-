# Guide de Déploiement - Miroît+ Expert

Ce document décrit les étapes pour installer et déployer l'application Miroît+ Expert chez un client.

## Table des matières

1. [Prérequis](#prérequis)
2. [Installation du Backend](#installation-du-backend)
3. [Configuration de la Base de Données](#configuration-de-la-base-de-données)
4. [Installation du Frontend](#installation-du-frontend)
5. [Configuration de l'Environnement](#configuration-de-lenvironnement)
6. [Initialisation des Données](#initialisation-des-données)
7. [Démarrage des Services](#démarrage-des-services)
8. [Vérification](#vérification)
9. [Dépannage](#dépannage)

---

## Prérequis

### Système d'exploitation
- **Windows 10/11** (recommandé) ou **Windows Server 2016+**
- **Linux** (Ubuntu 20.04+ ou Debian 11+) pour serveur

### Logiciels requis

#### Pour le Backend (Django)
- **Python 3.10 ou supérieur**
  - Télécharger depuis : https://www.python.org/downloads/
  - Cocher "Add Python to PATH" lors de l'installation
- **pip** (gestionnaire de paquets Python)
- **Git** (optionnel, pour cloner le projet)

#### Pour le Frontend (Flutter)
- **Flutter SDK 3.0+**
  - Télécharger depuis : https://flutter.dev/docs/get-started/install/windows
  - Ajouter Flutter au PATH système
- **Visual Studio 2019/2022** avec les composants C++ (pour Windows)
- **Android Studio** (optionnel, pour développement)

#### Base de données
- **SQLite** (inclus avec Python - par défaut)
- **PostgreSQL** (recommandé pour production)
  - Télécharger depuis : https://www.postgresql.org/download/windows/
- **MySQL** (alternative)

#### Autres
- **Node.js** (pour certaines dépendances Flutter)
- **7-Zip** ou **WinRAR** (pour extraire les archives)

---

## Installation du Backend

### 1. Préparer l'environnement

```powershell
# Créer un dossier pour l'application
mkdir C:\MiroitExpert
cd C:\MiroitExpert

# Créer un environnement virtuel Python
python -m venv venv

# Activer l'environnement virtuel
.\venv\Scripts\activate
```

### 2. Installer les dépendances

```powershell
# Installer les packages Python requis
pip install --upgrade pip
pip install -r backend\requirements.txt
```

### 3. Démarrage automatique (Option 1 - Recommandé)

### 3.1. Utiliser l'exécutable (Windows)

Si un exécutable `MiroitBackend.exe` a été créé :

1. **Double-cliquer sur `MiroitBackend.exe`**
   - Au premier lancement, le script va :
     - Créer la base de données SQLite si elle n'existe pas
     - Appliquer toutes les migrations
     - Demander la création d'un superutilisateur
     - Initialiser les données de référence
   - Ensuite, le serveur démarre automatiquement sur `http://127.0.0.1:8000`

2. **Lors des lancements suivants** :
   - Le serveur démarre directement sans réinitialisation

### 3.2. Utiliser le script Python

Si vous préférez utiliser le script Python directement :

```bash
cd backend
python start_server.py
```

Le script fait exactement la même chose que l'exécutable.

### 3.3. Utiliser le script batch (Windows)

Sur Windows, vous pouvez aussi utiliser :

```cmd
cd backend
start_server.bat
```

---

## 4. Configuration manuelle (Option 2)

Si vous préférez configurer manuellement :

### 4.1. Configuration de la base de données

#### Option A : SQLite (par défaut, pour tests)

Aucune configuration supplémentaire nécessaire. SQLite est inclus avec Python.

#### Option B : PostgreSQL (recommandé pour production)

1. Installer PostgreSQL et créer une base de données :

```sql
CREATE DATABASE miroiterie_db;
CREATE USER miroiterie_user WITH PASSWORD 'votre_mot_de_passe';
GRANT ALL PRIVILEGES ON DATABASE miroiterie_db TO miroiterie_user;
```

2. Modifier `backend/miroiterie/settings.py` :

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'miroiterie_db',
        'USER': 'miroiterie_user',
        'PASSWORD': 'votre_mot_de_passe',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}
```

### 4. Configuration des paramètres

1. Copier le fichier de configuration :

```powershell
cd backend
copy miroiterie\settings.py miroiterie\settings_local.py
```

2. Modifier `settings_local.py` :

```python
# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = 'votre-cle-secrete-unique-et-longue'

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = False

ALLOWED_HOSTS = ['localhost', '127.0.0.1', 'adresse-ip-serveur']

# Configuration CORS pour le frontend
CORS_ALLOWED_ORIGINS = [
    "http://localhost:8080",
    "http://adresse-ip-client:8080",
]
```

3. Modifier `settings.py` pour utiliser `settings_local.py` :

```python
try:
    from .settings_local import *
except ImportError:
    pass
```

### 5. Migrations de la base de données

```powershell
cd backend
python manage.py makemigrations
python manage.py migrate
```

### 6. Créer un superutilisateur

```powershell
python manage.py createsuperuser
```

Suivre les instructions pour créer le premier utilisateur administrateur.

### 7. Initialiser les données de référence

```powershell
# Initialiser les régions vent/neige pour le module Vitrages
python manage.py init_vitrages_data

# Créer d'autres données initiales si nécessaire
python manage.py loaddata initial_data.json  # Si disponible
```

### 8. Collecter les fichiers statiques

```powershell
python manage.py collectstatic --noinput
```

---

## Installation du Frontend

### 1. Vérifier Flutter

```powershell
flutter doctor
```

Résoudre tous les problèmes signalés.

### 2. Préparer le projet

```powershell
cd frontend

# Installer les dépendances
flutter pub get
```

### 3. Configuration de l'API

Modifier `frontend/lib/services/` pour pointer vers le serveur backend :

**Exemple pour `auth_service.dart` :**

```dart
static const String baseUrl = 'http://adresse-ip-serveur:8000/api/auth';
```

**Ou créer un fichier de configuration :**

Créer `frontend/lib/config/app_config.dart` :

```dart
class AppConfig {
  static const String apiBaseUrl = 'http://adresse-ip-serveur:8000/api';
  static const String apiAuthUrl = '$apiBaseUrl/auth';
  // ... autres URLs
}
```

### 4. Compiler l'application

#### Pour Windows (Desktop)

```powershell
flutter build windows --release
```

L'exécutable sera dans : `frontend\build\windows\x64\runner\Release\`

#### Pour créer un installateur

Utiliser **Inno Setup** ou **NSIS** pour créer un installateur Windows.

---

## Configuration de l'Environnement

### Variables d'environnement (optionnel)

Créer un fichier `.env` dans `backend/` :

```env
SECRET_KEY=votre-cle-secrete
DEBUG=False
DATABASE_URL=postgresql://user:password@localhost:5432/miroiterie_db
ALLOWED_HOSTS=localhost,127.0.0.1,adresse-ip
```

Installer `python-decouple` :

```powershell
pip install python-decouple
```

### Configuration du pare-feu

Autoriser les ports suivants :
- **8000** : Backend Django (API)
- **8080** : Frontend Flutter (si serveur web)

```powershell
# Windows Firewall
netsh advfirewall firewall add rule name="Django API" dir=in action=allow protocol=TCP localport=8000
```

---

## Initialisation des Données

### 1. Données de référence

```powershell
cd backend
python manage.py init_vitrages_data
```

### 2. Créer des utilisateurs

```powershell
python manage.py createsuperuser
```

Ou via l'interface d'administration Django : `http://localhost:8000/admin/`

### 3. Importer des données existantes (si applicable)

```powershell
python manage.py loaddata backup_data.json
```

---

## Démarrage des Services

### Backend (Django)

#### Mode développement

```powershell
cd backend
.\venv\Scripts\activate
python manage.py runserver 0.0.0.0:8000
```

#### Mode production (avec Gunicorn)

1. Installer Gunicorn :

```powershell
pip install gunicorn
```

2. Démarrer le serveur :

```powershell
gunicorn miroiterie.wsgi:application --bind 0.0.0.0:8000 --workers 4
```

#### Service Windows (optionnel)

Créer un fichier `start_backend.bat` :

```batch
@echo off
cd C:\MiroitExpert\backend
call venv\Scripts\activate
python manage.py runserver 0.0.0.0:8000
pause
```

Créer une tâche planifiée Windows pour démarrer automatiquement au démarrage.

### Frontend (Flutter)

#### Mode développement

```powershell
cd frontend
flutter run -d windows
```

#### Mode production

Lancer l'exécutable compilé :

```powershell
.\build\windows\x64\runner\Release\miroiterie_app.exe
```

---

## Vérification

### 1. Vérifier le backend

Ouvrir un navigateur et accéder à :
- **API Root** : http://localhost:8000/
- **Admin Django** : http://localhost:8000/admin/
- **API Auth** : http://localhost:8000/api/auth/

### 2. Vérifier le frontend

1. Lancer l'application Flutter
2. Se connecter avec le superutilisateur créé
3. Tester les modules principaux :
   - Commerciale
   - Menuiserie
   - Stock
   - Travaux
   - Planning
   - Tournées
   - CRM
   - Vitrages
   - Débit
   - Inertie

### 3. Tests de fonctionnalités

- ✅ Création d'un client
- ✅ Création d'un devis
- ✅ Création d'un article menuiserie
- ✅ Calcul d'épaisseur vitrage
- ✅ Optimisation de débit
- ✅ Impression PDF

---

## Dépannage

### Problèmes courants

#### 1. Erreur "Module not found"

```powershell
# Réinstaller les dépendances
pip install -r backend\requirements.txt
flutter pub get
```

#### 2. Erreur de connexion à la base de données

- Vérifier que PostgreSQL/MySQL est démarré
- Vérifier les identifiants dans `settings.py`
- Vérifier que la base de données existe

#### 3. Erreur CORS

Ajouter l'adresse IP du client dans `CORS_ALLOWED_ORIGINS` dans `settings.py`.

#### 4. L'application ne démarre pas

- Vérifier les logs dans `backend/logs/`
- Vérifier que le port 8000 n'est pas utilisé
- Vérifier les permissions d'écriture dans les dossiers `media/` et `static/`

#### 5. Erreur de migration

```powershell
# Réinitialiser les migrations (ATTENTION : perte de données)
python manage.py migrate --fake-initial
```

---

## Sauvegarde et Restauration

### Sauvegarde de la base de données

#### SQLite

```powershell
copy backend\db.sqlite3 backup\db_$(Get-Date -Format "yyyyMMdd_HHmmss").sqlite3
```

#### PostgreSQL

```powershell
pg_dump -U miroiterie_user miroiterie_db > backup\db_$(Get-Date -Format "yyyyMMdd_HHmmss").sql
```

### Restauration

#### SQLite

```powershell
copy backup\db_YYYYMMDD_HHMMSS.sqlite3 backend\db.sqlite3
```

#### PostgreSQL

```powershell
psql -U miroiterie_user miroiterie_db < backup\db_YYYYMMDD_HHMMSS.sql
```

---

## Mise à jour

### 1. Sauvegarder les données

```powershell
# Sauvegarder la base de données (voir section ci-dessus)
```

### 2. Mettre à jour le code

```powershell
# Si utilisation de Git
git pull origin main

# Sinon, copier les nouveaux fichiers
```

### 3. Mettre à jour les dépendances

```powershell
# Backend
cd backend
.\venv\Scripts\activate
pip install -r requirements.txt --upgrade

# Frontend
cd frontend
flutter pub get
```

### 4. Appliquer les migrations

```powershell
cd backend
python manage.py migrate
```

### 5. Redémarrer les services

---

## Support

Pour toute question ou problème :
- Consulter les logs dans `backend/logs/`
- Vérifier la documentation dans `README.md`
- Contacter le support technique

---

## Checklist de déploiement

- [ ] Python 3.10+ installé
- [ ] Flutter SDK installé
- [ ] Base de données configurée
- [ ] Backend installé et configuré
- [ ] Migrations appliquées
- [ ] Superutilisateur créé
- [ ] Données de référence initialisées
- [ ] Frontend compilé
- [ ] Configuration API mise à jour
- [ ] Pare-feu configuré
- [ ] Services démarrés
- [ ] Tests de vérification effectués
- [ ] Sauvegarde initiale effectuée

---

**Date de création** : 2025-11-07  
**Version** : 1.0.0


