from django.apps import AppConfig
from django.db import connection


class SystemLogsConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.system_logs'
    
    def ready(self):
        """Configure le handler de logs après le chargement de l'app"""
        try:
            # Vérifier si la table existe
            with connection.cursor() as cursor:
                # Utiliser une requête générique qui fonctionne avec SQLite et PostgreSQL
                if connection.vendor == 'sqlite':
                    cursor.execute("""
                        SELECT name FROM sqlite_master 
                        WHERE type='table' AND name='log_entries'
                    """)
                else:
                    cursor.execute("""
                        SELECT table_name FROM information_schema.tables 
                        WHERE table_name='log_entries'
                    """)
                table_exists = cursor.fetchone() is not None
            
            if table_exists:
                from .handlers import DatabaseLogHandler
                import logging
                
                # Ajouter le handler au logger racine et à django.request
                root_logger = logging.getLogger()
                django_request_logger = logging.getLogger('django.request')
                
                # Vérifier si le handler n'existe pas déjà
                handler_exists = any(
                    isinstance(h, DatabaseLogHandler) 
                    for h in root_logger.handlers
                )
                if not handler_exists:
                    db_handler = DatabaseLogHandler()
                    db_handler.setLevel(logging.WARNING)  # Capturer WARNING, ERROR et CRITICAL
                    formatter = logging.Formatter(
                        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
                    )
                    db_handler.setFormatter(formatter)
                    root_logger.addHandler(db_handler)
                    # Ajouter aussi au logger django.request pour capturer les erreurs HTTP
                    django_request_logger.addHandler(db_handler)
        except Exception:
            # Si les tables n'existent pas encore ou autre erreur, on ignore
            pass
