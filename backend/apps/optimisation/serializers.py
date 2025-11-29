from rest_framework import serializers
from .models import (
    Matiere, ParametresDebit, Affaire, Lancement, Debit, Chute, StockMatiere
)
from .optimisation_algo import OptimiseurDebit
from decimal import Decimal


class MatiereSerializer(serializers.ModelSerializer):
    type_matiere_label = serializers.CharField(source='get_type_matiere_display', read_only=True)

    class Meta:
        model = Matiere
        fields = [
            'id', 'code', 'designation', 'type_matiere', 'type_matiere_label',
            'epaisseur', 'largeur_standard', 'longueur_standard', 'unite',
            'prix_unitaire', 'actif', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class ParametresDebitSerializer(serializers.ModelSerializer):
    sens_coupe_label = serializers.CharField(source='get_sens_coupe_par_defaut_display', read_only=True)

    class Meta:
        model = ParametresDebit
        fields = [
            'id', 'nom', 'reequerrage', 'epaisseur_lame',
            'dimension_chute_jetee', 'dimension_chute_facturee',
            'sens_coupe_par_defaut', 'sens_coupe_label', 'actif',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class AffaireSerializer(serializers.ModelSerializer):
    lancements = serializers.SerializerMethodField()
    statut_label = serializers.CharField(source='get_statut_display', read_only=True)
    chantier_nom = serializers.CharField(source='chantier.nom', read_only=True, allow_null=True)
    created_by_nom = serializers.SerializerMethodField()

    class Meta:
        model = Affaire
        fields = [
            'id', 'numero_affaire', 'nom', 'chantier', 'chantier_nom',
            'description', 'statut', 'statut_label', 'created_by', 'created_by_nom',
            'lancements', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'numero_affaire', 'created_at', 'updated_at']

    def get_lancements(self, obj):
        return LancementSerializer(obj.lancements.all(), many=True).data

    def get_created_by_nom(self, obj):
        if obj.created_by:
            return f"{obj.created_by.prenom} {obj.created_by.nom}"
        return None


class LancementSerializer(serializers.ModelSerializer):
    debits = serializers.SerializerMethodField()
    matiere_detail = MatiereSerializer(source='matiere', read_only=True)
    parametres_detail = ParametresDebitSerializer(source='parametres', read_only=True)
    statut_label = serializers.CharField(source='get_statut_display', read_only=True)
    affaire_numero = serializers.CharField(source='affaire.numero_affaire', read_only=True)

    class Meta:
        model = Lancement
        fields = [
            'id', 'affaire', 'affaire_numero', 'numero_lancement', 'date_lancement',
            'matiere', 'matiere_detail', 'parametres', 'parametres_detail',
            'description', 'statut', 'statut_label', 'debits',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def get_debits(self, obj):
        return DebitSerializer(obj.debits.all(), many=True).data


class DebitSerializer(serializers.ModelSerializer):
    sens_coupe_label = serializers.CharField(source='get_sens_coupe_display', read_only=True)
    lancement_numero = serializers.CharField(source='lancement.numero_lancement', read_only=True)

    class Meta:
        model = Debit
        fields = [
            'id', 'lancement', 'lancement_numero', 'numero_debit',
            'largeur_source', 'longueur_source', 'epaisseur',
            'pieces', 'resultat_optimisation', 'plan_coupe',
            'taux_utilisation', 'nombre_plaques_necessaires',
            'sens_coupe', 'sens_coupe_label', 'chutes_reutilisables',
            'pdf_path', 'fichier_cnc_path', 'fichier_ascii_path',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def create(self, validated_data):
        debit = Debit.objects.create(**validated_data)
        # Optimiser automatiquement si des pièces sont fournies
        if debit.pieces:
            debit = self._optimiser_debit(debit)
        return debit

    def update(self, instance, validated_data):
        # Si les pièces changent, réoptimiser
        pieces_changed = 'pieces' in validated_data
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        
        if pieces_changed and instance.pieces:
            instance = self._optimiser_debit(instance)
        else:
            instance.save()
        
        return instance

    def _optimiser_debit(self, debit):
        """Optimise le débit"""
        try:
            lancement = debit.lancement
            matiere = lancement.matiere
            parametres = lancement.parametres
            
            # Déterminer les paramètres
            epaisseur_lame = Decimal('3')
            reequerrage = Decimal('0')
            sens_coupe = debit.sens_coupe or 'transversal'
            
            if parametres:
                epaisseur_lame = parametres.epaisseur_lame
                reequerrage = parametres.reequerrage
                if not sens_coupe:
                    sens_coupe = parametres.sens_coupe_par_defaut
            
            # Créer l'optimiseur
            optimiseur = OptimiseurDebit(
                largeur_source=debit.largeur_source,
                longueur_source=debit.longueur_source,
                epaisseur_lame=epaisseur_lame,
                reequerrage=reequerrage
            )
            
            # Optimiser selon le type de matière
            if matiere.type_matiere in ['plaque', 'panneau', 'tole', 'vitrage', 'plastique']:
                resultat = optimiseur.optimiser_guillotine(debit.pieces, sens_coupe)
            elif matiere.type_matiere in ['barre', 'bobine']:
                resultat = optimiseur.optimiser_barre(debit.pieces, debit.longueur_source)
            else:
                # Par défaut, utiliser guillotine
                resultat = optimiseur.optimiser_guillotine(debit.pieces, sens_coupe)
            
            # Mettre à jour le débit
            debit.resultat_optimisation = resultat
            debit.plan_coupe = resultat.get('plan_coupe', [])
            debit.taux_utilisation = Decimal(str(resultat.get('taux_utilisation', 0)))
            debit.nombre_plaques_necessaires = resultat.get('nombre_plaques', resultat.get('nombre_barres', 1))
            debit.chutes_reutilisables = resultat.get('chutes', [])
            debit.save()
            
            # Mettre à jour le statut du lancement
            if debit.lancement:
                debit.lancement.statut = 'optimise'
                debit.lancement.save()
            
            # Créer les chutes dans la base de données
            for chute_data in resultat.get('chutes', []):
                if matiere.type_matiere in ['plaque', 'panneau', 'tole', 'vitrage', 'plastique']:
                    Chute.objects.create(
                        matiere=matiere,
                        debit=debit,
                        largeur=Decimal(str(chute_data.get('largeur', 0))),
                        longueur=Decimal(str(chute_data.get('longueur', 0))),
                        epaisseur=debit.epaisseur,
                        quantite=1,
                        statut='disponible'
                    )
                else:  # barre
                    Chute.objects.create(
                        matiere=matiere,
                        debit=debit,
                        largeur=Decimal('0'),  # Pour les barres, seule la longueur compte
                        longueur=Decimal(str(chute_data.get('longueur', 0))),
                        epaisseur=debit.epaisseur,
                        quantite=1,
                        statut='disponible'
                    )
            
        except Exception as e:
            debit.resultat_optimisation = {'erreur': str(e)}
            debit.save()
        
        return debit


class ChuteSerializer(serializers.ModelSerializer):
    matiere_detail = MatiereSerializer(source='matiere', read_only=True)
    statut_label = serializers.CharField(source='get_statut_display', read_only=True)
    debit_numero = serializers.CharField(source='debit.numero_debit', read_only=True, allow_null=True)

    class Meta:
        model = Chute
        fields = [
            'id', 'matiere', 'matiere_detail', 'debit', 'debit_numero',
            'largeur', 'longueur', 'epaisseur', 'quantite', 'surface',
            'statut', 'statut_label', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'surface', 'created_at', 'updated_at']


class StockMatiereSerializer(serializers.ModelSerializer):
    matiere_detail = MatiereSerializer(source='matiere', read_only=True)
    statut_label = serializers.CharField(source='get_statut_display', read_only=True)
    quantite_disponible = serializers.ReadOnlyField()

    class Meta:
        model = StockMatiere
        fields = [
            'id', 'matiere', 'matiere_detail', 'largeur', 'longueur', 'epaisseur',
            'quantite', 'quantite_reservee', 'quantite_disponible',
            'prix_unitaire', 'emplacement', 'date_reception', 'date_peremption',
            'statut', 'statut_label', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'quantite_disponible', 'created_at', 'updated_at']

