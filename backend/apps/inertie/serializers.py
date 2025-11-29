from rest_framework import serializers
from .models import (
    FamilleMateriau,
    Profil,
    Projet,
    CalculRaidisseur,
    CalculTraverse,
    CalculEI,
    Configuration
)


class FamilleMateriauSerializer(serializers.ModelSerializer):
    class Meta:
        model = FamilleMateriau
        fields = '__all__'
        read_only_fields = ('id', 'created_at', 'updated_at')


class ProfilSerializer(serializers.ModelSerializer):
    famille_materiau_nom = serializers.CharField(source='famille_materiau.nom', read_only=True)
    
    class Meta:
        model = Profil
        fields = '__all__'
        read_only_fields = ('id', 'created_at', 'updated_at')


class ProjetSerializer(serializers.ModelSerializer):
    chantier_nom = serializers.CharField(source='chantier.nom', read_only=True, allow_null=True)
    created_by_nom = serializers.CharField(source='created_by.nom', read_only=True, allow_null=True)
    
    class Meta:
        model = Projet
        fields = '__all__'
        read_only_fields = ('id', 'date_creation', 'created_at', 'updated_at')


class CalculRaidisseurSerializer(serializers.ModelSerializer):
    projet_nom = serializers.CharField(source='projet.nom', read_only=True)
    famille_materiau_nom = serializers.CharField(source='famille_materiau.nom', read_only=True)
    profil_selectionne_code = serializers.CharField(
        source='profil_selectionne.code_profil',
        read_only=True,
        allow_null=True
    )
    
    class Meta:
        model = CalculRaidisseur
        fields = '__all__'
        read_only_fields = ('id', 'created_at', 'updated_at', 'pression_vent', 'inertie_requise')


class CalculTraverseSerializer(serializers.ModelSerializer):
    projet_nom = serializers.CharField(source='projet.nom', read_only=True)
    famille_materiau_nom = serializers.CharField(source='famille_materiau.nom', read_only=True)
    profil_selectionne_code = serializers.CharField(
        source='profil_selectionne.code_profil',
        read_only=True,
        allow_null=True
    )
    
    class Meta:
        model = CalculTraverse
        fields = '__all__'
        read_only_fields = ('id', 'created_at', 'updated_at', 'inertie_requise')


class CalculEISerializer(serializers.ModelSerializer):
    projet_nom = serializers.CharField(source='projet.nom', read_only=True)
    famille_materiau_nom = serializers.CharField(source='famille_materiau.nom', read_only=True)
    # i_reel peut être fourni en entrée pour le calcul
    i_reel = serializers.DecimalField(max_digits=15, decimal_places=6, required=False, allow_null=True)
    
    class Meta:
        model = CalculEI
        fields = '__all__'
        read_only_fields = (
            'id', 'created_at', 'updated_at',
            'e1', 'e2', 'e3', 'charge_exercee', 'charge_admissible',
            'i_mini', 'i_besoin', 'pression_calcul'
        )


class ConfigurationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Configuration
        fields = '__all__'
        read_only_fields = ('id', 'created_at', 'updated_at')


# Serializers pour les calculs utilitaires
class CalculInertieTubeSerializer(serializers.Serializer):
    """Serializer pour le calcul d'inertie d'un tube rectangulaire"""
    hauteur_cm = serializers.DecimalField(max_digits=10, decimal_places=2)
    largeur_cm = serializers.DecimalField(max_digits=10, decimal_places=2)
    epaisseur_cm = serializers.DecimalField(max_digits=10, decimal_places=2)
    
    def validate(self, data):
        if data['epaisseur_cm'] >= data['hauteur_cm'] / 2:
            raise serializers.ValidationError("L'épaisseur doit être inférieure à la moitié de la hauteur")
        if data['epaisseur_cm'] >= data['largeur_cm'] / 2:
            raise serializers.ValidationError("L'épaisseur doit être inférieure à la moitié de la largeur")
        return data

