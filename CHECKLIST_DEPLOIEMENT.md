# Checklist de Déploiement - Miroît+ Expert

Utilisez cette checklist pour vous assurer que toutes les étapes sont effectuées lors d'un déploiement chez un client.

## Pré-installation

- [ ] Vérifier les prérequis système (Windows 10/11, espace disque suffisant)
- [ ] Vérifier la connexion réseau (si serveur distant)
- [ ] Préparer les identifiants de base de données (si PostgreSQL/MySQL)
- [ ] Préparer les informations de connexion réseau (adresses IP, ports)
- [ ] Sauvegarder les données existantes (si mise à jour)

## Installation des prérequis

- [ ] Python 3.10+ installé et dans le PATH
- [ ] Flutter SDK 3.0+ installé et dans le PATH
- [ ] PostgreSQL installé (si utilisé)
- [ ] Visual Studio avec composants C++ installé (pour Flutter)
- [ ] Git installé (optionnel)

## Installation Backend

- [ ] Dossier d'installation créé
- [ ] Fichiers backend copiés
- [ ] Environnement virtuel Python créé
- [ ] Dépendances Python installées (`pip install -r requirements.txt`)
- [ ] Base de données créée (PostgreSQL/MySQL) ou SQLite configuré
- [ ] Fichier `settings.py` ou `settings_local.py` configuré
- [ ] `SECRET_KEY` défini et sécurisé
- [ ] `DEBUG = False` en production
- [ ] `ALLOWED_HOSTS` configuré
- [ ] `CORS_ALLOWED_ORIGINS` configuré
- [ ] Migrations appliquées (`python manage.py migrate`)
- [ ] Superutilisateur créé (`python manage.py createsuperuser`)
- [ ] Données de référence initialisées (`python manage.py init_vitrages_data`)
- [ ] Fichiers statiques collectés (`python manage.py collectstatic`)

## Installation Frontend

- [ ] Dossier frontend copié
- [ ] Dépendances Flutter installées (`flutter pub get`)
- [ ] Configuration API mise à jour (URLs du backend)
- [ ] Application compilée (`flutter build windows --release`)
- [ ] Exécutable testé

## Configuration réseau

- [ ] Port 8000 ouvert dans le pare-feu (backend)
- [ ] Port 8080 ouvert (si serveur web frontend)
- [ ] Adresses IP configurées dans les fichiers de configuration
- [ ] CORS configuré correctement

## Tests de vérification

- [ ] Backend accessible : http://localhost:8000
- [ ] Admin Django accessible : http://localhost:8000/admin/
- [ ] API accessible : http://localhost:8000/api/
- [ ] Frontend démarre correctement
- [ ] Connexion utilisateur fonctionne
- [ ] Module Commerciale testé
- [ ] Module Menuiserie testé
- [ ] Module Stock testé
- [ ] Module Travaux testé
- [ ] Module Planning testé
- [ ] Module Tournées testé
- [ ] Module CRM testé
- [ ] Module Vitrages testé
- [ ] Module Débit testé
- [ ] Module Inertie testé
- [ ] Impression PDF testée
- [ ] Gestion des imprimantes testée

## Sécurité

- [ ] `SECRET_KEY` unique et sécurisé
- [ ] `DEBUG = False` en production
- [ ] Mots de passe utilisateurs sécurisés
- [ ] Permissions fichiers/dossiers correctes
- [ ] Sauvegarde automatique configurée (optionnel)

## Documentation client

- [ ] Guide utilisateur fourni
- [ ] Identifiants de connexion fournis
- [ ] Procédure de démarrage documentée
- [ ] Procédure de sauvegarde documentée
- [ ] Procédure de mise à jour documentée
- [ ] Contacts support fournis

## Post-installation

- [ ] Formation utilisateurs effectuée
- [ ] Sauvegarde initiale effectuée
- [ ] Scripts de démarrage automatique créés (optionnel)
- [ ] Tâche planifiée Windows créée (optionnel)
- [ ] Monitoring configuré (optionnel)

## Notes

Date d'installation : _______________
Technicien : _______________
Client : _______________
Version installée : _______________

---

**Signature client** : _______________

**Signature technicien** : _______________




