from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db.models import Q
from .models import (
    Client, Chantier, Devis, LigneDevis, Facture,
    Paiement, VenteComptoir, Caisse, Relance
)
from apps.stock.models import CommandeFournisseur
from .serializers import (
    ClientSerializer, ChantierSerializer, DevisSerializer,
    LigneDevisSerializer, FactureSerializer, PaiementSerializer,
    CommandeFournisseurSerializer
)


class ClientViewSet(viewsets.ModelViewSet):
    queryset = Client.objects.all()
    serializer_class = ClientSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['type', 'actif', 'zone_geographique', 'famille_client']
    search_fields = ['nom', 'prenom', 'raison_sociale', 'email', 'siret']

    @action(detail=True, methods=['get'])
    def historique(self, request, pk=None):
        client = self.get_object()
        devis = Devis.objects.filter(client=client)
        factures = Facture.objects.filter(client=client)
        return Response({
            'devis': DevisSerializer(devis, many=True).data,
            'factures': FactureSerializer(factures, many=True).data,
        })


class ChantierViewSet(viewsets.ModelViewSet):
    queryset = Chantier.objects.all()
    serializer_class = ChantierSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['statut', 'client', 'commercial']
    search_fields = ['nom', 'adresse_livraison']


class DevisViewSet(viewsets.ModelViewSet):
    queryset = Devis.objects.all()
    serializer_class = DevisSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['statut', 'client', 'commercial']
    search_fields = ['numero_devis', 'client__nom']

    def perform_create(self, serializer):
        # Définir automatiquement le commercial si non fourni
        if 'commercial' not in serializer.validated_data:
            serializer.save(commercial=self.request.user)
        else:
            serializer.save()

    @action(detail=True, methods=['post'])
    def generer_facture(self, request, pk=None):
        devis = self.get_object()
        if devis.statut != 'accepte':
            return Response(
                {'error': 'Le devis doit être accepté pour générer une facture'},
                status=status.HTTP_400_BAD_REQUEST
            )
        # Logique de génération de facture à implémenter
        return Response({'message': 'Facture générée'})


class FactureViewSet(viewsets.ModelViewSet):
    queryset = Facture.objects.all()
    serializer_class = FactureSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['statut', 'client', 'commercial']
    search_fields = ['numero_facture', 'client__nom']

    @action(detail=True, methods=['post'])
    def enregistrer_paiement(self, request, pk=None):
        facture = self.get_object()
        serializer = PaiementSerializer(data=request.data)
        if serializer.is_valid():
            paiement = serializer.save(facture=facture)
            facture.montant_paye += paiement.montant
            if facture.montant_paye >= facture.montant_ttc:
                facture.statut = 'payee'
            elif facture.montant_paye > 0:
                facture.statut = 'partielle'
            facture.save()
            return Response(PaiementSerializer(paiement).data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

