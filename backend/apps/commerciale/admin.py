from django.contrib import admin
from .models import (
    Client, Chantier, Devis, LigneDevis, Facture,
    Paiement, VenteComptoir, Caisse, Relance
)
from apps.stock.models import CommandeFournisseur

admin.site.register(Client)
admin.site.register(Chantier)
admin.site.register(Devis)
admin.site.register(LigneDevis)
admin.site.register(Facture)
admin.site.register(Paiement)
admin.site.register(VenteComptoir)
admin.site.register(Caisse)
admin.site.register(CommandeFournisseur)
admin.site.register(Relance)

