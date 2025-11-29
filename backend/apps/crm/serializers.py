from rest_framework import serializers
from .models import Visite, SuiviCA, Statistique


class VisiteSerializer(serializers.ModelSerializer):
    client_nom = serializers.CharField(source='client.__str__', read_only=True)
    commercial_nom = serializers.SerializerMethodField()
    type_visite_label = serializers.CharField(source='get_type_visite_display', read_only=True)

    class Meta:
        model = Visite
        fields = [
            'id', 'client', 'client_nom', 'commercial', 'commercial_nom',
            'date_visite', 'type_visite', 'type_visite_label',
            'notes', 'resultat', 'created_at'
        ]
        read_only_fields = ['id', 'created_at']

    def get_commercial_nom(self, obj):
        if obj.commercial:
            return f"{obj.commercial.prenom} {obj.commercial.nom}"
        return None


class SuiviCASerializer(serializers.ModelSerializer):
    class Meta:
        model = SuiviCA
        fields = [
            'id', 'periode_debut', 'periode_fin', 'famille_article',
            'ca_ht', 'ca_ttc', 'nombre_devis', 'nombre_factures',
            'nombre_clients', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class StatistiqueSerializer(serializers.ModelSerializer):
    client_nom = serializers.CharField(source='client.__str__', read_only=True, allow_null=True)
    commercial_nom = serializers.SerializerMethodField()

    class Meta:
        model = Statistique
        fields = [
            'id', 'client', 'client_nom', 'commercial', 'commercial_nom',
            'periode_debut', 'periode_fin', 'ca_ht', 'ca_ttc',
            'nombre_devis', 'nombre_factures', 'famille_client',
            'zone_geographique', 'created_at'
        ]
        read_only_fields = ['id', 'created_at']

    def get_commercial_nom(self, obj):
        if obj.commercial:
            return f"{obj.commercial.prenom} {obj.commercial.nom}"
        return None




