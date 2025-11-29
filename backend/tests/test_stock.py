import pytest
from apps.stock.models import Categorie, Article, Fournisseur, Mouvement
from apps.commerciale.models import Client
from django.contrib.auth import get_user_model

User = get_user_model()


@pytest.fixture
def test_user():
    return User.objects.create_user(
        username='testuser',
        email='test@example.com',
        password='testpass123',
        nom='Test',
        prenom='User',
        role='atelier'
    )


@pytest.fixture
def test_categorie():
    return Categorie.objects.create(
        nom='Vitrage',
        description='Catégorie vitrage'
    )


@pytest.fixture
def test_fournisseur():
    return Fournisseur.objects.create(
        raison_sociale='Fournisseur Test',
        adresse='123 Rue Fournisseur',
        code_postal='75001',
        ville='Paris',
        telephone='0123456789'
    )


@pytest.mark.django_db
class TestStock:
    def test_categorie_creation(self, test_categorie):
        assert test_categorie.nom == 'Vitrage'
        assert test_categorie.description == 'Catégorie vitrage'

    def test_article_creation(self, test_categorie):
        article = Article.objects.create(
            reference='ART-001',
            designation='Vitrage 4mm',
            categorie=test_categorie,
            prix_achat_ht=10.00,
            prix_vente_ht=15.00,
            stock_actuel=100
        )
        assert article.reference == 'ART-001'
        assert article.stock_actuel == 100
        assert article.actif is True

    def test_fournisseur_creation(self, test_fournisseur):
        assert test_fournisseur.raison_sociale == 'Fournisseur Test'
        assert test_fournisseur.actif is True

    def test_mouvement_stock(self, test_categorie, test_user):
        article = Article.objects.create(
            reference='ART-002',
            designation='Vitrage 6mm',
            categorie=test_categorie,
            prix_achat_ht=12.00,
            prix_vente_ht=18.00,
            stock_actuel=50
        )

        mouvement = Mouvement.objects.create(
            article=article,
            type_mouvement='entree',
            quantite=25,
            prix_unitaire_ht=12.00,
            date_mouvement='2024-01-15',
            created_by=test_user
        )

        assert mouvement.type_mouvement == 'entree'
        assert mouvement.quantite == 25
        assert mouvement.article == article






