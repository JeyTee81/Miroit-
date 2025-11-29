from django.contrib import admin
from .models import Vehicule, Chauffeur, Tournee, Livraison, Chariot, LivraisonChariot

admin.site.register(Vehicule)
admin.site.register(Chauffeur)
admin.site.register(Tournee)
admin.site.register(Livraison)
admin.site.register(Chariot)
admin.site.register(LivraisonChariot)






