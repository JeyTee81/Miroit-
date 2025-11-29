@echo off
REM Script batch pour démarrer le serveur Django sur Windows
REM Ce script peut être utilisé si Python est installé

echo ============================================================
echo MIROIT+ EXPERT - SERVEUR BACKEND
echo ============================================================
echo.

REM Vérifier si Python est disponible
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Python n'est pas installe ou n'est pas dans le PATH
    echo.
    echo Veuillez installer Python 3.10 ou superieur depuis https://www.python.org/
    echo Assurez-vous de cocher "Add Python to PATH" lors de l'installation
    echo.
    pause
    exit /b 1
)

REM Activer l'environnement virtuel si il existe
if exist "venv\Scripts\activate.bat" (
    echo Activation de l'environnement virtuel...
    call venv\Scripts\activate.bat
)

REM Lancer le script de démarrage
echo Demarrage du serveur...
echo.
python start_server.py

pause



