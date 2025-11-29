from rest_framework import serializers
from .models import Projet, CalculVitrage, RegionVentNeige, CategorieTerrain, Configuration


class RegionVentNeigeSerializer(serializers.ModelSerializer):
    class Meta:
        model = RegionVentNeige
        fields = [
            'id', 'code_region', 'nom', 'pression_vent_reference',
            'charge_neige_reference', 'latitude_min', 'latitude_max',
            'longitude_min', 'longitude_max', 'description', 'actif'
        ]
        read_only_fields = ['id']


class CategorieTerrainSerializer(serializers.ModelSerializer):
    class Meta:
        model = CategorieTerrain
        fields = [
            'id', 'code', 'nom', 'description', 'coefficient_exposition',
            'photo_path', 'actif'
        ]
        read_only_fields = ['id']


class CalculVitrageSerializer(serializers.ModelSerializer):
    region_vent_detail = RegionVentNeigeSerializer(source='region_vent', read_only=True)
    region_neige_detail = RegionVentNeigeSerializer(source='region_neige', read_only=True)
    categorie_terrain_detail = CategorieTerrainSerializer(source='categorie_terrain', read_only=True)
    type_vitrage_label = serializers.CharField(source='get_type_vitrage_display', read_only=True)
    projet_numero = serializers.CharField(source='projet.numero_projet', read_only=True)

    class Meta:
        model = CalculVitrage
        fields = [
            'id', 'projet', 'projet_numero', 'largeur', 'hauteur',
            'type_vitrage', 'type_vitrage_label',
            'region_vent', 'region_vent_detail',
            'region_neige', 'region_neige_detail',
            'categorie_terrain', 'categorie_terrain_detail',
            'altitude', 'pression_vent', 'charge_neige',
            'coefficient_securite', 'epaisseur_calculee', 'epaisseur_recommandee',
            'resultat_calcul', 'norme_utilisee', 'cahier_cstb',
            'pdf_path', 'entete_personnalisee', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def create(self, validated_data):
        calcul = CalculVitrage.objects.create(**validated_data)
        # Calculer automatiquement l'épaisseur
        calcul.calculer_epaisseur()
        calcul.save()
        return calcul


class ProjetSerializer(serializers.ModelSerializer):
    calculs = CalculVitrageSerializer(many=True, read_only=True)
    chantier_nom = serializers.CharField(source='chantier.nom', read_only=True, allow_null=True)
    created_by_nom = serializers.SerializerMethodField()

    class Meta:
        model = Projet
        fields = [
            'id', 'numero_projet', 'chantier', 'chantier_nom', 'nom',
            'date_creation', 'created_by', 'created_by_nom',
            'calculs', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def get_created_by_nom(self, obj):
        if obj.created_by:
            return f"{obj.created_by.prenom} {obj.created_by.nom}"
        return None

    def create(self, validated_data):
        # Générer le numéro de projet si non fourni
        if not validated_data.get('numero_projet'):
            from django.utils import timezone
            date_creation = validated_data.get('date_creation', timezone.now().date())
            count = Projet.objects.filter(
                date_creation__year=date_creation.year
            ).count()
            validated_data['numero_projet'] = f"VIT-{date_creation.year}-{count + 1:04d}"
        
        projet = Projet.objects.create(**validated_data)
        return projet


class ConfigurationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Configuration
        fields = [
            'id', 'nom', 'type_vitrage', 'epaisseur', 'coefficients', 'actif'
        ]
        read_only_fields = ['id']




