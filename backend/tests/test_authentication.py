import pytest
from django.contrib.auth import get_user_model
from rest_framework.test import APIClient
from rest_framework import status

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


@pytest.mark.django_db
class TestAuthentication:
    def test_user_creation(self, test_user):
        assert test_user.username == 'testuser'
        assert test_user.email == 'test@example.com'
        assert test_user.check_password('testpass123')
        assert test_user.role == 'commercial'

    def test_login_success(self, api_client, test_user):
        response = api_client.post(
            '/api/auth/users/login/',
            {
                'username': 'testuser',
                'password': 'testpass123',
            },
            format='json'
        )
        assert response.status_code == status.HTTP_200_OK
        assert 'token' in response.data
        assert 'user' in response.data

    def test_login_failure(self, api_client, test_user):
        response = api_client.post(
            '/api/auth/users/login/',
            {
                'username': 'testuser',
                'password': 'wrongpassword',
            },
            format='json'
        )
        assert response.status_code == status.HTTP_401_UNAUTHORIZED






