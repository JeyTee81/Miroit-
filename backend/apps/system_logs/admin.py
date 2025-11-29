from django.contrib import admin
from .models import LogEntry


@admin.register(LogEntry)
class LogEntryAdmin(admin.ModelAdmin):
    """Admin pour les entrées de log"""
    
    list_display = ['created_at', 'level', 'logger_name']
    list_filter = ['level', 'created_at']
    search_fields = ['message', 'logger_name']
    readonly_fields = [
        'id', 'created_at', 'level', 'logger_name', 'message', 'module',
        'function', 'line_number', 'request_method', 'request_path',
        'request_user', 'response_status', 'response_time_ms',
        'exception_type', 'exception_message', 'traceback',
        'ip_address', 'user_agent', 'extra_data'
    ]
    
    def has_add_permission(self, request):
        """Les logs ne peuvent pas être créés manuellement"""
        return False
    
    def has_change_permission(self, request, obj=None):
        """Les logs ne peuvent pas être modifiés"""
        return False
    
    def has_delete_permission(self, request, obj=None):
        """Permettre la suppression pour nettoyer les anciens logs"""
        return True
