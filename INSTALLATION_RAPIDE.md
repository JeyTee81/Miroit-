# Installation Rapide - Miroît+ Expert

Guide rapide pour installer l'application en 10 minutes.

## Prérequis

- Windows 10/11
- Python 3.10+ ([télécharger](https://www.python.org/downloads/))
- Flutter SDK 3.0+ ([télécharger](https://flutter.dev/docs/get-started/install/windows))

## Étapes d'installation

### 1. Backend (5 minutes)

```powershell
# 1. Cloner ou copier le projet
cd C:\
mkdir MiroitExpert
cd MiroitExpert
# Copier les dossiers backend et frontend ici

# 2. Créer l'environnement virtuel
cd backend
python -m venv venv
.\venv\Scripts\activate

# 3. Installer les dépendances
pip install -r requirements.txt

# 4. Appliquer les migrations
python manage.py migrate

# 5. Créer un superutilisateur
python manage.py createsuperuser

# 6. Initialiser les données
python manage.py init_vitrages_data

# 7. Démarrer le serveur
python manage.py runserver
```

Le backend sera accessible sur : http://localhost:8000

### 2. Frontend (5 minutes)

```powershell
# 1. Ouvrir un nouveau terminal
cd C:\MiroitExpert\frontend

# 2. Installer les dépendances
flutter pub get

# 3. Lancer l'application
flutter run -d windows
```

### 3. Première connexion

1. L'application Flutter s'ouvre
2. Utiliser les identifiants du superutilisateur créé à l'étape 1.5
3. Vous êtes connecté !

## Vérification

- ✅ Backend accessible : http://localhost:8000
- ✅ Admin Django : http://localhost:8000/admin/
- ✅ Application Flutter lancée

## Problèmes ?

Consultez le [guide complet de déploiement](DEPLOIEMENT.md) pour plus de détails.




