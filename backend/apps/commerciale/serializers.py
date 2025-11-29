from rest_framework import serializers
from .models import (
    Client, Chantier, Devis, LigneDevis, Facture,
    Paiement, VenteComptoir, Caisse, Relance
)
from apps.stock.models import CommandeFournisseur


class ClientSerializer(serializers.ModelSerializer):
    class Meta:
        model = Client
        fields = [
            'id', 'type', 'raison_sociale', 'nom', 'prenom', 'siret',
            'adresse', 'code_postal', 'ville', 'pays', 'telephone', 'email',
            'commercial', 'zone_geographique', 'famille_client',
            'date_creation', 'actif', 'notes', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class ChantierSerializer(serializers.ModelSerializer):
    client_nom = serializers.CharField(source='client.nom', read_only=True)

    class Meta:
        model = Chantier
        fields = [
            'id', 'nom', 'client', 'client_nom', 'adresse_livraison',
            'date_debut', 'date_fin_prevue', 'date_fin_reelle', 'statut',
            'chef_chantier', 'commercial', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class LigneDevisSerializer(serializers.ModelSerializer):
    class Meta:
        model = LigneDevis
        fields = [
            'id', 'devis', 'article', 'designation', 'quantite',
            'prix_unitaire_ht', 'taux_tva', 'remise_pourcentage', 'ordre'
        ]
        extra_kwargs = {
            'devis': {'required': False},
        }


class DevisSerializer(serializers.ModelSerializer):
    lignes = LigneDevisSerializer(many=True, required=False)
    client_nom = serializers.CharField(source='client.nom', read_only=True)

    class Meta:
        model = Devis
        fields = [
            'id', 'numero_devis', 'client', 'client_nom', 'date_creation',
            'date_validite', 'montant_ht', 'montant_ttc', 'statut',
            'commercial', 'chantier', 'remise_pourcentage', 'notes',
            'lignes', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'numero_devis', 'date_creation', 'created_at', 'updated_at']

    def create(self, validated_data):
        lignes_data = validated_data.pop('lignes', [])
        devis = Devis.objects.create(**validated_data)
        
        # Générer le numéro de devis si non fourni
        if not devis.numero_devis:
            from django.utils import timezone
            count = Devis.objects.filter(
                date_creation__year=timezone.now().year
            ).count()
            devis.numero_devis = f"DEV-{timezone.now().year}-{count + 1:04d}"
            devis.save()
        
        # Créer les lignes et calculer les totaux
        total_ht = 0
        total_ttc = 0
        
        for ligne_data in lignes_data:
            # Créer une copie sans 'devis' et 'id'
            ligne_data_clean = {k: v for k, v in ligne_data.items() 
                               if k not in ['devis', 'id']}
            
            quantite = float(ligne_data_clean.get('quantite', 0))
            prix_ht = float(ligne_data_clean.get('prix_unitaire_ht', 0))
            taux_tva = float(ligne_data_clean.get('taux_tva', 20))
            remise_ligne = float(ligne_data_clean.get('remise_pourcentage', 0))
            
            # Calcul montant HT de la ligne
            montant_ht_ligne = quantite * prix_ht * (1 - remise_ligne / 100)
            montant_ttc_ligne = montant_ht_ligne * (1 + taux_tva / 100)
            
            total_ht += montant_ht_ligne
            total_ttc += montant_ttc_ligne
            
            LigneDevis.objects.create(devis=devis, **ligne_data_clean)
        
        # Appliquer la remise globale
        remise_globale = float(devis.remise_pourcentage) if devis.remise_pourcentage else 0.0
        devis.montant_ht = total_ht * (1 - remise_globale / 100)
        devis.montant_ttc = total_ttc * (1 - remise_globale / 100)
        devis.save()
        
        return devis

    def update(self, instance, validated_data):
        lignes_data = validated_data.pop('lignes', None)
        
        # Mettre à jour les champs du devis
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        
        # Mettre à jour les lignes si fournies
        if lignes_data is not None:
            # Supprimer les anciennes lignes
            instance.lignes.all().delete()
            
            # Calculer les totaux
            total_ht = 0
            total_ttc = 0
            
            for ligne_data in lignes_data:
                # Créer une copie sans 'devis' et 'id'
                ligne_data_clean = {k: v for k, v in ligne_data.items() 
                                   if k not in ['devis', 'id']}
                
                quantite = float(ligne_data_clean.get('quantite', 0))
                prix_ht = float(ligne_data_clean.get('prix_unitaire_ht', 0))
                taux_tva = float(ligne_data_clean.get('taux_tva', 20))
                remise_ligne = float(ligne_data_clean.get('remise_pourcentage', 0))
                
                # Calcul montant HT de la ligne
                montant_ht_ligne = quantite * prix_ht * (1 - remise_ligne / 100)
                montant_ttc_ligne = montant_ht_ligne * (1 + taux_tva / 100)
                
                total_ht += montant_ht_ligne
                total_ttc += montant_ttc_ligne
                
                LigneDevis.objects.create(devis=instance, **ligne_data_clean)
            
            # Appliquer la remise globale
            remise_globale = float(instance.remise_pourcentage) if instance.remise_pourcentage else 0.0
            instance.montant_ht = total_ht * (1 - remise_globale / 100)
            instance.montant_ttc = total_ttc * (1 - remise_globale / 100)
        else:
            # Recalculer avec les lignes existantes
            total_ht = 0
            total_ttc = 0
            for ligne in instance.lignes.all():
                quantite = ligne.quantite
                prix_ht = ligne.prix_unitaire_ht
                taux_tva = ligne.taux_tva
                remise_ligne = ligne.remise_pourcentage
                
                montant_ht_ligne = quantite * prix_ht * (1 - remise_ligne / 100)
                montant_ttc_ligne = montant_ht_ligne * (1 + taux_tva / 100)
                
                total_ht += montant_ht_ligne
                total_ttc += montant_ttc_ligne
            
            remise_globale = float(instance.remise_pourcentage) if instance.remise_pourcentage else 0.0
            instance.montant_ht = total_ht * (1 - remise_globale / 100)
            instance.montant_ttc = total_ttc * (1 - remise_globale / 100)
        
        instance.save()
        return instance


class FactureSerializer(serializers.ModelSerializer):
    client_nom = serializers.CharField(source='client.nom', read_only=True)
    montant_restant = serializers.SerializerMethodField()
    numero_facture = serializers.CharField(required=False, allow_blank=True)

    class Meta:
        model = Facture
        fields = [
            'id', 'numero_facture', 'devis', 'client', 'client_nom',
            'date_facture', 'date_echeance', 'montant_ht', 'montant_ttc',
            'montant_paye', 'montant_restant', 'statut', 'commercial',
            'chantier', 'compte_comptable', 'pdf_path',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def create(self, validated_data):
        # Générer le numéro de facture si non fourni
        if not validated_data.get('numero_facture'):
            from django.utils import timezone
            date_facture = validated_data.get('date_facture', timezone.now().date())
            count = Facture.objects.filter(
                date_facture__year=date_facture.year
            ).count()
            validated_data['numero_facture'] = f"FAC-{date_facture.year}-{count + 1:04d}"
        
        facture = Facture.objects.create(**validated_data)
        return facture

    def get_montant_restant(self, obj):
        return obj.montant_ttc - obj.montant_paye


class PaiementSerializer(serializers.ModelSerializer):
    class Meta:
        model = Paiement
        fields = [
            'id', 'facture', 'montant', 'date_paiement', 'mode_paiement',
            'numero_piece', 'banque', 'created_at'
        ]
        read_only_fields = ['id', 'created_at']


class CommandeFournisseurSerializer(serializers.ModelSerializer):
    fournisseur_nom = serializers.CharField(source='fournisseur.raison_sociale', read_only=True)

    class Meta:
        model = CommandeFournisseur
        fields = [
            'id', 'numero_commande', 'fournisseur', 'fournisseur_nom',
            'date_commande', 'date_livraison_prevue', 'montant_ht',
            'montant_ttc', 'statut', 'created_by', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

