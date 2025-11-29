from django.db import models
from django.conf import settings
import uuid


class LogEntry(models.Model):
    """Modèle pour stocker les logs de l'application"""
    
    LEVEL_CHOICES = [
        ('DEBUG', 'Debug'),
        ('INFO', 'Information'),
        ('WARNING', 'Avertissement'),
        ('ERROR', 'Erreur'),
        ('CRITICAL', 'Critique'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    level = models.CharField(max_length=10, choices=LEVEL_CHOICES, db_index=True)
    logger_name = models.CharField(max_length=255, db_index=True)
    message = models.TextField()
    module = models.CharField(max_length=255, null=True, blank=True, db_index=True)
    function = models.CharField(max_length=255, null=True, blank=True)
    line_number = models.IntegerField(null=True, blank=True)
    
    # Informations sur la requête HTTP (si applicable)
    request_method = models.CharField(max_length=10, null=True, blank=True)
    request_path = models.CharField(max_length=500, null=True, blank=True, db_index=True)
    request_user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='log_entries'
    )
    response_status = models.IntegerField(null=True, blank=True, db_index=True)
    response_time_ms = models.FloatField(null=True, blank=True)
    
    # Informations sur l'exception (si applicable)
    exception_type = models.CharField(max_length=255, null=True, blank=True)
    exception_message = models.TextField(null=True, blank=True)
    traceback = models.TextField(null=True, blank=True)
    
    # Informations système
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    user_agent = models.TextField(null=True, blank=True)
    
    # Métadonnées
    extra_data = models.JSONField(default=None, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)
    
    class Meta:
        db_table = 'log_entries'
        verbose_name = 'Entrée de log'
        verbose_name_plural = 'Entrées de log'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['-created_at', 'level']),
            models.Index(fields=['level', 'created_at']),
            models.Index(fields=['logger_name', 'created_at']),
        ]
    
    def __str__(self):
        if self.message:
            msg = self.message[:100] if len(self.message) > 100 else self.message
            return f"[{self.level}] {self.logger_name} - {msg}"
        return f"[{self.level}] {self.logger_name}"
    
    @property
    def is_error(self):
        """Retourne True si le log est une erreur ou critique"""
        return self.level in ['ERROR', 'CRITICAL']
    
    @property
    def short_message(self):
        """Retourne un message tronqué"""
        if not self.message:
            return ''
        return self.message[:200] + '...' if len(self.message) > 200 else self.message
