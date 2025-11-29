from rest_framework import serializers
from .models import LogEntry


class LogEntrySerializer(serializers.ModelSerializer):
    """Serializer pour les entrées de log"""
    
    request_user_name = serializers.SerializerMethodField()
    is_error = serializers.ReadOnlyField()
    short_message = serializers.ReadOnlyField()
    
    class Meta:
        model = LogEntry
        fields = [
            'id',
            'level',
            'logger_name',
            'message',
            'module',
            'function',
            'line_number',
            'request_method',
            'request_path',
            'request_user',
            'request_user_name',
            'response_status',
            'response_time_ms',
            'exception_type',
            'exception_message',
            'traceback',
            'ip_address',
            'user_agent',
            'extra_data',
            'created_at',
            'is_error',
            'short_message',
        ]
        read_only_fields = ['id', 'created_at']
    
    def get_request_user_name(self, obj):
        """Retourne le nom de l'utilisateur qui a fait la requête"""
        if obj.request_user:
            return f"{obj.request_user.prenom} {obj.request_user.nom}"
        return None


class LogEntrySummarySerializer(serializers.ModelSerializer):
    """Serializer simplifié pour les listes de logs"""
    
    request_user_name = serializers.SerializerMethodField()
    is_error = serializers.ReadOnlyField()
    short_message = serializers.ReadOnlyField()
    
    class Meta:
        model = LogEntry
        fields = [
            'id',
            'level',
            'logger_name',
            'short_message',
            'request_method',
            'request_path',
            'request_user_name',
            'response_status',
            'exception_type',
            'created_at',
            'is_error',
        ]
    
    def get_request_user_name(self, obj):
        """Retourne le nom de l'utilisateur qui a fait la requête"""
        if obj.request_user:
            return f"{obj.request_user.prenom} {obj.request_user.nom}"
        return None

