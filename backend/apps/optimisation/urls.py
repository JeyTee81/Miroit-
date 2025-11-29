from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    MatiereViewSet, ParametresDebitViewSet, AffaireViewSet,
    LancementViewSet, DebitViewSet, ChuteViewSet, StockMatiereViewSet
)

router = DefaultRouter()
router.register(r'matieres', MatiereViewSet, basename='matiere')
router.register(r'parametres-debit', ParametresDebitViewSet, basename='parametres-debit')
router.register(r'affaires', AffaireViewSet, basename='affaire')
router.register(r'lancements', LancementViewSet, basename='lancement')
router.register(r'debits', DebitViewSet, basename='debit')
router.register(r'chutes', ChuteViewSet, basename='chute')
router.register(r'stocks', StockMatiereViewSet, basename='stock-matiere')

urlpatterns = [
    path('', include(router.urls)),
]
