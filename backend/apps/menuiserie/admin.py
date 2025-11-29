from django.contrib import admin
from .models import Projet, Article, TarifFournisseur, Dessin


@admin.register(Projet)
class ProjetAdmin(admin.ModelAdmin):
    list_display = ['numero_projet', 'nom', 'devis', 'chantier', 'statut', 'date_creation', 'created_by']
    list_filter = ['statut', 'date_creation']
    search_fields = ['numero_projet', 'nom', 'devis__numero_devis']
    readonly_fields = ['id', 'created_at', 'updated_at']


@admin.register(Article)
class ArticleAdmin(admin.ModelAdmin):
    list_display = ['designation', 'projet', 'type_article', 'largeur', 'hauteur', 'quantite', 'prix_unitaire_ht']
    list_filter = ['type_article', 'projet']
    search_fields = ['designation', 'projet__numero_projet']
    readonly_fields = ['id', 'created_at', 'updated_at']


@admin.register(TarifFournisseur)
class TarifFournisseurAdmin(admin.ModelAdmin):
    list_display = ['fournisseur', 'reference_fournisseur', 'designation', 'prix_unitaire_ht', 'unite', 'actif']
    list_filter = ['actif', 'unite', 'fournisseur']
    search_fields = ['reference_fournisseur', 'designation', 'fournisseur__raison_sociale']
    readonly_fields = ['id', 'created_at']


@admin.register(Dessin)
class DessinAdmin(admin.ModelAdmin):
    list_display = ['article', 'format', 'echelle', 'created_at']
    list_filter = ['format', 'created_at']
    search_fields = ['article__designation']
    readonly_fields = ['id', 'created_at']
