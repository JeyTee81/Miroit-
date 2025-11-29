from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import VisiteViewSet, SuiviCAViewSet, StatistiqueViewSet

router = DefaultRouter()
router.register(r'visites', VisiteViewSet, basename='visite')
router.register(r'suivi-ca', SuiviCAViewSet, basename='suivi-ca')
router.register(r'statistiques', StatistiqueViewSet, basename='statistique')

urlpatterns = [
    path('', include(router.urls)),
]



