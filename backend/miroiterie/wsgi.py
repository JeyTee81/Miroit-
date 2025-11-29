"""
WSGI config for miroiterie project.
"""

import os

from django.core.wsgi import get_wsgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'miroiterie.settings')

application = get_wsgi_application()






