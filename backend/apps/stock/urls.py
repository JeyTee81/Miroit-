from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    CategorieViewSet, ArticleViewSet, FournisseurViewSet, MouvementViewSet
)

router = DefaultRouter()
router.register(r'categories', CategorieViewSet, basename='categorie')
router.register(r'articles', ArticleViewSet, basename='article')
router.register(r'fournisseurs', FournisseurViewSet, basename='fournisseur')
router.register(r'mouvements', MouvementViewSet, basename='mouvement')

urlpatterns = [
    path('', include(router.urls)),
]
