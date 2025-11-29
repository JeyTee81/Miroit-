from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db.models import Q
from .models import Projet, Article, TarifFournisseur, Dessin, OptionMenuiserie
from .serializers import (
    ProjetSerializer, ArticleSerializer, TarifFournisseurSerializer,
    DessinSerializer, OptionMenuiserieSerializer
)


class ProjetViewSet(viewsets.ModelViewSet):
    queryset = Projet.objects.all()
    serializer_class = ProjetSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['statut', 'devis', 'chantier', 'created_by']
    search_fields = ['numero_projet', 'nom', 'devis__numero_devis']

    def perform_create(self, serializer):
        # Définir automatiquement le créateur si non fourni
        if 'created_by' not in serializer.validated_data:
            serializer.save(created_by=self.request.user)
        else:
            serializer.save()


class ArticleViewSet(viewsets.ModelViewSet):
    queryset = Article.objects.all()
    serializer_class = ArticleSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['projet', 'type_article']
    search_fields = ['designation', 'projet__numero_projet']

    def get_queryset(self):
        queryset = Article.objects.all()
        projet_id = self.request.query_params.get('projet', None)
        if projet_id:
            queryset = queryset.filter(projet_id=projet_id)
        return queryset


class TarifFournisseurViewSet(viewsets.ModelViewSet):
    queryset = TarifFournisseur.objects.all()
    serializer_class = TarifFournisseurSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['fournisseur', 'actif', 'unite']
    search_fields = ['reference_fournisseur', 'designation', 'fournisseur__raison_sociale']


class DessinViewSet(viewsets.ModelViewSet):
    queryset = Dessin.objects.all()
    serializer_class = DessinSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['article', 'format']
    search_fields = ['article__designation']


class OptionMenuiserieViewSet(viewsets.ModelViewSet):
    queryset = OptionMenuiserie.objects.all()
    serializer_class = OptionMenuiserieSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['type_option', 'type_article', 'actif']
    search_fields = ['code', 'libelle', 'ajout_designation']

    def get_queryset(self):
        queryset = OptionMenuiserie.objects.all()
        type_article = self.request.query_params.get('type_article', None)
        type_option = self.request.query_params.get('type_option', None)
        
        if type_article:
            queryset = queryset.filter(
                Q(type_article=type_article) | Q(type_article='tous')
            )
        
        if type_option:
            queryset = queryset.filter(type_option=type_option)
        
        return queryset.filter(actif=True).order_by('type_option', 'ordre_affichage', 'libelle')

    @action(detail=False, methods=['post'])
    def calculer_prix(self, request):
        """Calcule le prix d'un article avec options sans le sauvegarder"""
        tarif_id = request.data.get('tarif_fournisseur')
        prix_base = request.data.get('prix_base_ht')
        largeur = float(request.data.get('largeur', 0))
        hauteur = float(request.data.get('hauteur', 0))
        options_obligatoires = request.data.get('options_obligatoires', [])
        options_facultatives = request.data.get('options_facultatives', [])
        
        from decimal import Decimal
        
        # Calculer le prix de base
        if tarif_id:
            try:
                tarif = TarifFournisseur.objects.get(id=tarif_id, actif=True)
                prix_base_calc = tarif.prix_unitaire_ht
                if tarif.unite == 'm2':
                    surface = (largeur * hauteur) / 10000  # cm² -> m²
                    prix_base_calc = Decimal(str(surface)) * prix_base_calc
                elif tarif.unite == 'ml':
                    perimetre = (largeur + hauteur) * 2 / 100  # cm -> m
                    prix_base_calc = Decimal(str(perimetre)) * prix_base_calc
            except TarifFournisseur.DoesNotExist:
                return Response({'error': 'Tarif fournisseur introuvable'}, status=400)
        elif prix_base:
            prix_base_calc = Decimal(str(prix_base))
        else:
            return Response({'error': 'Tarif fournisseur ou prix de base requis'}, status=400)
        
        prix_final = prix_base_calc
        
        # Appliquer les options
        for option_id in options_obligatoires + options_facultatives:
            try:
                option = OptionMenuiserie.objects.get(id=option_id, actif=True)
                if option.impact_prix_type == 'fixe':
                    prix_final += option.impact_prix_valeur
                elif option.impact_prix_type == 'pourcentage':
                    prix_final += (prix_base_calc * option.impact_prix_valeur / Decimal('100'))
            except OptionMenuiserie.DoesNotExist:
                pass
        
        return Response({'prix_calcule': float(prix_final)})

    @action(detail=False, methods=['post'])
    def generer_designation(self, request):
        """Génère la désignation d'un article avec options sans le sauvegarder"""
        designation_base = request.data.get('designation_base', '')
        type_article = request.data.get('type_article', '')
        largeur = request.data.get('largeur', 0)
        hauteur = request.data.get('hauteur', 0)
        options_obligatoires = request.data.get('options_obligatoires', [])
        options_facultatives = request.data.get('options_facultatives', [])
        
        designation_parts = []
        
        if designation_base:
            designation_parts.append(designation_base)
        elif type_article:
            type_labels = {
                'fenetre': 'Fenêtre',
                'porte': 'Porte',
                'baie': 'Baie vitrée',
                'autre': 'Autre'
            }
            type_label = type_labels.get(type_article, type_article)
            designation_parts.append(f"{type_label} {int(largeur)}x{int(hauteur)}")
        
        # Ajouter les options
        for option_id in options_obligatoires + options_facultatives:
            try:
                option = OptionMenuiserie.objects.get(id=option_id, actif=True)
                if option.ajout_designation:
                    designation_parts.append(option.ajout_designation)
            except OptionMenuiserie.DoesNotExist:
                pass
        
        designation_generee = " - ".join(designation_parts) if designation_parts else designation_base
        
        return Response({'designation_generee': designation_generee})


