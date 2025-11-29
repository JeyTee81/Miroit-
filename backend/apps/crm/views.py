from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db.models import Q, Sum, Count
from django.utils import timezone
from datetime import datetime, timedelta
from .models import Visite, SuiviCA, Statistique
from .serializers import VisiteSerializer, SuiviCASerializer, StatistiqueSerializer


class VisiteViewSet(viewsets.ModelViewSet):
    queryset = Visite.objects.select_related('client', 'commercial').all()
    serializer_class = VisiteSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = Visite.objects.select_related('client', 'commercial').all()
        
        # Filtrer par client
        client_id = self.request.query_params.get('client')
        if client_id:
            queryset = queryset.filter(client_id=client_id)
        
        # Filtrer par commercial
        commercial_id = self.request.query_params.get('commercial')
        if commercial_id:
            queryset = queryset.filter(commercial_id=commercial_id)
        
        # Filtrer par type de visite
        type_visite = self.request.query_params.get('type_visite')
        if type_visite:
            queryset = queryset.filter(type_visite=type_visite)
        
        # Filtrer par date
        date_debut = self.request.query_params.get('date_debut')
        date_fin = self.request.query_params.get('date_fin')
        if date_debut:
            try:
                date_debut_obj = datetime.fromisoformat(date_debut.replace('Z', '+00:00')).date()
                queryset = queryset.filter(date_visite__gte=date_debut_obj)
            except (ValueError, AttributeError):
                pass
        if date_fin:
            try:
                date_fin_obj = datetime.fromisoformat(date_fin.replace('Z', '+00:00')).date()
                queryset = queryset.filter(date_visite__lte=date_fin_obj)
            except (ValueError, AttributeError):
                pass
        
        return queryset.order_by('-date_visite', '-created_at')


class SuiviCAViewSet(viewsets.ModelViewSet):
    queryset = SuiviCA.objects.all()
    serializer_class = SuiviCASerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = SuiviCA.objects.all()
        
        # Filtrer par période
        periode_debut = self.request.query_params.get('periode_debut')
        periode_fin = self.request.query_params.get('periode_fin')
        if periode_debut:
            try:
                periode_debut_obj = datetime.fromisoformat(periode_debut.replace('Z', '+00:00')).date()
                queryset = queryset.filter(periode_debut__gte=periode_debut_obj)
            except (ValueError, AttributeError):
                pass
        if periode_fin:
            try:
                periode_fin_obj = datetime.fromisoformat(periode_fin.replace('Z', '+00:00')).date()
                queryset = queryset.filter(periode_fin__lte=periode_fin_obj)
            except (ValueError, AttributeError):
                pass
        
        # Filtrer par famille d'articles
        famille = self.request.query_params.get('famille_article')
        if famille:
            queryset = queryset.filter(famille_article=famille)
        
        return queryset.order_by('-periode_debut', '-periode_fin', 'famille_article')

    @action(detail=False, methods=['post'])
    def calculer(self, request):
        """Calcule le CA par famille d'articles pour une période donnée"""
        periode_debut = request.data.get('periode_debut')
        periode_fin = request.data.get('periode_fin')
        
        if not periode_debut or not periode_fin:
            return Response({
                'error': 'periode_debut et periode_fin sont requis'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            periode_debut_obj = datetime.fromisoformat(periode_debut.replace('Z', '+00:00')).date()
            periode_fin_obj = datetime.fromisoformat(periode_fin.replace('Z', '+00:00')).date()
        except (ValueError, AttributeError):
            return Response({
                'error': 'Format de date invalide. Utilisez ISO format (YYYY-MM-DD)'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Calculer le CA par famille
        resultats = SuiviCA.calculer_ca_par_famille(periode_debut_obj, periode_fin_obj)
        
        # Créer ou mettre à jour les enregistrements SuiviCA
        suivi_ca_list = []
        for famille, data in resultats.items():
            suivi_ca, created = SuiviCA.objects.update_or_create(
                periode_debut=periode_debut_obj,
                periode_fin=periode_fin_obj,
                famille_article=famille,
                defaults={
                    'ca_ht': data['ca_ht'],
                    'ca_ttc': data['ca_ttc'],
                    'nombre_devis': data['nombre_devis'],
                    'nombre_factures': data['nombre_factures'],
                    'nombre_clients': data['nombre_clients'],
                }
            )
            suivi_ca_list.append(suivi_ca)
        
        serializer = self.get_serializer(suivi_ca_list, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def resume(self, request):
        """Retourne un résumé du CA par famille pour différentes périodes"""
        # Période actuelle (mois en cours)
        maintenant = timezone.now().date()
        debut_mois = maintenant.replace(day=1)
        fin_mois = (debut_mois + timedelta(days=32)).replace(day=1) - timedelta(days=1)
        
        # Mois précédent
        debut_mois_precedent = (debut_mois - timedelta(days=1)).replace(day=1)
        fin_mois_precedent = debut_mois - timedelta(days=1)
        
        # Année en cours
        debut_annee = maintenant.replace(month=1, day=1)
        fin_annee = maintenant.replace(month=12, day=31)
        
        resultats = {
            'mois_courant': SuiviCA.calculer_ca_par_famille(debut_mois, fin_mois),
            'mois_precedent': SuiviCA.calculer_ca_par_famille(debut_mois_precedent, fin_mois_precedent),
            'annee_courante': SuiviCA.calculer_ca_par_famille(debut_annee, fin_annee),
        }
        
        return Response(resultats)


class StatistiqueViewSet(viewsets.ModelViewSet):
    queryset = Statistique.objects.select_related('client', 'commercial').all()
    serializer_class = StatistiqueSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = Statistique.objects.select_related('client', 'commercial').all()
        
        # Filtrer par client
        client_id = self.request.query_params.get('client')
        if client_id:
            queryset = queryset.filter(client_id=client_id)
        
        # Filtrer par commercial
        commercial_id = self.request.query_params.get('commercial')
        if commercial_id:
            queryset = queryset.filter(commercial_id=commercial_id)
        
        # Filtrer par période
        periode_debut = self.request.query_params.get('periode_debut')
        periode_fin = self.request.query_params.get('periode_fin')
        if periode_debut:
            try:
                periode_debut_obj = datetime.fromisoformat(periode_debut.replace('Z', '+00:00')).date()
                queryset = queryset.filter(periode_debut__gte=periode_debut_obj)
            except (ValueError, AttributeError):
                pass
        if periode_fin:
            try:
                periode_fin_obj = datetime.fromisoformat(periode_fin.replace('Z', '+00:00')).date()
                queryset = queryset.filter(periode_fin__lte=periode_fin_obj)
            except (ValueError, AttributeError):
                pass
        
        return queryset.order_by('-periode_debut', '-periode_fin')




