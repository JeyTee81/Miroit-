from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    VehiculeViewSet, ChauffeurViewSet, TourneeViewSet,
    LivraisonViewSet, ChariotViewSet, LivraisonChariotViewSet
)

router = DefaultRouter()
router.register(r'vehicules', VehiculeViewSet, basename='vehicule')
router.register(r'chauffeurs', ChauffeurViewSet, basename='chauffeur')
router.register(r'tournees', TourneeViewSet, basename='tournee')
router.register(r'livraisons', LivraisonViewSet, basename='livraison')
router.register(r'chariots', ChariotViewSet, basename='chariot')
router.register(r'livraisons-chariots', LivraisonChariotViewSet, basename='livraison-chariot')

urlpatterns = [
    path('', include(router.urls)),
]



