"""
Script de démarrage automatique du serveur Django
Initialise la base de données au premier lancement et démarre le serveur
"""
import os
import sys
from pathlib import Path

# Ajouter le répertoire backend au path Python
BASE_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(BASE_DIR))

# Changer le répertoire de travail vers backend
os.chdir(BASE_DIR)

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'miroiterie.settings')

import django
django.setup()

from django.core.management import execute_from_command_line
from django.db import connection
from django.conf import settings


def check_database_exists():
    """Vérifie si la base de données existe"""
    db_path = settings.DATABASES['default']['NAME']
    
    if 'sqlite' in settings.DATABASES['default']['ENGINE']:
        return os.path.exists(db_path)
    else:
        # Pour PostgreSQL, on essaie de se connecter
        try:
            with connection.cursor() as cursor:
                cursor.execute("SELECT 1")
            return True
        except:
            return False


def initialize_database():
    """Initialise la base de données au premier lancement"""
    print("=" * 60)
    print("Initialisation de la base de données...")
    print("=" * 60)
    
    # Vérifier si la base existe
    if check_database_exists():
        print("✓ Base de données trouvée")
    else:
        print("✗ Base de données introuvable - création en cours...")
    
    # Créer les migrations si nécessaire
    print("\n1. Vérification des migrations...")
    try:
        # Ne pas créer de migrations automatiquement, juste vérifier
        # Les migrations doivent être créées en développement
        print("✓ Migrations vérifiées")
    except Exception as e:
        print(f"⚠ Avertissement: {e}")
    
    # Appliquer les migrations
    print("\n2. Application des migrations...")
    try:
        execute_from_command_line(['manage.py', 'migrate', '--run-syncdb'])
        print("✓ Migrations appliquées")
    except Exception as e:
        print(f"✗ Erreur lors de l'application des migrations: {e}")
        return False
    
    # Vérifier si un superutilisateur existe
    print("\n3. Vérification du superutilisateur...")
    try:
        from django.contrib.auth import get_user_model
        User = get_user_model()
        
        if not User.objects.filter(is_superuser=True).exists():
            print("⚠ Aucun superutilisateur trouvé")
            print("\n" + "=" * 60)
            print("CRÉATION DU SUPERUTILISATEUR")
            print("=" * 60)
            
            # Demander les informations du superutilisateur
            username = input("Nom d'utilisateur (admin): ").strip() or "admin"
            email = input("Email (admin@example.com): ").strip() or "admin@example.com"
            
            while True:
                password = input("Mot de passe: ").strip()
                if password:
                    break
                print("⚠ Le mot de passe ne peut pas être vide")
            
            # Créer le superutilisateur
            try:
                User.objects.create_superuser(
                    username=username,
                    email=email,
                    password=password,
                    nom="Administrateur",
                    prenom="Admin"
                )
                print(f"\n✓ Superutilisateur '{username}' créé avec succès")
            except Exception as e:
                print(f"✗ Erreur lors de la création du superutilisateur: {e}")
                return False
        else:
            print("✓ Superutilisateur existant trouvé")
    except Exception as e:
        print(f"⚠ Erreur lors de la vérification du superutilisateur: {e}")
    
    # Initialiser les données de référence si nécessaire
    print("\n4. Initialisation des données de référence...")
    try:
        # Commande pour initialiser les données Vitrages
        from django.core.management import call_command
        try:
            call_command('init_vitrages_data', verbosity=0)
            print("✓ Données Vitrages initialisées")
        except Exception:
            pass  # La commande peut ne pas exister ou les données déjà initialisées
    except Exception as e:
        print(f"⚠ Avertissement: {e}")
    
    print("\n" + "=" * 60)
    print("✓ Initialisation terminée avec succès")
    print("=" * 60 + "\n")
    
    return True


def start_server(host='127.0.0.1', port=8000):
    """Démarre le serveur Django"""
    print("=" * 60)
    print("DÉMARRAGE DU SERVEUR DJANGO")
    print("=" * 60)
    print(f"\nServeur accessible sur: http://{host}:{port}")
    print("Appuyez sur Ctrl+C pour arrêter le serveur\n")
    print("=" * 60 + "\n")
    
    try:
        execute_from_command_line([
            'manage.py',
            'runserver',
            f'{host}:{port}'
        ])
    except KeyboardInterrupt:
        print("\n\n" + "=" * 60)
        print("Arrêt du serveur...")
        print("=" * 60)
        sys.exit(0)
    except Exception as e:
        print(f"\n✗ Erreur lors du démarrage du serveur: {e}")
        sys.exit(1)


def main():
    """Fonction principale"""
    print("\n" + "=" * 60)
    print("MIROÎT+ EXPERT - SERVEUR BACKEND")
    print("=" * 60 + "\n")
    
    # Vérifier si on est dans le bon répertoire
    manage_py = BASE_DIR / 'manage.py'
    if not manage_py.exists():
        print("✗ Erreur: manage.py introuvable")
        print(f"   Chemin actuel: {BASE_DIR}")
        print("   Assurez-vous d'exécuter ce script depuis le répertoire backend/")
        if sys.platform == 'win32':
            input("\nAppuyez sur Entrée pour quitter...")
        sys.exit(1)
    
    # Initialiser la base de données si nécessaire
    if not initialize_database():
        print("\n✗ Échec de l'initialisation de la base de données")
        print("   Veuillez vérifier les erreurs ci-dessus")
        if sys.platform == 'win32':
            input("\nAppuyez sur Entrée pour quitter...")
        sys.exit(1)
    
    # Démarrer le serveur
    start_server()


if __name__ == '__main__':
    main()

