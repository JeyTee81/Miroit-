from rest_framework import viewsets, filters, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from django_filters.rest_framework import DjangoFilterBackend
from django.utils import timezone
from datetime import timedelta
from django.db.models import Q, Count
from django.db.models.functions import TruncDate

from .models import LogEntry
from .serializers import LogEntrySerializer, LogEntrySummarySerializer


class LogEntryViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet pour consulter les logs"""
    
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['level', 'logger_name', 'request_method', 'response_status']
    search_fields = ['message', 'module', 'function', 'request_path']
    ordering_fields = ['created_at', 'level', 'logger_name']
    ordering = ['-created_at']
    
    def get_queryset(self):
        """Retourne le queryset avec filtres optionnels"""
        queryset = LogEntry.objects.all()
        
        # Filtre par date (dernières 24h, 7 jours, 30 jours, ou personnalisé)
        date_filter = self.request.query_params.get('date_filter', None)
        if date_filter:
            now = timezone.now()
            if date_filter == '24h':
                queryset = queryset.filter(created_at__gte=now - timedelta(hours=24))
            elif date_filter == '7d':
                queryset = queryset.filter(created_at__gte=now - timedelta(days=7))
            elif date_filter == '30d':
                queryset = queryset.filter(created_at__gte=now - timedelta(days=30))
        
        # Filtre par niveau d'erreur uniquement
        errors_only = self.request.query_params.get('errors_only', None)
        if errors_only == 'true':
            queryset = queryset.filter(level__in=['ERROR', 'CRITICAL'])
        
        # Filtre par utilisateur
        user_id = self.request.query_params.get('user_id', None)
        if user_id:
            queryset = queryset.filter(request_user_id=user_id)
        
        return queryset.select_related('request_user')
    
    def get_serializer_class(self):
        """Retourne le serializer approprié selon l'action"""
        if self.action == 'list':
            return LogEntrySummarySerializer
        return LogEntrySerializer
    
    @action(detail=False, methods=['get'])
    def stats(self, request):
        """Retourne des statistiques sur les logs"""
        queryset = self.get_queryset()
        
        # Statistiques par niveau
        level_stats = queryset.values('level').annotate(
            count=Count('id')
        ).order_by('level')
        
        # Statistiques par jour (derniers 7 jours)
        seven_days_ago = timezone.now() - timedelta(days=7)
        daily_stats = queryset.filter(
            created_at__gte=seven_days_ago
        ).annotate(
            date=TruncDate('created_at')
        ).values('date', 'level').annotate(
            count=Count('id')
        ).order_by('date', 'level')
        
        # Top 10 des erreurs les plus fréquentes
        top_errors = queryset.filter(
            level__in=['ERROR', 'CRITICAL']
        ).values('logger_name', 'message').annotate(
            count=Count('id')
        ).order_by('-count')[:10]
        
        # Statistiques par endpoint (derniers 7 jours)
        endpoint_stats = queryset.filter(
            created_at__gte=seven_days_ago,
            request_path__isnull=False
        ).values('request_path', 'request_method').annotate(
            count=Count('id'),
            error_count=Count('id', filter=Q(level__in=['ERROR', 'CRITICAL']))
        ).order_by('-count')[:20]
        
        return Response({
            'level_stats': list(level_stats),
            'daily_stats': list(daily_stats),
            'top_errors': list(top_errors),
            'endpoint_stats': list(endpoint_stats),
            'total_logs': queryset.count(),
            'error_logs': queryset.filter(level__in=['ERROR', 'CRITICAL']).count(),
        })
    
    @action(detail=False, methods=['delete'])
    def clear_old_logs(self, request):
        """Supprime les logs plus anciens que X jours"""
        days = int(request.query_params.get('days', 30))
        cutoff_date = timezone.now() - timedelta(days=days)
        
        deleted_count, _ = LogEntry.objects.filter(
            created_at__lt=cutoff_date
        ).delete()
        
        return Response({
            'message': f'{deleted_count} logs supprimés (plus anciens que {days} jours)',
            'deleted_count': deleted_count
        })
    
    @action(detail=True, methods=['get'])
    def traceback(self, request, pk=None):
        """Retourne le traceback complet d'une erreur"""
        log_entry = self.get_object()
        if not log_entry.traceback:
            return Response({
                'message': 'Aucun traceback disponible pour ce log'
            }, status=status.HTTP_404_NOT_FOUND)
        
        return Response({
            'id': str(log_entry.id),
            'level': log_entry.level,
            'message': log_entry.message,
            'exception_type': log_entry.exception_type,
            'exception_message': log_entry.exception_message,
            'traceback': log_entry.traceback,
            'created_at': log_entry.created_at,
        })
    
    @action(detail=False, methods=['post'], permission_classes=[AllowAny])
    def create_frontend_log(self, request):
        """Endpoint pour créer un log depuis le frontend (sans authentification requise)"""
        from .models import LogEntry
        
        data = request.data.copy()
        
        # Extraire les informations de la requête
        user = request.user if request.user.is_authenticated else None
        
        # Créer le log
        log_entry = LogEntry.objects.create(
            level=data.get('level', 'ERROR'),
            logger_name=data.get('logger_name', 'frontend'),
            message=data.get('message', ''),
            module=data.get('module'),
            function=data.get('function'),
            line_number=data.get('line_number'),
            request_method=data.get('request_method'),
            request_path=data.get('request_path'),
            request_user=user,
            response_status=data.get('response_status'),
            response_time_ms=data.get('response_time_ms'),
            exception_type=data.get('exception_type'),
            exception_message=data.get('exception_message'),
            traceback=data.get('traceback'),
            ip_address=self._get_client_ip(request),
            user_agent=request.META.get('HTTP_USER_AGENT', ''),
            extra_data=data.get('extra_data'),
        )
        
        serializer = LogEntrySerializer(log_entry)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    
    def _get_client_ip(self, request):
        """Récupère l'adresse IP du client"""
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            ip = x_forwarded_for.split(',')[0]
        else:
            ip = request.META.get('REMOTE_ADDR')
        return ip
