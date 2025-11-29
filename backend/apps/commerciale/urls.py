from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    ClientViewSet, ChantierViewSet, DevisViewSet, FactureViewSet
)

router = DefaultRouter()
router.register(r'clients', ClientViewSet, basename='client')
router.register(r'chantiers', ChantierViewSet, basename='chantier')
router.register(r'devis', DevisViewSet, basename='devis')
router.register(r'factures', FactureViewSet, basename='facture')

urlpatterns = [
    path('', include(router.urls)),
]
