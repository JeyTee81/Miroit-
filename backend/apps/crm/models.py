from django.db import models
import uuid
from django.conf import settings
from django.db.models import Sum, Count, Q
from decimal import Decimal


class Visite(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    client = models.ForeignKey(
        'commerciale.Client',
        on_delete=models.CASCADE,
        related_name='visites'
    )
    commercial = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        related_name='visites'
    )
    date_visite = models.DateField()
    type_visite = models.CharField(
        max_length=20,
        choices=[
            ('prise_contact', 'Prise de contact'),
            ('devis', 'Devis'),
            ('suivi', 'Suivi'),
            ('relance', 'Relance'),
        ]
    )
    notes = models.TextField()
    resultat = models.CharField(max_length=200, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'crm_visites'
        verbose_name = 'Visite'
        verbose_name_plural = 'Visites'
        ordering = ['-date_visite', '-created_at']

    def __str__(self):
        return f"{self.client} - {self.date_visite}"


class SuiviCA(models.Model):
    """Suivi du Chiffre d'Affaires par familles d'articles"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    periode_debut = models.DateField()
    periode_fin = models.DateField()
    famille_article = models.CharField(max_length=100)  # Ex: 'Menuiserie', 'Vitrage', 'Travaux', etc.
    ca_ht = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    ca_ttc = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    nombre_devis = models.IntegerField(default=0)
    nombre_factures = models.IntegerField(default=0)
    nombre_clients = models.IntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'crm_suivi_ca'
        verbose_name = 'Suivi CA'
        verbose_name_plural = 'Suivi CA'
        unique_together = ['periode_debut', 'periode_fin', 'famille_article']
        ordering = ['-periode_debut', '-periode_fin', 'famille_article']

    def __str__(self):
        return f"{self.famille_article} - {self.ca_ttc}€ ({self.periode_debut} à {self.periode_fin})"

    @classmethod
    def calculer_ca_par_famille(cls, periode_debut, periode_fin):
        """Calcule le CA par famille d'articles pour une période donnée"""
        from apps.commerciale.models import Facture, Devis
        from apps.menuiserie.models import Article as ArticleMenuiserie
        from apps.travaux.models import FactureTravaux, DevisTravaux
        
        resultats = {}
        
        # CA depuis les factures commerciales (Menuiserie)
        factures = Facture.objects.filter(
            date_facture__gte=periode_debut,
            date_facture__lte=periode_fin,
            statut__in=['emise', 'payee', 'partielle']
        )
        
        # Calculer le CA pour Menuiserie (via les devis associés)
        factures_menuiserie = factures.filter(
            devis__isnull=False
        )
        ca_menuiserie_ht = factures_menuiserie.aggregate(
            total=Sum('montant_ht')
        )['total'] or Decimal('0')
        ca_menuiserie_ttc = factures_menuiserie.aggregate(
            total=Sum('montant_ttc')
        )['total'] or Decimal('0')
        
        if ca_menuiserie_ttc > 0:
            resultats['Menuiserie'] = {
                'ca_ht': ca_menuiserie_ht,
                'ca_ttc': ca_menuiserie_ttc,
                'nombre_factures': factures_menuiserie.count(),
                'nombre_devis': factures_menuiserie.values('devis').distinct().count(),
                'nombre_clients': factures_menuiserie.values('client').distinct().count(),
            }
        
        # CA depuis les factures Travaux
        factures_travaux = FactureTravaux.objects.filter(
            date_facture__gte=periode_debut,
            date_facture__lte=periode_fin,
            statut__in=['emise', 'payee', 'partielle']
        )
        ca_travaux_ht = factures_travaux.aggregate(
            total=Sum('montant_ht')
        )['total'] or Decimal('0')
        ca_travaux_ttc = factures_travaux.aggregate(
            total=Sum('montant_ttc')
        )['total'] or Decimal('0')
        
        if ca_travaux_ttc > 0:
            resultats['Travaux'] = {
                'ca_ht': ca_travaux_ht,
                'ca_ttc': ca_travaux_ttc,
                'nombre_factures': factures_travaux.count(),
                'nombre_devis': factures_travaux.values('devis').distinct().count(),
                'nombre_clients': factures_travaux.values('client').distinct().count(),
            }
        
        # Autres familles peuvent être ajoutées ici (Vitrage, etc.)
        
        return resultats


class Statistique(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    client = models.ForeignKey(
        'commerciale.Client',
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name='statistiques'
    )
    commercial = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='statistiques'
    )
    periode_debut = models.DateField()
    periode_fin = models.DateField()
    ca_ht = models.DecimalField(max_digits=10, decimal_places=2)
    ca_ttc = models.DecimalField(max_digits=10, decimal_places=2)
    nombre_devis = models.IntegerField(default=0)
    nombre_factures = models.IntegerField(default=0)
    famille_client = models.CharField(max_length=100, null=True, blank=True)
    zone_geographique = models.CharField(max_length=100, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'crm_statistiques'
        verbose_name = 'Statistique'
        verbose_name_plural = 'Statistiques'

    def __str__(self):
        return f"CA: {self.ca_ttc}€ - {self.periode_debut} à {self.periode_fin}"
