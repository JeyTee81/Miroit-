import time
import logging
from django.utils.deprecation import MiddlewareMixin
from django.contrib.auth import get_user_model

logger = logging.getLogger(__name__)


class RequestLoggingMiddleware(MiddlewareMixin):
    """Middleware pour logger automatiquement les requêtes HTTP"""
    
    def process_request(self, request):
        """Enregistre le début de la requête"""
        request._start_time = time.time()
        return None
    
    def process_response(self, request, response):
        """Enregistre la fin de la requête et crée un log"""
        if hasattr(request, '_start_time'):
            response_time = (time.time() - request._start_time) * 1000  # en millisecondes
            
            # Récupérer l'utilisateur
            user = None
            if hasattr(request, 'user') and request.user.is_authenticated:
                user = request.user
            
            # Déterminer le niveau de log selon le statut de la réponse
            # Note: Les erreurs 500 sont déjà loggées par l'exception handler DRF avec le traceback
            # On les logge quand même ici pour avoir les infos de requête, mais sans traceback
            if response.status_code >= 500:
                level = 'ERROR'
            elif response.status_code >= 400:
                level = 'WARNING'
            else:
                level = 'INFO'
            
            # Extraire les détails d'erreur depuis la réponse si c'est une erreur
            exception_type = None
            exception_message = None
            traceback_text = None
            
            if response.status_code >= 400:
                # Essayer d'extraire les détails depuis le body de la réponse
                try:
                    if hasattr(response, 'data') and isinstance(response.data, dict):
                        # Réponse DRF
                        if 'detail' in response.data:
                            exception_message = str(response.data['detail'])
                        elif 'error' in response.data:
                            exception_message = str(response.data['error'])
                        elif 'message' in response.data:
                            exception_message = str(response.data['message'])
                        
                        # Extraire le type d'exception si disponible
                        if 'exception_type' in response.data:
                            exception_type = str(response.data['exception_type'])
                except Exception:
                    pass
            
            # Logger la requête
            logger.log(
                getattr(logging, level),
                f"{request.method} {request.path} - {response.status_code}",
                extra={
                    'request_method': request.method,
                    'request_path': request.path,
                    'request_user': user,
                    'response_status': response.status_code,
                    'response_time_ms': response_time,
                    'ip_address': self.get_client_ip(request),
                    'user_agent': request.META.get('HTTP_USER_AGENT', ''),
                    'exception_type': exception_type,
                    'exception_message': exception_message,
                }
            )
        
        return response
    
    def process_exception(self, request, exception):
        """Enregistre les exceptions non gérées"""
        user = None
        if hasattr(request, 'user') and request.user.is_authenticated:
            user = request.user
        
        logger.exception(
            f"Exception non gérée: {request.method} {request.path}",
            extra={
                'request_method': request.method,
                'request_path': request.path,
                'request_user': user,
                'exception_type': type(exception).__name__,
                'exception_message': str(exception),
                'ip_address': self.get_client_ip(request),
                'user_agent': request.META.get('HTTP_USER_AGENT', ''),
            }
        )
        return None
    
    def get_client_ip(self, request):
        """Récupère l'adresse IP du client"""
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            ip = x_forwarded_for.split(',')[0]
        else:
            ip = request.META.get('REMOTE_ADDR')
        return ip

