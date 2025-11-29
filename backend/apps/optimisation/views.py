from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db.models import Q, F
from .models import (
    Matiere, ParametresDebit, Affaire, Lancement, Debit, Chute, StockMatiere
)
from .serializers import (
    MatiereSerializer, ParametresDebitSerializer, AffaireSerializer,
    LancementSerializer, DebitSerializer, ChuteSerializer, StockMatiereSerializer
)


class MatiereViewSet(viewsets.ModelViewSet):
    queryset = Matiere.objects.all()
    serializer_class = MatiereSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = Matiere.objects.all()
        actif = self.request.query_params.get('actif')
        if actif is not None:
            queryset = queryset.filter(actif=actif.lower() == 'true')
        
        type_matiere = self.request.query_params.get('type_matiere')
        if type_matiere:
            queryset = queryset.filter(type_matiere=type_matiere)
        
        return queryset.order_by('code')


class ParametresDebitViewSet(viewsets.ModelViewSet):
    queryset = ParametresDebit.objects.all()
    serializer_class = ParametresDebitSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = ParametresDebit.objects.all()
        actif = self.request.query_params.get('actif')
        if actif is not None:
            queryset = queryset.filter(actif=actif.lower() == 'true')
        return queryset


class AffaireViewSet(viewsets.ModelViewSet):
    queryset = Affaire.objects.select_related('chantier', 'created_by').prefetch_related('lancements').all()
    serializer_class = AffaireSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = Affaire.objects.select_related('chantier', 'created_by').prefetch_related('lancements').all()
        
        statut = self.request.query_params.get('statut')
        if statut:
            queryset = queryset.filter(statut=statut)
        
        chantier_id = self.request.query_params.get('chantier')
        if chantier_id:
            queryset = queryset.filter(chantier_id=chantier_id)
        
        return queryset.order_by('-created_at')


class LancementViewSet(viewsets.ModelViewSet):
    queryset = Lancement.objects.select_related('affaire', 'matiere', 'parametres').prefetch_related('debits').all()
    serializer_class = LancementSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = Lancement.objects.select_related('affaire', 'matiere', 'parametres').prefetch_related('debits').all()
        
        affaire_id = self.request.query_params.get('affaire')
        if affaire_id:
            queryset = queryset.filter(affaire_id=affaire_id)
        
        statut = self.request.query_params.get('statut')
        if statut:
            queryset = queryset.filter(statut=statut)
        
        return queryset.order_by('-date_lancement', '-created_at')


class DebitViewSet(viewsets.ModelViewSet):
    queryset = Debit.objects.select_related('lancement').all()
    serializer_class = DebitSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = Debit.objects.select_related('lancement').all()
        
        lancement_id = self.request.query_params.get('lancement')
        if lancement_id:
            queryset = queryset.filter(lancement_id=lancement_id)
        
        return queryset.order_by('-created_at')

    @action(detail=True, methods=['post'])
    def optimiser(self, request, pk=None):
        """Force la réoptimisation du débit"""
        debit = self.get_object()
        serializer = self.get_serializer(debit)
        # L'optimisation se fait automatiquement dans le serializer
        debit = serializer._optimiser_debit(debit)
        return Response(DebitSerializer(debit).data)

    @action(detail=True, methods=['get'])
    def exporter_ascii(self, request, pk=None):
        """Exporte le débit au format ASCII"""
        debit = self.get_object()
        # TODO: Implémenter l'export ASCII
        return Response({
            'message': 'Export ASCII à implémenter',
            'debit_id': str(debit.id),
        })


class ChuteViewSet(viewsets.ModelViewSet):
    queryset = Chute.objects.select_related('matiere', 'debit').all()
    serializer_class = ChuteSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = Chute.objects.select_related('matiere', 'debit').all()
        
        matiere_id = self.request.query_params.get('matiere')
        if matiere_id:
            queryset = queryset.filter(matiere_id=matiere_id)
        
        statut = self.request.query_params.get('statut')
        if statut:
            queryset = queryset.filter(statut=statut)
        
        # Filtrer les chutes disponibles
        disponibles = self.request.query_params.get('disponibles')
        if disponibles and disponibles.lower() == 'true':
            queryset = queryset.filter(statut='disponible')
        
        return queryset.order_by('-created_at')


class StockMatiereViewSet(viewsets.ModelViewSet):
    queryset = StockMatiere.objects.select_related('matiere').all()
    serializer_class = StockMatiereSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = StockMatiere.objects.select_related('matiere').all()
        
        matiere_id = self.request.query_params.get('matiere')
        if matiere_id:
            queryset = queryset.filter(matiere_id=matiere_id)
        
        statut = self.request.query_params.get('statut')
        if statut:
            queryset = queryset.filter(statut=statut)
        
        # Filtrer les stocks disponibles
        disponibles = self.request.query_params.get('disponibles')
        if disponibles and disponibles.lower() == 'true':
            queryset = queryset.filter(statut='disponible').filter(
                Q(quantite__gt=0) | Q(quantite_reservee__lt=F('quantite'))
            )
        
        return queryset.order_by('-created_at')

    @action(detail=False, methods=['post'])
    def importer_ruptures(self, request):
        """Importe les ruptures de stock depuis un fichier"""
        # TODO: Implémenter l'import de ruptures
        return Response({
            'message': 'Import de ruptures à implémenter'
        }, status=status.HTTP_501_NOT_IMPLEMENTED)

    @action(detail=False, methods=['get'])
    def exporter_ruptures(self, request):
        """Exporte les ruptures de stock vers un fichier"""
        # TODO: Implémenter l'export de ruptures
        return Response({
            'message': 'Export de ruptures à implémenter'
        }, status=status.HTTP_501_NOT_IMPLEMENTED)

