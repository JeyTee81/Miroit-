from rest_framework import serializers
from .models import (
    DevisTravaux, LigneDevisTravaux, CommandeTravaux,
    FactureTravaux, LigneFactureTravaux
)


class LigneDevisTravauxSerializer(serializers.ModelSerializer):
    class Meta:
        model = LigneDevisTravaux
        fields = [
            'id', 'devis', 'designation', 'description', 'quantite', 'unite',
            'prix_unitaire_ht', 'montant_ht', 'taux_tva', 'montant_ttc',
            'detail_calcul', 'ordre', 'created_at'
        ]
        read_only_fields = ['id', 'montant_ht', 'montant_ttc', 'created_at']


class DevisTravauxSerializer(serializers.ModelSerializer):
    lignes = LigneDevisTravauxSerializer(many=True, required=False, read_only=True)
    client_nom = serializers.CharField(source='client.raison_sociale', read_only=True)
    chantier_nom = serializers.CharField(source='chantier.nom', read_only=True)
    created_by_username = serializers.CharField(source='created_by.username', read_only=True)

    class Meta:
        model = DevisTravaux
        fields = [
            'id', 'numero_devis', 'client', 'client_nom', 'chantier', 'chantier_nom',
            'date_devis', 'date_validite', 'type_travaux', 'description',
            'montant_ht', 'taux_tva', 'montant_ttc', 'statut',
            'date_envoi', 'date_acceptation', 'created_by', 'created_by_username',
            'lignes', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'numero_devis', 'montant_ttc', 'created_at', 'updated_at']

    def create(self, validated_data):
        devis = DevisTravaux.objects.create(**validated_data)
        return devis


class CommandeTravauxSerializer(serializers.ModelSerializer):
    devis_numero = serializers.CharField(source='devis.numero_devis', read_only=True)
    client_nom = serializers.CharField(source='client.raison_sociale', read_only=True)
    chantier_nom = serializers.CharField(source='chantier.nom', read_only=True)
    created_by_username = serializers.CharField(source='created_by.username', read_only=True)

    class Meta:
        model = CommandeTravaux
        fields = [
            'id', 'numero_commande', 'devis', 'devis_numero', 'client', 'client_nom',
            'chantier', 'chantier_nom', 'date_commande', 'date_debut_prevue',
            'date_fin_prevue', 'type_travaux', 'description', 'montant_ht',
            'taux_tva', 'montant_ttc', 'statut', 'created_by', 'created_by_username',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'numero_commande', 'montant_ttc', 'created_at', 'updated_at']


class LigneFactureTravauxSerializer(serializers.ModelSerializer):
    class Meta:
        model = LigneFactureTravaux
        fields = [
            'id', 'facture', 'designation', 'description', 'quantite', 'unite',
            'prix_unitaire_ht', 'montant_ht', 'taux_tva', 'montant_ttc',
            'detail_calcul', 'ordre', 'created_at'
        ]
        read_only_fields = ['id', 'montant_ht', 'montant_ttc', 'created_at']


class FactureTravauxSerializer(serializers.ModelSerializer):
    lignes = LigneFactureTravauxSerializer(many=True, required=False, read_only=True)
    commande_numero = serializers.CharField(source='commande.numero_commande', read_only=True)
    devis_numero = serializers.CharField(source='devis.numero_devis', read_only=True)
    client_nom = serializers.CharField(source='client.raison_sociale', read_only=True)
    chantier_nom = serializers.CharField(source='chantier.nom', read_only=True)
    created_by_username = serializers.CharField(source='created_by.username', read_only=True)

    class Meta:
        model = FactureTravaux
        fields = [
            'id', 'numero_facture', 'commande', 'commande_numero', 'devis', 'devis_numero',
            'client', 'client_nom', 'chantier', 'chantier_nom', 'date_facture',
            'date_echeance', 'type_travaux', 'description', 'montant_ht', 'taux_tva',
            'montant_ttc', 'montant_paye', 'montant_restant', 'statut',
            'created_by', 'created_by_username', 'lignes', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'numero_facture', 'montant_ttc', 'montant_restant', 'created_at', 'updated_at']

    def create(self, validated_data):
        facture = FactureTravaux.objects.create(**validated_data)
        return facture




