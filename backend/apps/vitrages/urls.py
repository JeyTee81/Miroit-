from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    ProjetViewSet, CalculVitrageViewSet, RegionVentNeigeViewSet,
    CategorieTerrainViewSet, ConfigurationViewSet
)

router = DefaultRouter()
router.register(r'projets', ProjetViewSet, basename='projet')
router.register(r'calculs', CalculVitrageViewSet, basename='calcul')
router.register(r'regions-vent-neige', RegionVentNeigeViewSet, basename='region-vent-neige')
router.register(r'categories-terrain', CategorieTerrainViewSet, basename='categorie-terrain')
router.register(r'configurations', ConfigurationViewSet, basename='configuration')

urlpatterns = [
    path('', include(router.urls)),
]



