from rest_framework import serializers
from .models import Categorie, Article, Fournisseur, Mouvement, CommandeFournisseurLigne


class CategorieSerializer(serializers.ModelSerializer):
    class Meta:
        model = Categorie
        fields = ['id', 'nom', 'parent', 'description']


class ArticleSerializer(serializers.ModelSerializer):
    categorie_nom = serializers.CharField(source='categorie.nom', read_only=True)

    class Meta:
        model = Article
        fields = [
            'id', 'reference', 'designation', 'categorie', 'categorie_nom',
            'unite_mesure', 'prix_achat_ht', 'prix_vente_ht', 'taux_tva',
            'stock_minimum', 'stock_actuel', 'actif', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class FournisseurSerializer(serializers.ModelSerializer):
    class Meta:
        model = Fournisseur
        fields = [
            'id', 'raison_sociale', 'siret', 'adresse', 'code_postal',
            'ville', 'pays', 'telephone', 'email', 'contact', 'actif',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class MouvementSerializer(serializers.ModelSerializer):
    article_reference = serializers.CharField(source='article.reference', read_only=True)

    class Meta:
        model = Mouvement
        fields = [
            'id', 'article', 'article_reference', 'type_mouvement',
            'quantite', 'prix_unitaire_ht', 'date_mouvement',
            'reference_document', 'chantier', 'commande_fournisseur',
            'created_by', 'notes', 'created_at'
        ]
        read_only_fields = ['id', 'created_at']






