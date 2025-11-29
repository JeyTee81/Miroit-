"""
URL configuration for miroiterie project.
"""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from django.http import JsonResponse

def api_root(request):
    """Vue racine pour afficher les informations de l'API"""
    return JsonResponse({
        'message': 'API Miroiterie/Menuiserie',
        'version': '1.0.0',
        'endpoints': {
            'admin': '/admin/',
            'authentication': '/api/auth/',
            'commerciale': '/api/commerciale/',
            'menuiserie': '/api/menuiserie/',
            'stock': '/api/stock/',
            'travaux': '/api/travaux/',
            'planning': '/api/planning/',
            'tournees': '/api/tournees/',
            'crm': '/api/crm/',
            'vitrages': '/api/vitrages/',
            'optimisation': '/api/optimisation/',
            'inertie': '/api/inertie/',
            'comptabilite': '/api/comptabilite/',
            'parametres': '/api/parametres/',
            'system_logs': '/api/system_logs/',
        }
    })

urlpatterns = [
    path('', api_root, name='api_root'),
    path('api/', api_root, name='api_root'),
    path('admin/', admin.site.urls),
    path('api/auth/', include('apps.authentication.urls')),
    path('api/commerciale/', include('apps.commerciale.urls')),
    path('api/menuiserie/', include('apps.menuiserie.urls')),
    path('api/stock/', include('apps.stock.urls')),
    path('api/travaux/', include('apps.travaux.urls')),
    path('api/planning/', include('apps.planning.urls')),
    path('api/tournees/', include('apps.tournees.urls')),
    path('api/crm/', include('apps.crm.urls')),
    path('api/vitrages/', include('apps.vitrages.urls')),
    path('api/optimisation/', include('apps.optimisation.urls')),
    path('api/inertie/', include('apps.inertie.urls')),
    path('api/comptabilite/', include('apps.comptabilite.urls')),
    path('api/parametres/', include('apps.parametres.urls')),
    path('api/system_logs/', include('apps.system_logs.urls')),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)


