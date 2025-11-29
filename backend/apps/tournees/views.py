from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.utils import timezone
from datetime import datetime
from .models import Vehicule, Chauffeur, Tournee, Livraison, Chariot, LivraisonChariot
from .serializers import (
    VehiculeSerializer, ChauffeurSerializer, TourneeSerializer,
    LivraisonSerializer, ChariotSerializer, LivraisonChariotSerializer
)


class VehiculeViewSet(viewsets.ModelViewSet):
    queryset = Vehicule.objects.all()
    serializer_class = VehiculeSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = Vehicule.objects.all()
        actif = self.request.query_params.get('actif')
        if actif is not None:
            queryset = queryset.filter(actif=actif.lower() == 'true')
        return queryset


class ChauffeurViewSet(viewsets.ModelViewSet):
    queryset = Chauffeur.objects.select_related('user').all()
    serializer_class = ChauffeurSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = Chauffeur.objects.select_related('user').all()
        actif = self.request.query_params.get('actif')
        if actif is not None:
            queryset = queryset.filter(actif=actif.lower() == 'true')
        return queryset


class ChariotViewSet(viewsets.ModelViewSet):
    queryset = Chariot.objects.all()
    serializer_class = ChariotSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = Chariot.objects.all()
        actif = self.request.query_params.get('actif')
        if actif is not None:
            queryset = queryset.filter(actif=actif.lower() == 'true')
        return queryset


