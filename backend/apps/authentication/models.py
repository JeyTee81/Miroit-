from django.contrib.auth.models import AbstractUser
from django.db import models
import uuid


class Group(models.Model):
    """Groupe d'utilisateurs avec permissions par module"""
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    nom = models.CharField(max_length=100, unique=True)
    description = models.TextField(blank=True, null=True)
    
    # Permissions par module (True = accès autorisé)
    acces_commerciale = models.BooleanField(default=False)
    acces_menuiserie = models.BooleanField(default=False)
    acces_vitrages = models.BooleanField(default=False)
    acces_optimisation = models.BooleanField(default=False)
    acces_stock = models.BooleanField(default=False)
    acces_travaux = models.BooleanField(default=False)
    acces_planning = models.BooleanField(default=False)
    acces_tournees = models.BooleanField(default=False)
    acces_crm = models.BooleanField(default=False)
    acces_inertie = models.BooleanField(default=False)
    acces_parametres = models.BooleanField(default=False)
    acces_logs = models.BooleanField(default=False)
    
    actif = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'user_groups'
        verbose_name = 'Groupe'
        verbose_name_plural = 'Groupes'
        ordering = ['nom']

    def __str__(self):
        return self.nom
    
    def get_modules_accessibles(self):
        """Retourne la liste des modules accessibles"""
        modules = []
        if self.acces_commerciale:
            modules.append('commerciale')
        if self.acces_menuiserie:
            modules.append('menuiserie')
        if self.acces_vitrages:
            modules.append('vitrages')
        if self.acces_optimisation:
            modules.append('optimisation')
        if self.acces_stock:
            modules.append('stock')
        if self.acces_travaux:
            modules.append('travaux')
        if self.acces_planning:
            modules.append('planning')
        if self.acces_tournees:
            modules.append('tournees')
        if self.acces_crm:
            modules.append('crm')
        if self.acces_inertie:
            modules.append('inertie')
        if self.acces_parametres:
            modules.append('parametres')
        if self.acces_logs:
            modules.append('logs')
        return modules


class User(AbstractUser):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    nom = models.CharField(max_length=100)
    prenom = models.CharField(max_length=100)
    role = models.CharField(
        max_length=20,
        choices=[
            ('admin', 'Administrateur'),
            ('commercial', 'Commercial'),
            ('atelier', 'Service technique'),
            ('ouvrier', 'Ouvrier'),
            ('logistique', 'Logistique'),
            ('comptable', 'Comptable'),
        ],
        default='commercial'
    )
    groupe = models.ForeignKey(
        Group,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='users'
    )
    actif = models.BooleanField(default=True)
    last_login = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'users'
        verbose_name = 'Utilisateur'
        verbose_name_plural = 'Utilisateur'

    def __str__(self):
        return f"{self.prenom} {self.nom} ({self.role})"
    
    def get_modules_accessibles(self):
        """Retourne la liste des modules accessibles pour cet utilisateur"""
        # Superutilisateur a accès à tout
        if self.is_superuser:
            return [
                'commerciale', 'menuiserie', 'vitrages', 'optimisation',
                'stock', 'travaux', 'planning', 'tournees', 'crm',
                'inertie', 'parametres', 'logs'
            ]
        
        # Si l'utilisateur a un groupe, utiliser les permissions du groupe
        if self.groupe:
            return self.groupe.get_modules_accessibles()
        
        # Sinon, utiliser les permissions par défaut selon le rôle (pour compatibilité)
        return []





