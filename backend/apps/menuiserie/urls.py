from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    ProjetViewSet, ArticleViewSet, TarifFournisseurViewSet, DessinViewSet,
    OptionMenuiserieViewSet
)

router = DefaultRouter()
router.register(r'projets', ProjetViewSet, basename='projet')
router.register(r'articles', ArticleViewSet, basename='article')
router.register(r'tarifs-fournisseurs', TarifFournisseurViewSet, basename='tarif-fournisseur')
router.register(r'dessins', DessinViewSet, basename='dessin')
router.register(r'options', OptionMenuiserieViewSet, basename='option-menuiserie')

urlpatterns = [
    path('', include(router.urls)),
]
