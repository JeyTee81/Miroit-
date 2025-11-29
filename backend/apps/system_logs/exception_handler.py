import logging
import traceback
from rest_framework.views import exception_handler
from rest_framework.response import Response
from rest_framework import status

# Utiliser le logger racine pour s'assurer que le DatabaseLogHandler capture les logs
logger = logging.getLogger()


def custom_exception_handler(exc, context):
    """
    Handler personnalisé pour les exceptions DRF qui logge les erreurs avec le traceback complet
    """
    # Appeler le handler par défaut de DRF pour obtenir la réponse standard
    response = exception_handler(exc, context)
    
    if response is not None:
        # Extraire les informations de la requête
        request = context.get('request')
        view = context.get('view')
        
        # Récupérer l'utilisateur
        user = None
        if request and hasattr(request, 'user') and request.user.is_authenticated:
            user = request.user
        
        # Calculer le temps de réponse si disponible
        response_time_ms = None
        if request and hasattr(request, '_start_time'):
            import time
            response_time_ms = (time.time() - request._start_time) * 1000
        
        # Récupérer l'IP et le user agent
        ip_address = None
        user_agent = None
        if request:
            x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
            if x_forwarded_for:
                ip_address = x_forwarded_for.split(',')[0]
            else:
                ip_address = request.META.get('REMOTE_ADDR')
            user_agent = request.META.get('HTTP_USER_AGENT', '')
        
        # Construire le message d'erreur
        error_message = str(exc)
        if hasattr(response, 'data') and isinstance(response.data, dict):
            if 'detail' in response.data:
                error_message = str(response.data['detail'])
            elif 'error' in response.data:
                error_message = str(response.data['error'])
            elif 'message' in response.data:
                error_message = str(response.data['message'])
        
        # Logger l'exception avec le traceback complet
        logger.exception(
            f"Exception DRF: {request.method if request else 'UNKNOWN'} {request.path if request else 'UNKNOWN'} - {type(exc).__name__}",
            exc_info=True,
            extra={
                'request_method': request.method if request else None,
                'request_path': request.path if request else None,
                'request_user': user,
                'response_status': response.status_code,
                'response_time_ms': response_time_ms,
                'exception_type': type(exc).__name__,
                'exception_message': error_message,
                'view_class': view.__class__.__name__ if view else None,
                'ip_address': ip_address,
                'user_agent': user_agent,
            }
        )
    
    return response

