from rest_framework import serializers
from .models import RendezVous


class RendezVousSerializer(serializers.ModelSerializer):
    utilisateur_nom = serializers.CharField(source='utilisateur.username', read_only=True)
    client_nom = serializers.CharField(source='client.nom', read_only=True, allow_null=True)
    chantier_nom = serializers.CharField(source='chantier.nom', read_only=True, allow_null=True)
    type_label = serializers.CharField(source='get_type_display', read_only=True)
    statut_label = serializers.CharField(source='get_statut_display', read_only=True)

    class Meta:
        model = RendezVous
        fields = [
            'id', 'titre', 'description', 'date_debut', 'date_fin',
            'type', 'type_label', 'utilisateur', 'utilisateur_nom',
            'client', 'client_nom', 'chantier', 'chantier_nom',
            'lieu', 'statut', 'statut_label',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def validate(self, data):
        """Valider que date_fin est après date_debut"""
        if data.get('date_fin') and data.get('date_debut'):
            if data['date_fin'] <= data['date_debut']:
                raise serializers.ValidationError({
                    'date_fin': 'La date de fin doit être après la date de début.'
                })
        return data




