from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db.models import F
from .models import Categorie, Article, Fournisseur, Mouvement, CommandeFournisseurLigne
from .serializers import (
    CategorieSerializer, ArticleSerializer, FournisseurSerializer, MouvementSerializer
)


class CategorieViewSet(viewsets.ModelViewSet):
    queryset = Categorie.objects.all()
    serializer_class = CategorieSerializer
    permission_classes = [IsAuthenticated]
    search_fields = ['nom']


class ArticleViewSet(viewsets.ModelViewSet):
    queryset = Article.objects.all()
    serializer_class = ArticleSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['categorie', 'actif', 'unite_mesure']
    search_fields = ['reference', 'designation']

    @action(detail=False, methods=['get'])
    def stock_faible(self, request):
        articles = Article.objects.filter(
            stock_actuel__lte=F('stock_minimum'),
            actif=True
        )
        serializer = self.get_serializer(articles, many=True)
        return Response(serializer.data)


class FournisseurViewSet(viewsets.ModelViewSet):
    queryset = Fournisseur.objects.all()
    serializer_class = FournisseurSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['actif']
    search_fields = ['raison_sociale', 'siret', 'email']


class MouvementViewSet(viewsets.ModelViewSet):
    queryset = Mouvement.objects.all()
    serializer_class = MouvementSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['type_mouvement', 'article', 'date_mouvement']

    def perform_create(self, serializer):
        mouvement = serializer.save(created_by=self.request.user)
        # Mise à jour du stock
        article = mouvement.article
        if mouvement.type_mouvement == 'entree':
            article.stock_actuel += mouvement.quantite
        elif mouvement.type_mouvement == 'sortie':
            article.stock_actuel -= mouvement.quantite
        elif mouvement.type_mouvement == 'inventaire':
            article.stock_actuel = mouvement.quantite
        article.save()

