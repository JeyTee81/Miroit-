from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.utils import timezone
from datetime import datetime, timedelta
from .models import RendezVous
from .serializers import RendezVousSerializer


class RendezVousViewSet(viewsets.ModelViewSet):
    queryset = RendezVous.objects.all()
    serializer_class = RendezVousSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        """Filtrer selon les paramètres de requête"""
        queryset = RendezVous.objects.select_related(
            'utilisateur', 'client', 'chantier'
        ).all()

        # Filtrer par utilisateur
        utilisateur_id = self.request.query_params.get('utilisateur')
        if utilisateur_id:
            queryset = queryset.filter(utilisateur_id=utilisateur_id)

        # Filtrer par type
        type_rdv = self.request.query_params.get('type')
        if type_rdv:
            queryset = queryset.filter(type=type_rdv)

        # Filtrer par statut
        statut = self.request.query_params.get('statut')
        if statut:
            queryset = queryset.filter(statut=statut)

        # Filtrer par date (début de période)
        date_debut = self.request.query_params.get('date_debut')
        if date_debut:
            try:
                date_debut_obj = datetime.fromisoformat(date_debut.replace('Z', '+00:00'))
                queryset = queryset.filter(date_debut__gte=date_debut_obj)
            except (ValueError, AttributeError):
                pass

        # Filtrer par date (fin de période)
        date_fin = self.request.query_params.get('date_fin')
        if date_fin:
            try:
                date_fin_obj = datetime.fromisoformat(date_fin.replace('Z', '+00:00'))
                queryset = queryset.filter(date_fin__lte=date_fin_obj)
            except (ValueError, AttributeError):
                pass

        # Filtrer par client
        client_id = self.request.query_params.get('client')
        if client_id:
            queryset = queryset.filter(client_id=client_id)

        # Filtrer par chantier
        chantier_id = self.request.query_params.get('chantier')
        if chantier_id:
            queryset = queryset.filter(chantier_id=chantier_id)

        return queryset.order_by('date_debut')

    @action(detail=False, methods=['get'])
    def par_periode(self, request):
        """Récupérer les rendez-vous pour une période donnée"""
        date_debut_str = request.query_params.get('date_debut')
        date_fin_str = request.query_params.get('date_fin')

        if not date_debut_str or not date_fin_str:
            return Response({
                'error': 'Les paramètres date_debut et date_fin sont requis'
            }, status=status.HTTP_400_BAD_REQUEST)

        try:
            date_debut = datetime.fromisoformat(date_debut_str.replace('Z', '+00:00'))
            date_fin = datetime.fromisoformat(date_fin_str.replace('Z', '+00:00'))
        except (ValueError, AttributeError):
            return Response({
                'error': 'Format de date invalide. Utilisez ISO 8601'
            }, status=status.HTTP_400_BAD_REQUEST)

        queryset = self.get_queryset().filter(
            date_debut__gte=date_debut,
            date_fin__lte=date_fin
        )

        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def aujourdhui(self, request):
        """Récupérer les rendez-vous d'aujourd'hui"""
        aujourdhui = timezone.now().date()
        queryset = self.get_queryset().filter(
            date_debut__date=aujourdhui
        )
        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def cette_semaine(self, request):
        """Récupérer les rendez-vous de cette semaine"""
        aujourdhui = timezone.now().date()
        debut_semaine = aujourdhui - timedelta(days=aujourdhui.weekday())
        fin_semaine = debut_semaine + timedelta(days=6)

        queryset = self.get_queryset().filter(
            date_debut__date__gte=debut_semaine,
            date_debut__date__lte=fin_semaine
        )
        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def ce_mois(self, request):
        """Récupérer les rendez-vous de ce mois"""
        aujourdhui = timezone.now().date()
        debut_mois = aujourdhui.replace(day=1)
        if aujourdhui.month == 12:
            fin_mois = aujourdhui.replace(year=aujourdhui.year + 1, month=1, day=1) - timedelta(days=1)
        else:
            fin_mois = aujourdhui.replace(month=aujourdhui.month + 1, day=1) - timedelta(days=1)

        queryset = self.get_queryset().filter(
            date_debut__date__gte=debut_mois,
            date_debut__date__lte=fin_mois
        )
        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)




