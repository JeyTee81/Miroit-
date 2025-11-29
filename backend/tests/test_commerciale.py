import pytest
from django.contrib.auth import get_user_model
from apps.commerciale.models import Client, Devis, Chantier
from rest_framework.test import APIClient

User = get_user_model()


@pytest.fixture
def api_client():
    return APIClient()


@pytest.fixture
def test_user():
    return User.objects.create_user(
        username='testuser',
        email='test@example.com',
        password='testpass123',
        nom='Test',
        prenom='User',
        role='commercial'
    )


@pytest.fixture
def test_client():
    return Client.objects.create(
        type='entreprise',
        raison_sociale='Test Entreprise',
        nom='Test',
        prenom='Client',
        adresse='123 Rue Test',
        code_postal='75001',
        ville='Paris',
        telephone='0123456789',
        email='client@test.com'
    )


@pytest.mark.django_db
class TestCommerciale:
    def test_client_creation(self, test_client):
        assert test_client.raison_sociale == 'Test Entreprise'
        assert test_client.type == 'entreprise'
        assert test_client.actif is True

    def test_devis_creation(self, test_client, test_user):
        devis = Devis.objects.create(
            numero_devis='DEV-001',
            client=test_client,
            date_validite='2024-12-31',
            commercial=test_user,
            statut='brouillon'
        )
        assert devis.numero_devis == 'DEV-001'
        assert devis.client == test_client
        assert devis.statut == 'brouillon'

    def test_chantier_creation(self, test_client, test_user):
        chantier = Chantier.objects.create(
            nom='Chantier Test',
            client=test_client,
            adresse_livraison='456 Rue Livraison',
            date_debut='2024-01-01',
            date_fin_prevue='2024-03-31',
            commercial=test_user
        )
        assert chantier.nom == 'Chantier Test'
        assert chantier.client == test_client
        assert chantier.statut == 'planifie'






