from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ImprimanteViewSet, ImportAccessViewSet

router = DefaultRouter()
router.register(r'imprimantes', ImprimanteViewSet, basename='imprimante')
router.register(r'import-access', ImportAccessViewSet, basename='import-access')

urlpatterns = [
    path('', include(router.urls)),
]


