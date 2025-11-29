from django.contrib import admin
from .models import User, Group


@admin.register(Group)
class GroupAdmin(admin.ModelAdmin):
    list_display = ['nom', 'actif', 'created_at']
    list_filter = ['actif']
    search_fields = ['nom', 'description']
    fieldsets = (
        ('Informations', {
            'fields': ('nom', 'description', 'actif')
        }),
        ('Permissions modules', {
            'fields': (
                'acces_commerciale', 'acces_menuiserie', 'acces_vitrages',
                'acces_optimisation', 'acces_stock', 'acces_travaux',
                'acces_planning', 'acces_tournees', 'acces_crm',
                'acces_inertie', 'acces_parametres', 'acces_logs',
            )
        }),
    )


@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ['username', 'email', 'nom', 'prenom', 'role', 'groupe', 'actif']
    list_filter = ['role', 'groupe', 'actif']
    search_fields = ['username', 'email', 'nom', 'prenom']
