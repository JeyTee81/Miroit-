from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    FamilleMateriauViewSet,
    ProfilViewSet,
    ProjetViewSet,
    CalculRaidisseurViewSet,
    CalculTraverseViewSet,
    CalculEIViewSet,
    ConfigurationViewSet,
    CalculUtilitaireViewSet
)

router = DefaultRouter()
router.register(r'familles-materiaux', FamilleMateriauViewSet, basename='famille-materiau')
router.register(r'profils', ProfilViewSet, basename='profil')
router.register(r'projets', ProjetViewSet, basename='projet')
router.register(r'calculs-raidisseur', CalculRaidisseurViewSet, basename='calcul-raidisseur')
router.register(r'calculs-traverse', CalculTraverseViewSet, basename='calcul-traverse')
router.register(r'calculs-ei', CalculEIViewSet, basename='calcul-ei')
router.register(r'configuration', ConfigurationViewSet, basename='configuration')
router.register(r'utilitaire', CalculUtilitaireViewSet, basename='utilitaire')

urlpatterns = [
    path('', include(router.urls)),
]