class TourneeViewSet(viewsets.ModelViewSet):
    queryset = Tournee.objects.select_related('vehicule', 'chauffeur', 'chauffeur__user').prefetch_related('livraisons').all()
    serializer_class = TourneeSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = Tournee.objects.select_related('vehicule', 'chauffeur', 'chauffeur__user').prefetch_related('livraisons').all()
        
        # Filtrer par date
        date_tournee = self.request.query_params.get('date_tournee')
        if date_tournee:
            try:
                date_obj = datetime.fromisoformat(date_tournee.replace('Z', '+00:00')).date()
                queryset = queryset.filter(date_tournee=date_obj)
            except (ValueError, AttributeError):
                pass
        
        # Filtrer par statut
        statut = self.request.query_params.get('statut')
        if statut:
            queryset = queryset.filter(statut=statut)
        
        # Filtrer par chauffeur
        chauffeur_id = self.request.query_params.get('chauffeur')
        if chauffeur_id:
            queryset = queryset.filter(chauffeur_id=chauffeur_id)
        
        return queryset.order_by('-date_tournee', '-created_at')

    @action(detail=True, methods=['post'])
    def optimiser(self, request, pk=None):
        """Optimise l'itinéraire de la tournée"""
        tournee = self.get_object()
        
        # Récupérer les livraisons avec leurs coordonnées
        livraisons = tournee.livraisons.all().order_by('ordre_livraison')
        
        if not livraisons.exists():
            return Response({
                'error': 'Aucune livraison à optimiser'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Algorithme simple d'optimisation (plus proche voisin)
        # En production, on utiliserait un algorithme plus sophistiqué (TSP, etc.)
        points = []
        for livraison in livraisons:
            if livraison.latitude and livraison.longitude:
                points.append({
                    'livraison_id': str(livraison.id),
                    'ordre_actuel': livraison.ordre_livraison,
                    'latitude': float(livraison.latitude),
                    'longitude': float(livraison.longitude),
                })
        
        if len(points) < 2:
            return Response({
                'message': 'Pas assez de points avec coordonnées pour optimiser',
                'itineraire': tournee.itineraire_optimise
            })
        
        # Algorithme du plus proche voisin
        optimized_order = _optimize_route(points)
        
        # Mettre à jour l'ordre des livraisons
        for index, point in enumerate(optimized_order):
            livraison = Livraison.objects.get(id=point['livraison_id'])
            livraison.ordre_livraison = index + 1
            livraison.save()
        
        # Calculer la distance totale estimée
        total_distance = _calculate_total_distance(optimized_order)
        
        # Mettre à jour la tournée
        tournee.itineraire_optimise = {
            'points': optimized_order,
            'distance_totale_km': total_distance,
            'optimise_le': timezone.now().isoformat(),
        }
        tournee.distance_totale = total_distance
        tournee.duree_estimee = int(total_distance * 2)  # Estimation: 2 min/km
        tournee.save()
        
        serializer = self.get_serializer(tournee)
        return Response(serializer.data)

    @action(detail=True, methods=['post'])
    def demarrer(self, request, pk=None):
        """Démarre une tournée"""
        tournee = self.get_object()
        if tournee.statut != 'planifiee':
            return Response({
                'error': 'Seules les tournées planifiées peuvent être démarrées'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        tournee.statut = 'en_cours'
        tournee.save()
        serializer = self.get_serializer(tournee)
        return Response(serializer.data)

    @action(detail=True, methods=['post'])
    def terminer(self, request, pk=None):
        """Termine une tournée"""
        tournee = self.get_object()
        if tournee.statut != 'en_cours':
            return Response({
                'error': 'Seules les tournées en cours peuvent être terminées'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        tournee.statut = 'terminee'
        tournee.save()
        serializer = self.get_serializer(tournee)
        return Response(serializer.data)


class LivraisonViewSet(viewsets.ModelViewSet):
    queryset = Livraison.objects.select_related('tournee', 'chantier', 'facture').prefetch_related('chariots').all()
    serializer_class = LivraisonSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = Livraison.objects.select_related('tournee', 'chantier', 'facture').prefetch_related('chariots').all()
        
        # Filtrer par tournée
        tournee_id = self.request.query_params.get('tournee')
        if tournee_id:
            queryset = queryset.filter(tournee_id=tournee_id)
        
        # Filtrer par statut
        statut = self.request.query_params.get('statut')
        if statut:
            queryset = queryset.filter(statut=statut)
        
        return queryset.order_by('ordre_livraison')

    @action(detail=True, methods=['post'])
    def marquer_livree(self, request, pk=None):
        """Marque une livraison comme livrée"""
        livraison = self.get_object()
        livraison.statut = 'livree'
        livraison.date_livraison_reelle = timezone.now()
        livraison.save()
        serializer = self.get_serializer(livraison)
        return Response(serializer.data)


class LivraisonChariotViewSet(viewsets.ModelViewSet):
    queryset = LivraisonChariot.objects.select_related('livraison', 'chariot').all()
    serializer_class = LivraisonChariotSerializer
    permission_classes = [IsAuthenticated]


def _optimize_route(points):
    """Algorithme simple du plus proche voisin pour optimiser l'itinéraire"""
    if not points:
        return []
    
    # Commencer par le premier point
    optimized = [points[0]]
    remaining = points[1:]
    
    current_point = points[0]
    
    while remaining:
        # Trouver le point le plus proche
        nearest = None
        nearest_distance = float('inf')
        nearest_index = -1
        
        for i, point in enumerate(remaining):
            distance = _calculate_distance(
                current_point['latitude'], current_point['longitude'],
                point['latitude'], point['longitude']
            )
            if distance < nearest_distance:
                nearest_distance = distance
                nearest = point
                nearest_index = i
        
        if nearest:
            optimized.append(nearest)
            remaining.pop(nearest_index)
            current_point = nearest
    
    return optimized


def _calculate_distance(lat1, lon1, lat2, lon2):
    """Calcule la distance en km entre deux points (formule de Haversine)"""
    from math import radians, sin, cos, sqrt, atan2
    
    R = 6371  # Rayon de la Terre en km
    
    lat1_rad = radians(lat1)
    lat2_rad = radians(lat2)
    delta_lat = radians(lat2 - lat1)
    delta_lon = radians(lon2 - lon1)
    
    a = sin(delta_lat / 2) ** 2 + cos(lat1_rad) * cos(lat2_rad) * sin(delta_lon / 2) ** 2
    c = 2 * atan2(sqrt(a), sqrt(1 - a))
    
    return R * c


def _calculate_total_distance(points):
    """Calcule la distance totale d'un itinéraire"""
    if len(points) < 2:
        return 0.0
    
    total = 0.0
    for i in range(len(points) - 1):
        total += _calculate_distance(
            points[i]['latitude'], points[i]['longitude'],
            points[i + 1]['latitude'], points[i + 1]['longitude']
        )
    
    return round(total, 2)




