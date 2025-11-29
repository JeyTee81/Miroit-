"""
Script pour générer le script SQL à partir des modèles Django.
Usage: python manage.py generate_sql > schema.sql
"""
from django.core.management import execute_from_command_line
import sys

if __name__ == '__main__':
    # Cette commande nécessite django-extensions installé
    # Commande alternative: python manage.py sqlmigrate --all
    execute_from_command_line(['manage.py', 'inspectdb', '--settings=miroiterie.settings'])






