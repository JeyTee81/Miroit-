from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    DevisTravauxViewSet, LigneDevisTravauxViewSet,
    CommandeTravauxViewSet, FactureTravauxViewSet,
    LigneFactureTravauxViewSet
)

router = DefaultRouter()
router.register(r'devis', DevisTravauxViewSet, basename='devis-travaux')
router.register(r'devis-lignes', LigneDevisTravauxViewSet, basename='ligne-devis-travaux')
router.register(r'commandes', CommandeTravauxViewSet, basename='commande-travaux')
router.register(r'factures', FactureTravauxViewSet, basename='facture-travaux')
router.register(r'factures-lignes', LigneFactureTravauxViewSet, basename='ligne-facture-travaux')

urlpatterns = [
    path('', include(router.urls)),
]


