from django.contrib import admin
from .models import Imprimante

@admin.register(Imprimante)
class ImprimanteAdmin(admin.ModelAdmin):
    list_display = ['nom', 'type_imprimante', 'adresse_ip', 'port', 'actif', 'imprimante_par_defaut']
    list_filter = ['type_imprimante', 'actif', 'imprimante_par_defaut']
    search_fields = ['nom', 'adresse_ip', 'nom_reseau']




