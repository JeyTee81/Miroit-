# Script d'installation automatique - Miroît+ Expert
# PowerShell Script pour Windows

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Installation Miroît+ Expert" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier Python
Write-Host "Vérification de Python..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version 2>&1
    Write-Host "✓ Python trouvé: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Python n'est pas installé!" -ForegroundColor Red
    Write-Host "Veuillez installer Python 3.10+ depuis https://www.python.org/downloads/" -ForegroundColor Red
    exit 1
}

# Vérifier Flutter
Write-Host "Vérification de Flutter..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    Write-Host "✓ Flutter trouvé: $flutterVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Flutter n'est pas installé!" -ForegroundColor Red
    Write-Host "Veuillez installer Flutter SDK depuis https://flutter.dev/docs/get-started/install/windows" -ForegroundColor Red
    exit 1
}

# Demander le chemin d'installation
$installPath = Read-Host "Chemin d'installation (par défaut: C:\MiroitExpert)"
if ([string]::IsNullOrWhiteSpace($installPath)) {
    $installPath = "C:\MiroitExpert"
}

# Créer le dossier d'installation
Write-Host "Création du dossier d'installation: $installPath" -ForegroundColor Yellow
if (!(Test-Path $installPath)) {
    New-Item -ItemType Directory -Path $installPath -Force | Out-Null
    Write-Host "✓ Dossier créé" -ForegroundColor Green
} else {
    Write-Host "✓ Dossier existe déjà" -ForegroundColor Green
}

# Copier les fichiers (si nécessaire)
Write-Host ""
Write-Host "Veuillez copier les dossiers 'backend' et 'frontend' dans: $installPath" -ForegroundColor Yellow
Write-Host "Appuyez sur Entrée une fois les fichiers copiés..."
Read-Host

# Installation Backend
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Installation du Backend" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$backendPath = Join-Path $installPath "backend"
if (!(Test-Path $backendPath)) {
    Write-Host "✗ Le dossier backend n'existe pas dans $installPath" -ForegroundColor Red
    exit 1
}

Set-Location $backendPath

# Créer l'environnement virtuel
Write-Host "Création de l'environnement virtuel..." -ForegroundColor Yellow
if (!(Test-Path "venv")) {
    python -m venv venv
    Write-Host "✓ Environnement virtuel créé" -ForegroundColor Green
} else {
    Write-Host "✓ Environnement virtuel existe déjà" -ForegroundColor Green
}

# Activer l'environnement virtuel
Write-Host "Activation de l'environnement virtuel..." -ForegroundColor Yellow
& ".\venv\Scripts\Activate.ps1"

# Installer les dépendances
Write-Host "Installation des dépendances Python..." -ForegroundColor Yellow
pip install --upgrade pip
pip install -r requirements.txt
Write-Host "✓ Dépendances installées" -ForegroundColor Green

# Appliquer les migrations
Write-Host "Application des migrations..." -ForegroundColor Yellow
python manage.py migrate
Write-Host "✓ Migrations appliquées" -ForegroundColor Green

# Créer le superutilisateur
Write-Host ""
Write-Host "Création du superutilisateur..." -ForegroundColor Yellow
Write-Host "Veuillez entrer les informations du superutilisateur:" -ForegroundColor Yellow
python manage.py createsuperuser

# Initialiser les données
Write-Host "Initialisation des données de référence..." -ForegroundColor Yellow
try {
    python manage.py init_vitrages_data
    Write-Host "✓ Données initialisées" -ForegroundColor Green
} catch {
    Write-Host "⚠ Commande init_vitrages_data non disponible (normal si module non installé)" -ForegroundColor Yellow
}

# Installation Frontend
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Installation du Frontend" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$frontendPath = Join-Path $installPath "frontend"
if (!(Test-Path $frontendPath)) {
    Write-Host "✗ Le dossier frontend n'existe pas dans $installPath" -ForegroundColor Red
    exit 1
}

Set-Location $frontendPath

# Installer les dépendances Flutter
Write-Host "Installation des dépendances Flutter..." -ForegroundColor Yellow
flutter pub get
Write-Host "✓ Dépendances Flutter installées" -ForegroundColor Green

# Créer les scripts de démarrage
Write-Host ""
Write-Host "Création des scripts de démarrage..." -ForegroundColor Yellow

# Script démarrage backend
$startBackendScript = @"
@echo off
cd /d "$backendPath"
call venv\Scripts\activate
python manage.py runserver 0.0.0.0:8000
pause
"@
$startBackendScript | Out-File -FilePath (Join-Path $installPath "start_backend.bat") -Encoding ASCII

# Script démarrage frontend
$startFrontendScript = @"
@echo off
cd /d "$frontendPath"
flutter run -d windows
pause
"@
$startFrontendScript | Out-File -FilePath (Join-Path $installPath "start_frontend.bat") -Encoding ASCII

Write-Host "✓ Scripts créés" -ForegroundColor Green

# Résumé
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Installation terminée!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Pour démarrer l'application:" -ForegroundColor Yellow
Write-Host "1. Double-cliquer sur 'start_backend.bat' dans $installPath" -ForegroundColor White
Write-Host "2. Attendre que le serveur démarre (http://localhost:8000)" -ForegroundColor White
Write-Host "3. Double-cliquer sur 'start_frontend.bat' dans $installPath" -ForegroundColor White
Write-Host ""
Write-Host "Documentation:" -ForegroundColor Yellow
Write-Host "- Guide complet: DEPLOIEMENT.md" -ForegroundColor White
Write-Host "- Guide rapide: INSTALLATION_RAPIDE.md" -ForegroundColor White
Write-Host ""

Read-Host "Appuyez sur Entrée pour quitter"




