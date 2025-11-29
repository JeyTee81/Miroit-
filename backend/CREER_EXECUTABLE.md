# Création d'un exécutable pour le backend

Ce guide explique comment créer un exécutable Windows autonome pour le serveur Django.

## Prérequis

- Python 3.10 ou supérieur installé
- Toutes les dépendances installées dans l'environnement virtuel

## Méthode 1 : Script automatique (Recommandé)

1. **Activer l'environnement virtuel** :
   ```cmd
   cd backend
   venv\Scripts\activate
   ```

2. **Lancer le script de build** :
   ```cmd
   python build_exe.py
   ```

   Le script va :
   - Vérifier si PyInstaller est installé (et l'installer si nécessaire)
   - Créer l'exécutable `MiroitBackend.exe` dans le dossier `dist/`

3. **L'exécutable sera créé dans** :
   ```
   backend/dist/MiroitBackend.exe
   ```

## Méthode 2 : Commande manuelle

Si vous préférez utiliser PyInstaller directement :

```cmd
cd backend
venv\Scripts\activate
pip install pyinstaller

pyinstaller --name=MiroitBackend --onefile --windowed ^
    --add-data "miroiterie;miroiterie" ^
    --hidden-import django.core.management ^
    --hidden-import django.core.management.commands.migrate ^
    --hidden-import django.db.backends.sqlite3 ^
    --collect-all django ^
    --collect-all rest_framework ^
    start_server.py
```

## Utilisation de l'exécutable

1. **Copier l'exécutable** où vous voulez (par exemple dans `C:\MiroitBackend\`)

2. **Créer un dossier pour la base de données** (optionnel, mais recommandé) :
   ```
   C:\MiroitBackend\
   ├── MiroitBackend.exe
   └── db\  (sera créé automatiquement)
   ```

3. **Double-cliquer sur `MiroitBackend.exe`**

4. **Au premier lancement** :
   - Le script va créer la base de données SQLite
   - Appliquer toutes les migrations
   - Demander la création d'un superutilisateur
   - Démarrer le serveur sur `http://127.0.0.1:8000`

5. **Lors des lancements suivants** :
   - Le serveur démarre directement

## Notes importantes

- **Taille de l'exécutable** : Environ 50-100 Mo (contient Python et toutes les dépendances)
- **Performance** : L'exécutable peut être légèrement plus lent au démarrage qu'un script Python
- **Base de données** : La base SQLite sera créée dans le même dossier que l'exécutable
- **Logs** : Si vous utilisez `--windowed`, les logs ne seront pas visibles. Utilisez `--console` pour voir les logs

## Personnalisation

### Ajouter une icône

1. Créer ou télécharger un fichier `.ico`
2. Modifier `build_exe.py` :
   ```python
   '--icon=icon.ico',
   ```

### Changer le nom de l'exécutable

Modifier dans `build_exe.py` :
```python
'--name=VotreNom',
```

### Afficher la console (pour voir les logs)

Dans `build_exe.py`, remplacer :
```python
'--windowed',  # Pas de console
```

Par :
```python
# '--windowed',  # Commenté pour afficher la console
```

## Dépannage

### Erreur "Module not found"

Ajouter le module manquant dans `build_exe.py` :
```python
'--hidden-import', 'nom_du_module',
```

### L'exécutable ne démarre pas

1. Vérifier que toutes les dépendances sont installées
2. Tester avec `--console` pour voir les erreurs
3. Vérifier les permissions d'écriture dans le dossier

### Base de données non créée

Vérifier que l'exécutable a les permissions d'écriture dans son dossier.

## Alternative : Service Windows

Pour installer le serveur comme un service Windows qui démarre automatiquement, voir la section "Installation comme service Windows" dans `DEPLOIEMENT.md`.



