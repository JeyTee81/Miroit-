from rest_framework import serializers
from .models import Projet, Article, TarifFournisseur, Dessin, OptionMenuiserie


class TarifFournisseurSerializer(serializers.ModelSerializer):
    fournisseur_nom = serializers.CharField(source='fournisseur.raison_sociale', read_only=True)

    class Meta:
        model = TarifFournisseur
        fields = [
            'id', 'fournisseur', 'fournisseur_nom', 'reference_fournisseur',
            'designation', 'prix_unitaire_ht', 'unite', 'date_validite_debut',
            'date_validite_fin', 'actif', 'created_at'
        ]
        read_only_fields = ['id', 'created_at']


class DessinSerializer(serializers.ModelSerializer):
    class Meta:
        model = Dessin
        fields = [
            'id', 'article', 'fichier_path', 'echelle', 'format', 'created_at'
        ]
        read_only_fields = ['id', 'created_at']


class OptionMenuiserieSerializer(serializers.ModelSerializer):
    class Meta:
        model = OptionMenuiserie
        fields = [
            'id', 'code', 'libelle', 'type_option', 'type_article',
            'ajout_designation', 'impact_prix_type', 'impact_prix_valeur',
            'impact_dessin', 'actif', 'ordre_affichage', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class ArticleSerializer(serializers.ModelSerializer):
    dessins = DessinSerializer(many=True, required=False, read_only=True)
    tarif_fournisseur_nom = serializers.CharField(
        source='tarif_fournisseur.designation',
        read_only=True
    )
    designation_generee = serializers.SerializerMethodField()
    prix_calcule = serializers.SerializerMethodField()
    options_obligatoires_details = serializers.SerializerMethodField()
    options_facultatives_details = serializers.SerializerMethodField()

    class Meta:
        model = Article
        fields = [
            'id', 'projet', 'designation', 'designation_base', 'designation_generee',
            'type_article', 'largeur', 'hauteur', 'profondeur', 'quantite',
            'prix_unitaire_ht', 'prix_base_ht', 'prix_calcule', 'dessin_path',
            'echelle_dessin', 'options_obligatoires', 'options_facultatives',
            'options_obligatoires_details', 'options_facultatives_details',
            'tarif_fournisseur', 'tarif_fournisseur_nom', 'dessins',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'designation_generee', 'prix_calcule', 'created_at', 'updated_at']

    def get_designation_generee(self, obj):
        """Retourne la désignation générée automatiquement"""
        try:
            return obj.generer_designation()
        except Exception:
            return obj.designation or ''

    def get_prix_calcule(self, obj):
        """Retourne le prix calculé avec les options"""
        try:
            if obj.tarif_fournisseur or obj.prix_base_ht:
                return float(obj.calculer_prix_avec_options())
        except Exception:
            pass
        return None

    def get_options_obligatoires_details(self, obj):
        """Retourne les détails des options obligatoires"""
        options = []
        if obj.options_obligatoires:
            for option_id in obj.options_obligatoires:
                try:
                    from uuid import UUID
                    if isinstance(option_id, str):
                        option_id = UUID(option_id)
                    option = OptionMenuiserie.objects.get(id=option_id, actif=True)
                    options.append(OptionMenuiserieSerializer(option).data)
                except (OptionMenuiserie.DoesNotExist, ValueError, TypeError):
                    pass
        return options

    def get_options_facultatives_details(self, obj):
        """Retourne les détails des options facultatives"""
        options = []
        if obj.options_facultatives:
            for option_id in obj.options_facultatives:
                try:
                    from uuid import UUID
                    if isinstance(option_id, str):
                        option_id = UUID(option_id)
                    option = OptionMenuiserie.objects.get(id=option_id, actif=True)
                    options.append(OptionMenuiserieSerializer(option).data)
                except (OptionMenuiserie.DoesNotExist, ValueError, TypeError):
                    pass
        return options


class ProjetSerializer(serializers.ModelSerializer):
    articles = ArticleSerializer(many=True, required=False, read_only=True)
    devis_numero = serializers.CharField(source='devis.numero_devis', read_only=True)
    chantier_nom = serializers.CharField(source='chantier.nom', read_only=True)
    created_by_username = serializers.CharField(source='created_by.username', read_only=True)

    class Meta:
        model = Projet
        fields = [
            'id', 'numero_projet', 'devis', 'devis_numero', 'chantier', 'chantier_nom',
            'nom', 'date_creation', 'statut', 'created_by', 'created_by_username',
            'articles', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'numero_projet', 'date_creation', 'created_at', 'updated_at']

    def create(self, validated_data):
        projet = Projet.objects.create(**validated_data)
        
        # Générer le numéro de projet si non fourni
        if not projet.numero_projet:
            from django.utils import timezone
            count = Projet.objects.filter(
                date_creation__year=timezone.now().year
            ).count()
            projet.numero_projet = f"PROJ-{timezone.now().year}-{count + 1:04d}"
            projet.save()
        
        return projet


