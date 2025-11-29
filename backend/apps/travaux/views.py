from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db.models import Sum
from .models import (
    DevisTravaux, LigneDevisTravaux, CommandeTravaux,
    FactureTravaux, LigneFactureTravaux
)
from .serializers import (
    DevisTravauxSerializer, LigneDevisTravauxSerializer,
    CommandeTravauxSerializer, FactureTravauxSerializer,
    LigneFactureTravauxSerializer
)


class DevisTravauxViewSet(viewsets.ModelViewSet):
    queryset = DevisTravaux.objects.all()
    serializer_class = DevisTravauxSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['statut', 'client', 'chantier', 'type_travaux']
    search_fields = ['numero_devis', 'type_travaux', 'client__raison_sociale']

    def perform_create(self, serializer):
        if 'created_by' not in serializer.validated_data:
            serializer.save(created_by=self.request.user)
        else:
            serializer.save()

    @action(detail=True, methods=['post'])
    def calculer_totaux(self, request, pk=None):
        """Recalcule les totaux du devis à partir des lignes"""
        devis = self.get_object()
        lignes = devis.lignes.all()
        
        total_ht = sum(float(ligne.montant_ht) for ligne in lignes)
        devis.montant_ht = total_ht
        devis.montant_ttc = total_ht * (1 + float(devis.taux_tva) / 100)
        devis.save()
        
        serializer = self.get_serializer(devis)
        return Response(serializer.data)


class LigneDevisTravauxViewSet(viewsets.ModelViewSet):
    queryset = LigneDevisTravaux.objects.all()
    serializer_class = LigneDevisTravauxSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['devis']

    def perform_create(self, serializer):
        ligne = serializer.save()
        # Recalculer les totaux du devis
        devis = ligne.devis
        lignes = devis.lignes.all()
        total_ht = sum(float(l.montant_ht) for l in lignes)
        devis.montant_ht = total_ht
        devis.montant_ttc = total_ht * (1 + float(devis.taux_tva) / 100)
        devis.save()

    def perform_update(self, serializer):
        ligne = serializer.save()
        # Recalculer les totaux du devis
        devis = ligne.devis
        lignes = devis.lignes.all()
        total_ht = sum(float(l.montant_ht) for l in lignes)
        devis.montant_ht = total_ht
        devis.montant_ttc = total_ht * (1 + float(devis.taux_tva) / 100)
        devis.save()

    def perform_destroy(self, instance):
        devis = instance.devis
        instance.delete()
        # Recalculer les totaux du devis
        lignes = devis.lignes.all()
        total_ht = sum(float(l.montant_ht) for l in lignes)
        devis.montant_ht = total_ht
        devis.montant_ttc = total_ht * (1 + float(devis.taux_tva) / 100)
        devis.save()


class CommandeTravauxViewSet(viewsets.ModelViewSet):
    queryset = CommandeTravaux.objects.all()
    serializer_class = CommandeTravauxSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['statut', 'client', 'chantier', 'type_travaux']
    search_fields = ['numero_commande', 'type_travaux', 'client__raison_sociale']

    def perform_create(self, serializer):
        if 'created_by' not in serializer.validated_data:
            serializer.save(created_by=self.request.user)
        else:
            serializer.save()


class FactureTravauxViewSet(viewsets.ModelViewSet):
    queryset = FactureTravaux.objects.all()
    serializer_class = FactureTravauxSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['statut', 'client', 'chantier', 'type_travaux']
    search_fields = ['numero_facture', 'type_travaux', 'client__raison_sociale']

    def perform_create(self, serializer):
        if 'created_by' not in serializer.validated_data:
            serializer.save(created_by=self.request.user)
        else:
            serializer.save()

    @action(detail=True, methods=['post'])
    def calculer_totaux(self, request, pk=None):
        """Recalcule les totaux de la facture à partir des lignes"""
        facture = self.get_object()
        lignes = facture.lignes.all()
        
        total_ht = sum(float(ligne.montant_ht) for ligne in lignes)
        facture.montant_ht = total_ht
        facture.montant_ttc = total_ht * (1 + float(facture.taux_tva) / 100)
        facture.montant_restant = facture.montant_ttc - facture.montant_paye
        facture.save()
        
        serializer = self.get_serializer(facture)
        return Response(serializer.data)


class LigneFactureTravauxViewSet(viewsets.ModelViewSet):
    queryset = LigneFactureTravaux.objects.all()
    serializer_class = LigneFactureTravauxSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['facture']

    def perform_create(self, serializer):
        ligne = serializer.save()
        # Recalculer les totaux de la facture
        facture = ligne.facture
        lignes = facture.lignes.all()
        total_ht = sum(float(l.montant_ht) for l in lignes)
        facture.montant_ht = total_ht
        facture.montant_ttc = total_ht * (1 + float(facture.taux_tva) / 100)
        facture.montant_restant = facture.montant_ttc - facture.montant_paye
        facture.save()

    def perform_update(self, serializer):
        ligne = serializer.save()
        # Recalculer les totaux de la facture
        facture = ligne.facture
        lignes = facture.lignes.all()
        total_ht = sum(float(l.montant_ht) for l in lignes)
        facture.montant_ht = total_ht
        facture.montant_ttc = total_ht * (1 + float(facture.taux_tva) / 100)
        facture.montant_restant = facture.montant_ttc - facture.montant_paye
        facture.save()

    def perform_destroy(self, instance):
        facture = instance.facture
        instance.delete()
        # Recalculer les totaux de la facture
        lignes = facture.lignes.all()
        total_ht = sum(float(l.montant_ht) for l in lignes)
        facture.montant_ht = total_ht
        facture.montant_ttc = total_ht * (1 + float(facture.taux_tva) / 100)
        facture.montant_restant = facture.montant_ttc - facture.montant_paye
        facture.save()




