from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db.models import Q
from .models import Projet, CalculVitrage, RegionVentNeige, CategorieTerrain, Configuration
from .serializers import (
    ProjetSerializer, CalculVitrageSerializer, RegionVentNeigeSerializer,
    CategorieTerrainSerializer, ConfigurationSerializer
)


class ProjetViewSet(viewsets.ModelViewSet):
    queryset = Projet.objects.select_related('chantier', 'created_by').prefetch_related('calculs').all()
    serializer_class = ProjetSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = Projet.objects.select_related('chantier', 'created_by').prefetch_related('calculs').all()
        
        # Filtrer par chantier
        chantier_id = self.request.query_params.get('chantier')
        if chantier_id:
            queryset = queryset.filter(chantier_id=chantier_id)
        
        return queryset.order_by('-date_creation', '-created_at')


class CalculVitrageViewSet(viewsets.ModelViewSet):
    queryset = CalculVitrage.objects.select_related(
        'projet', 'region_vent', 'region_neige', 'categorie_terrain'
    ).all()
    serializer_class = CalculVitrageSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = CalculVitrage.objects.select_related(
            'projet', 'region_vent', 'region_neige', 'categorie_terrain'
        ).all()
        
        # Filtrer par projet
        projet_id = self.request.query_params.get('projet')
        if projet_id:
            queryset = queryset.filter(projet_id=projet_id)
        
        # Filtrer par type
        type_vitrage = self.request.query_params.get('type_vitrage')
        if type_vitrage:
            queryset = queryset.filter(type_vitrage=type_vitrage)
        
        return queryset.order_by('-created_at')

    @action(detail=True, methods=['post'])
    def recalculer(self, request, pk=None):
        """Recalcule l'épaisseur du vitrage"""
        calcul = self.get_object()
        calcul.calculer_epaisseur()
        calcul.save()
        serializer = self.get_serializer(calcul)
        return Response(serializer.data)

    @action(detail=True, methods=['get'])
    def note_calcul(self, request, pk=None):
        """Génère la note de calcul au format JSON pour génération PDF"""
        calcul = self.get_object()
        return Response({
            'calcul': CalculVitrageSerializer(calcul).data,
            'entete': calcul.entete_personnalisee or '',
        })


class RegionVentNeigeViewSet(viewsets.ModelViewSet):
    queryset = RegionVentNeige.objects.all()
    serializer_class = RegionVentNeigeSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = RegionVentNeige.objects.all()
        actif = self.request.query_params.get('actif')
        if actif is not None:
            queryset = queryset.filter(actif=actif.lower() == 'true')
        return queryset.order_by('code_region')

    @action(detail=False, methods=['get'])
    def par_coordonnees(self, request):
        """Trouve la région selon les coordonnées GPS"""
        latitude = request.query_params.get('latitude')
        longitude = request.query_params.get('longitude')
        
        if not latitude or not longitude:
            return Response({
                'error': 'latitude et longitude sont requis'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            lat = float(latitude)
            lon = float(longitude)
            
            region = RegionVentNeige.objects.filter(
                latitude_min__lte=lat,
                latitude_max__gte=lat,
                longitude_min__lte=lon,
                longitude_max__gte=lon,
                actif=True
            ).first()
            
            if region:
                serializer = self.get_serializer(region)
                return Response(serializer.data)
            else:
                return Response({
                    'message': 'Aucune région trouvée pour ces coordonnées'
                }, status=status.HTTP_404_NOT_FOUND)
        except ValueError:
            return Response({
                'error': 'Format de coordonnées invalide'
            }, status=status.HTTP_400_BAD_REQUEST)


class CategorieTerrainViewSet(viewsets.ModelViewSet):
    queryset = CategorieTerrain.objects.all()
    serializer_class = CategorieTerrainSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = CategorieTerrain.objects.all()
        actif = self.request.query_params.get('actif')
        if actif is not None:
            queryset = queryset.filter(actif=actif.lower() == 'true')
        return queryset.order_by('code')


class ConfigurationViewSet(viewsets.ModelViewSet):
    queryset = Configuration.objects.all()
    serializer_class = ConfigurationSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = Configuration.objects.all()
        actif = self.request.query_params.get('actif')
        if actif is not None:
            queryset = queryset.filter(actif=actif.lower() == 'true')
        return queryset




