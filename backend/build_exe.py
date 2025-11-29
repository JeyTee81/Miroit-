"""
Script pour créer un exécutable Windows du serveur Django
Utilise PyInstaller pour créer un .exe autonome
"""
import os
import sys
import subprocess
from pathlib import Path

def check_pyinstaller():
    """Vérifie si PyInstaller est installé"""
    try:
        import PyInstaller
        return True
    except ImportError:
        return False

def install_pyinstaller():
    """Installe PyInstaller"""
    print("Installation de PyInstaller...")
    subprocess.check_call([sys.executable, '-m', 'pip', 'install', 'pyinstaller'])

def build_exe():
    """Crée l'exécutable"""
    BASE_DIR = Path(__file__).resolve().parent
    
    print("=" * 60)
    print("CRÉATION DE L'EXÉCUTABLE")
    print("=" * 60)
    
    # Vérifier PyInstaller
    if not check_pyinstaller():
        print("PyInstaller n'est pas installé. Installation...")
        install_pyinstaller()
    
    # Options PyInstaller
    # Note: Utiliser --console pour voir les logs (recommandé pour le débogage)
    # Utiliser --windowed pour masquer la console (production)
    options = [
        'pyinstaller',
        '--name=MiroitBackend',
        '--onefile',  # Un seul fichier exécutable
        '--console',  # Afficher la console pour voir les logs (changer en --windowed pour masquer)
        # '--icon=icon.ico',  # Décommenter et ajouter une icône si disponible
        '--add-data', f'{BASE_DIR}/miroiterie;miroiterie',  # Inclure les settings
        '--hidden-import', 'django.core.management',
        '--hidden-import', 'django.core.management.commands.migrate',
        '--hidden-import', 'django.db.backends.sqlite3',
        '--hidden-import', 'django.contrib.auth',
        '--hidden-import', 'django.contrib.contenttypes',
        '--hidden-import', 'django.contrib.sessions',
        '--hidden-import', 'django.contrib.messages',
        '--collect-all', 'django',
        '--collect-all', 'rest_framework',
        '--collect-all', 'django_filters',
        'start_server.py',
    ]
    
    print("\nCompilation en cours...")
    print("(Cela peut prendre plusieurs minutes)\n")
    
    try:
        subprocess.check_call(options, cwd=str(BASE_DIR))
        print("\n" + "=" * 60)
        print("✓ EXÉCUTABLE CRÉÉ AVEC SUCCÈS")
        print("=" * 60)
        print(f"\nFichier créé: {BASE_DIR}/dist/MiroitBackend.exe")
        print("\nVous pouvez maintenant distribuer cet exécutable.")
    except subprocess.CalledProcessError as e:
        print(f"\n✗ Erreur lors de la création de l'exécutable: {e}")
        sys.exit(1)

if __name__ == '__main__':
    build_exe()

