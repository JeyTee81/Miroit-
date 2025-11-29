import logging
import traceback
from django.utils import timezone
from .models import LogEntry


class DatabaseLogHandler(logging.Handler):
    """Handler personnalisé pour écrire les logs dans la base de données"""
    
    def emit(self, record):
        """Écrit le log dans la base de données"""
        try:
            # Extraire les informations de la requête HTTP si disponibles
            request_method = getattr(record, 'request_method', None)
            request_path = getattr(record, 'request_path', None)
            request_user = getattr(record, 'request_user', None)
            response_status = getattr(record, 'response_status', None)
            response_time_ms = getattr(record, 'response_time_ms', None)
            ip_address = getattr(record, 'ip_address', None)
            user_agent = getattr(record, 'user_agent', None)
            
            # Extraire les informations sur l'exception si disponible
            exception_type = getattr(record, 'exception_type', None)
            exception_message = getattr(record, 'exception_message', None)
            traceback_text = None
            
            # Priorité aux informations depuis exc_info (traceback complet)
            if record.exc_info:
                exception_type = record.exc_info[0].__name__ if record.exc_info[0] else exception_type
                exception_message = str(record.exc_info[1]) if record.exc_info[1] else exception_message
                traceback_text = ''.join(traceback.format_exception(*record.exc_info))
            # Sinon, utiliser les informations depuis les champs extra (passés par le middleware)
            elif exception_type or exception_message:
                # Construire un message d'exception basique si on a les infos mais pas de traceback
                if exception_type and exception_message:
                    traceback_text = f"{exception_type}: {exception_message}"
            
            # Extraire les informations sur le module/fonction
            module = record.module if hasattr(record, 'module') else None
            function = record.funcName if hasattr(record, 'funcName') else None
            line_number = record.lineno if hasattr(record, 'lineno') else None
            
            # Construire le dictionnaire extra_data
            extra_data = {}
            for key, value in record.__dict__.items():
                if key not in [
                    'name', 'msg', 'args', 'created', 'filename', 'funcName',
                    'levelname', 'levelno', 'lineno', 'module', 'msecs',
                    'message', 'pathname', 'process', 'processName', 'relativeCreated',
                    'thread', 'threadName', 'exc_info', 'exc_text', 'stack_info',
                    'request_method', 'request_path', 'request_user', 'response_status',
                    'response_time_ms', 'ip_address', 'user_agent',
                    'exception_type', 'exception_message',
                ]:
                    try:
                        # Essayer de sérialiser la valeur
                        import json
                        json.dumps(value)
                        extra_data[key] = value
                    except (TypeError, ValueError):
                        extra_data[key] = str(value)
            
            # Créer l'entrée de log
            LogEntry.objects.create(
                level=record.levelname,
                logger_name=record.name,
                message=record.getMessage(),
                module=module,
                function=function,
                line_number=line_number,
                request_method=request_method,
                request_path=request_path,
                request_user=request_user,
                response_status=response_status,
                response_time_ms=response_time_ms,
                exception_type=exception_type,
                exception_message=exception_message,
                traceback=traceback_text,
                ip_address=ip_address,
                user_agent=user_agent,
                extra_data=extra_data if extra_data else None,
            )
        except Exception as e:
            # En cas d'erreur lors de l'écriture du log, on ne fait rien
            # pour éviter une boucle infinie de logs
            pass

