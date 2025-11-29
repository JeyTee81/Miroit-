from django.contrib import admin
from .models import Projet, CalculVitrage, RegionVentNeige, CategorieTerrain, Configuration


@admin.register(Projet)
class ProjetAdmin(admin.ModelAdmin):
    list_display = ['numero_projet', 'nom', 'chantier', 'date_creation', 'created_by']
    list_filter = ['date_creation']
    search_fields = ['numero_projet', 'nom']


@admin.register(CalculVitrage)
class CalculVitrageAdmin(admin.ModelAdmin):
    list_display = ['projet', 'type_vitrage', 'largeur', 'hauteur', 'epaisseur_recommandee', 'created_at']
    list_filter = ['type_vitrage', 'created_at']
    search_fields = ['projet__numero_projet', 'projet__nom']


@admin.register(RegionVentNeige)
class RegionVentNeigeAdmin(admin.ModelAdmin):
    list_display = ['code_region', 'nom', 'pression_vent_reference', 'charge_neige_reference', 'actif']
    list_filter = ['actif']
    search_fields = ['code_region', 'nom']


@admin.register(CategorieTerrain)
class CategorieTerrainAdmin(admin.ModelAdmin):
    list_display = ['code', 'nom', 'coefficient_exposition', 'actif']
    list_filter = ['actif']
    search_fields = ['code', 'nom']


@admin.register(Configuration)
class ConfigurationAdmin(admin.ModelAdmin):
    list_display = ['nom', 'type_vitrage', 'epaisseur', 'actif']
    list_filter = ['type_vitrage', 'actif']
    search_fields = ['nom']
