from rest_framework import serializers
from .models import Vehicule, Chauffeur, Tournee, Livraison, Chariot, LivraisonChariot


class VehiculeSerializer(serializers.ModelSerializer):
    type_label = serializers.CharField(source='get_type_display', read_only=True)

    class Meta:
        model = Vehicule
        fields = [
            'id', 'immatriculation', 'marque', 'modele', 'type', 'type_label',
            'capacite_charge', 'actif', 'created_at'
        ]
        read_only_fields = ['id', 'created_at']


class ChauffeurSerializer(serializers.ModelSerializer):
    user_nom = serializers.CharField(source='user.nom', read_only=True)
    user_prenom = serializers.CharField(source='user.prenom', read_only=True)
    user_username = serializers.CharField(source='user.username', read_only=True)

    class Meta:
        model = Chauffeur
        fields = [
            'id', 'user', 'user_nom', 'user_prenom', 'user_username',
            'numero_permis', 'date_expiration_permis', 'actif'
        ]
        read_only_fields = ['id']


class ChariotSerializer(serializers.ModelSerializer):
    class Meta:
        model = Chariot
        fields = [
            'id', 'numero', 'type', 'capacite', 'actif', 'created_at'
        ]
        read_only_fields = ['id', 'created_at']


class LivraisonChariotSerializer(serializers.ModelSerializer):
    chariot_detail = ChariotSerializer(source='chariot', read_only=True)

    class Meta:
        model = LivraisonChariot
        fields = [
            'id', 'livraison', 'chariot', 'chariot_detail', 'quantite'
        ]
        read_only_fields = ['id']


class LivraisonSerializer(serializers.ModelSerializer):
    chantier_nom = serializers.CharField(source='chantier.nom', read_only=True)
    facture_numero = serializers.CharField(source='facture.numero_facture', read_only=True, allow_null=True)
    statut_label = serializers.CharField(source='get_statut_display', read_only=True)
    chariots = LivraisonChariotSerializer(many=True, read_only=True)

    class Meta:
        model = Livraison
        fields = [
            'id', 'tournee', 'facture', 'facture_numero', 'chantier', 'chantier_nom',
            'ordre_livraison', 'adresse_livraison', 'latitude', 'longitude',
            'statut', 'statut_label', 'date_livraison_prevue', 'date_livraison_reelle',
            'signature_path', 'notes', 'chariots', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class TourneeSerializer(serializers.ModelSerializer):
    vehicule_detail = VehiculeSerializer(source='vehicule', read_only=True)
    chauffeur_detail = ChauffeurSerializer(source='chauffeur', read_only=True)
    statut_label = serializers.CharField(source='get_statut_display', read_only=True)
    livraisons = LivraisonSerializer(many=True, read_only=True)
    numero_tournee = serializers.CharField(required=False, allow_blank=True)

    class Meta:
        model = Tournee
        fields = [
            'id', 'numero_tournee', 'date_tournee', 'vehicule', 'vehicule_detail',
            'chauffeur', 'chauffeur_detail', 'statut', 'statut_label',
            'itineraire_optimise', 'distance_totale', 'duree_estimee',
            'livraisons', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def create(self, validated_data):
        # Générer le numéro de tournée si non fourni
        if not validated_data.get('numero_tournee'):
            from django.utils import timezone
            date_tournee = validated_data.get('date_tournee', timezone.now().date())
            count = Tournee.objects.filter(
                date_tournee__year=date_tournee.year
            ).count()
            validated_data['numero_tournee'] = f"TOUR-{date_tournee.year}-{count + 1:04d}"
        
        tournee = Tournee.objects.create(**validated_data)
        return tournee




