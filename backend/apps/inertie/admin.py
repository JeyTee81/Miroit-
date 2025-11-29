from django.contrib import admin
from .models import (
    FamilleMateriau,
    Profil,
    Projet,
    CalculRaidisseur,
    CalculTraverse,
    CalculEI,
    Configuration
)


@admin.register(FamilleMateriau)
class FamilleMateriauAdmin(admin.ModelAdmin):
    list_display = ('nom', 'module_elasticite', 'actif', 'created_at')
    list_filter = ('actif',)
    search_fields = ('nom',)


@admin.register(Profil)
class ProfilAdmin(admin.ModelAdmin):
    list_display = ('code_profil', 'designation', 'famille_materiau', 'inertie_ixx', 'inertie_iyy', 'actif')
    list_filter = ('famille_materiau', 'actif')
    search_fields = ('code_profil', 'designation')


@admin.register(Projet)
class ProjetAdmin(admin.ModelAdmin):
    list_display = ('numero_projet', 'nom', 'chantier', 'date_creation', 'created_by')
    list_filter = ('date_creation',)
    search_fields = ('numero_projet', 'nom')


@admin.register(CalculRaidisseur)
class CalculRaidisseurAdmin(admin.ModelAdmin):
    list_display = ('projet', 'type_charge', 'famille_materiau', 'inertie_requise', 'created_at')
    list_filter = ('type_charge', 'famille_materiau', 'region_vent')
    search_fields = ('projet__numero_projet', 'projet__nom')


@admin.register(CalculTraverse)
class CalculTraverseAdmin(admin.ModelAdmin):
    list_display = ('projet', 'famille_materiau', 'inertie_requise', 'created_at')
    list_filter = ('famille_materiau',)
    search_fields = ('projet__numero_projet', 'projet__nom')


@admin.register(CalculEI)
class CalculEIAdmin(admin.ModelAdmin):
    list_display = ('projet', 'type_charge', 'famille_materiau', 'i_besoin', 'created_at')
    list_filter = ('type_charge', 'famille_materiau')
    search_fields = ('projet__numero_projet', 'projet__nom')


@admin.register(Configuration)
class ConfigurationAdmin(admin.ModelAdmin):
    list_display = ('titre_document', 'region_vent_defaut', 'categorie_terrain_defaut', 'neige_defaut')


