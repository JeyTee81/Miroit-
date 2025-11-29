from django.contrib import admin
from .models import (
    Matiere, ParametresDebit, Affaire, Lancement, Debit, Chute, StockMatiere
)


@admin.register(Matiere)
class MatiereAdmin(admin.ModelAdmin):
    list_display = ['code', 'designation', 'type_matiere', 'actif']
    list_filter = ['type_matiere', 'actif']
    search_fields = ['code', 'designation']


@admin.register(ParametresDebit)
class ParametresDebitAdmin(admin.ModelAdmin):
    list_display = ['nom', 'epaisseur_lame', 'reequerrage', 'actif']
    list_filter = ['actif']


@admin.register(Affaire)
class AffaireAdmin(admin.ModelAdmin):
    list_display = ['numero_affaire', 'nom', 'chantier', 'statut', 'created_at']
    list_filter = ['statut', 'created_at']
    search_fields = ['numero_affaire', 'nom']


@admin.register(Lancement)
class LancementAdmin(admin.ModelAdmin):
    list_display = ['numero_lancement', 'affaire', 'matiere', 'date_lancement', 'statut']
    list_filter = ['statut', 'date_lancement']
    search_fields = ['numero_lancement', 'affaire__numero_affaire']


@admin.register(Debit)
class DebitAdmin(admin.ModelAdmin):
    list_display = ['numero_debit', 'lancement', 'taux_utilisation', 'nombre_plaques_necessaires', 'created_at']
    list_filter = ['sens_coupe', 'created_at']
    search_fields = ['numero_debit']


@admin.register(Chute)
class ChuteAdmin(admin.ModelAdmin):
    list_display = ['matiere', 'largeur', 'longueur', 'quantite', 'statut', 'created_at']
    list_filter = ['statut', 'created_at']
    search_fields = ['matiere__code']


@admin.register(StockMatiere)
class StockMatiereAdmin(admin.ModelAdmin):
    list_display = ['matiere', 'largeur', 'longueur', 'quantite', 'quantite_reservee', 'statut']
    list_filter = ['statut']
    search_fields = ['matiere__code']
