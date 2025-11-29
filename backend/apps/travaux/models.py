from django.db import models
import uuid
from django.conf import settings


class ChantierTravaux(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    chantier = models.ForeignKey(
        'commerciale.Chantier',
        on_delete=models.CASCADE,
        related_name='travaux'
    )
    date_debut = models.DateField()
    date_fin = models.DateField(null=True, blank=True)
    statut = models.CharField(
        max_length=20,
        choices=[
            ('planifie', 'Planifié'),
            ('en_cours', 'En cours'),
            ('suspendu', 'Suspendu'),
            ('termine', 'Terminé'),
        ],
        default='planifie'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'travaux_chantiers'
        verbose_name = 'Chantier travaux'
        verbose_name_plural = 'Chantiers travaux'

    def __str__(self):
        return f"{self.chantier.nom} - {self.statut}"


class Heure(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    chantier = models.ForeignKey(
        'commerciale.Chantier',
        on_delete=models.CASCADE,
        related_name='heures'
    )
    salarie = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='heures_travaillees'
    )
    date_travail = models.DateField()
    heures_normales = models.DecimalField(max_digits=5, decimal_places=2)
    heures_supplementaires = models.DecimalField(max_digits=5, decimal_places=2, default=0)
    taux_horaire = models.DecimalField(max_digits=10, decimal_places=2)
    activite = models.CharField(
        max_length=20,
        choices=[
            ('fabrication', 'Fabrication'),
            ('pose', 'Pose'),
            ('livraison', 'Livraison'),
            ('autre', 'Autre'),
        ]
    )
    notes = models.TextField(null=True, blank=True)
    valide_par = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='heures_validees'
    )
    valide_le = models.DateField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'travaux_heures'
        verbose_name = 'Heure'
        verbose_name_plural = 'Heures'

    def __str__(self):
        return f"{self.salarie} - {self.date_travail} - {self.heures_normales}h"


class BilanChantier(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    chantier = models.ForeignKey(
        'commerciale.Chantier',
        on_delete=models.CASCADE,
        related_name='bilans'
    )
    periode_debut = models.DateField()
    periode_fin = models.DateField()
    heures_totales = models.DecimalField(max_digits=10, decimal_places=2)
    cout_total = models.DecimalField(max_digits=10, decimal_places=2)
    avancement_pourcentage = models.DecimalField(max_digits=5, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'travaux_bilans_chantiers'
        verbose_name = 'Bilan chantier'
        verbose_name_plural = 'Bilans chantiers'

    def __str__(self):
        return f"{self.chantier.nom} - {self.periode_debut} à {self.periode_fin}"


class DevisTravaux(models.Model):
    """Devis pour travaux"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    numero_devis = models.CharField(max_length=50, unique=True)
    client = models.ForeignKey(
        'commerciale.Client',
        on_delete=models.CASCADE,
        related_name='devis_travaux'
    )
    chantier = models.ForeignKey(
        'commerciale.Chantier',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='devis_travaux'
    )
    date_devis = models.DateField()
    date_validite = models.DateField(null=True, blank=True)
    type_travaux = models.CharField(
        max_length=50,
        help_text="Type de travaux (ex: Rénovation, Installation, Réparation)"
    )
    description = models.TextField(null=True, blank=True)
    montant_ht = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    taux_tva = models.DecimalField(max_digits=5, decimal_places=2, default=20)
    montant_ttc = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    statut = models.CharField(
        max_length=20,
        choices=[
            ('brouillon', 'Brouillon'),
            ('envoye', 'Envoyé'),
            ('accepte', 'Accepté'),
            ('refuse', 'Refusé'),
        ],
        default='brouillon'
    )
    date_envoi = models.DateField(null=True, blank=True)
    date_acceptation = models.DateField(null=True, blank=True)
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        related_name='devis_travaux_crees'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'travaux_devis'
        verbose_name = 'Devis travaux'
        verbose_name_plural = 'Devis travaux'
        ordering = ['-date_devis']

    def __str__(self):
        return f"{self.numero_devis} - {self.client}"

    def save(self, *args, **kwargs):
        if not self.numero_devis:
            from django.utils import timezone
            count = DevisTravaux.objects.filter(
                date_devis__year=timezone.now().year
            ).count()
            self.numero_devis = f"DEV-TRAV-{timezone.now().year}-{count + 1:04d}"
        
        # Calculer le montant TTC
        self.montant_ttc = self.montant_ht * (1 + self.taux_tva / 100)
        super().save(*args, **kwargs)


class LigneDevisTravaux(models.Model):
    """Ligne de devis travaux avec détail du calcul"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    devis = models.ForeignKey(
        DevisTravaux,
        on_delete=models.CASCADE,
        related_name='lignes'
    )
    designation = models.CharField(max_length=200)
    description = models.TextField(null=True, blank=True)
    quantite = models.DecimalField(max_digits=10, decimal_places=2, default=1)
    unite = models.CharField(
        max_length=20,
        choices=[
            ('unite', 'Unité'),
            ('heure', 'Heure'),
            ('jour', 'Jour'),
            ('m2', 'm²'),
            ('ml', 'mètre linéaire'),
            ('forfait', 'Forfait'),
        ],
        default='unite'
    )
    # Détail du calcul
    prix_unitaire_ht = models.DecimalField(max_digits=10, decimal_places=2)
    montant_ht = models.DecimalField(max_digits=10, decimal_places=2)
    taux_tva = models.DecimalField(max_digits=5, decimal_places=2, default=20)
    montant_ttc = models.DecimalField(max_digits=10, decimal_places=2)
    # Détail du calcul du prix (JSON pour stocker les éléments)
    detail_calcul = models.JSONField(
        default=dict,
        help_text="Détail du calcul : {main_oeuvre: {heures: 10, taux: 25}, materiaux: [...], autres: [...]}"
    )
    ordre = models.IntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'travaux_devis_lignes'
        verbose_name = 'Ligne devis travaux'
        verbose_name_plural = 'Lignes devis travaux'
        ordering = ['ordre', 'created_at']

    def __str__(self):
        return f"{self.devis.numero_devis} - {self.designation}"

    def save(self, *args, **kwargs):
        # Calculer le montant HT et TTC
        self.montant_ht = self.quantite * self.prix_unitaire_ht
        self.montant_ttc = self.montant_ht * (1 + self.taux_tva / 100)
        super().save(*args, **kwargs)


class CommandeTravaux(models.Model):
    """Commande de travaux"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    numero_commande = models.CharField(max_length=50, unique=True)
    devis = models.ForeignKey(
        DevisTravaux,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='commandes'
    )
    client = models.ForeignKey(
        'commerciale.Client',
        on_delete=models.CASCADE,
        related_name='commandes_travaux'
    )
    chantier = models.ForeignKey(
        'commerciale.Chantier',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='commandes_travaux'
    )
    date_commande = models.DateField()
    date_debut_prevue = models.DateField(null=True, blank=True)
    date_fin_prevue = models.DateField(null=True, blank=True)
    type_travaux = models.CharField(max_length=50)
    description = models.TextField(null=True, blank=True)
    montant_ht = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    taux_tva = models.DecimalField(max_digits=5, decimal_places=2, default=20)
    montant_ttc = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    statut = models.CharField(
        max_length=20,
        choices=[
            ('brouillon', 'Brouillon'),
            ('confirmee', 'Confirmée'),
            ('en_cours', 'En cours'),
            ('terminee', 'Terminée'),
            ('annulee', 'Annulée'),
        ],
        default='brouillon'
    )
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        related_name='commandes_travaux_crees'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'travaux_commandes'
        verbose_name = 'Commande travaux'
        verbose_name_plural = 'Commandes travaux'
        ordering = ['-date_commande']

    def __str__(self):
        return f"{self.numero_commande} - {self.client}"

    def save(self, *args, **kwargs):
        if not self.numero_commande:
            from django.utils import timezone
            count = CommandeTravaux.objects.filter(
                date_commande__year=timezone.now().year
            ).count()
            self.numero_commande = f"CMD-TRAV-{timezone.now().year}-{count + 1:04d}"
        
        self.montant_ttc = self.montant_ht * (1 + self.taux_tva / 100)
        super().save(*args, **kwargs)


class FactureTravaux(models.Model):
    """Facture pour travaux"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    numero_facture = models.CharField(max_length=50, unique=True)
    commande = models.ForeignKey(
        CommandeTravaux,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='factures'
    )
    devis = models.ForeignKey(
        DevisTravaux,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='factures'
    )
    client = models.ForeignKey(
        'commerciale.Client',
        on_delete=models.CASCADE,
        related_name='factures_travaux'
    )
    chantier = models.ForeignKey(
        'commerciale.Chantier',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='factures_travaux'
    )
    date_facture = models.DateField()
    date_echeance = models.DateField(null=True, blank=True)
    type_travaux = models.CharField(max_length=50)
    description = models.TextField(null=True, blank=True)
    montant_ht = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    taux_tva = models.DecimalField(max_digits=5, decimal_places=2, default=20)
    montant_ttc = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    montant_paye = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    montant_restant = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    statut = models.CharField(
        max_length=20,
        choices=[
            ('brouillon', 'Brouillon'),
            ('emise', 'Émise'),
            ('payee', 'Payée'),
            ('partiellement_payee', 'Partiellement payée'),
            ('impayee', 'Impayée'),
        ],
        default='brouillon'
    )
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        related_name='factures_travaux_crees'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'travaux_factures'
        verbose_name = 'Facture travaux'
        verbose_name_plural = 'Factures travaux'
        ordering = ['-date_facture']

    def __str__(self):
        return f"{self.numero_facture} - {self.client}"

    def save(self, *args, **kwargs):
        if not self.numero_facture:
            from django.utils import timezone
            count = FactureTravaux.objects.filter(
                date_facture__year=timezone.now().year
            ).count()
            self.numero_facture = f"FAC-TRAV-{timezone.now().year}-{count + 1:04d}"
        
        self.montant_ttc = self.montant_ht * (1 + self.taux_tva / 100)
        self.montant_restant = self.montant_ttc - self.montant_paye
        
        # Mettre à jour le statut selon le paiement
        if self.montant_restant <= 0:
            self.statut = 'payee'
        elif self.montant_paye > 0:
            self.statut = 'partiellement_payee'
        elif self.statut == 'brouillon':
            pass  # Garder brouillon
        else:
            self.statut = 'emise'
        
        super().save(*args, **kwargs)


class LigneFactureTravaux(models.Model):
    """Ligne de facture travaux avec détail du calcul"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    facture = models.ForeignKey(
        FactureTravaux,
        on_delete=models.CASCADE,
        related_name='lignes'
    )
    designation = models.CharField(max_length=200)
    description = models.TextField(null=True, blank=True)
    quantite = models.DecimalField(max_digits=10, decimal_places=2, default=1)
    unite = models.CharField(
        max_length=20,
        choices=[
            ('unite', 'Unité'),
            ('heure', 'Heure'),
            ('jour', 'Jour'),
            ('m2', 'm²'),
            ('ml', 'mètre linéaire'),
            ('forfait', 'Forfait'),
        ],
        default='unite'
    )
    prix_unitaire_ht = models.DecimalField(max_digits=10, decimal_places=2)
    montant_ht = models.DecimalField(max_digits=10, decimal_places=2)
    taux_tva = models.DecimalField(max_digits=5, decimal_places=2, default=20)
    montant_ttc = models.DecimalField(max_digits=10, decimal_places=2)
    # Détail du calcul du prix (JSON pour stocker les éléments)
    detail_calcul = models.JSONField(
        default=dict,
        help_text="Détail du calcul : {main_oeuvre: {heures: 10, taux: 25}, materiaux: [...], autres: [...]}"
    )
    ordre = models.IntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'travaux_factures_lignes'
        verbose_name = 'Ligne facture travaux'
        verbose_name_plural = 'Lignes factures travaux'
        ordering = ['ordre', 'created_at']

    def __str__(self):
        return f"{self.facture.numero_facture} - {self.designation}"

    def save(self, *args, **kwargs):
        # Calculer le montant HT et TTC
        self.montant_ht = self.quantite * self.prix_unitaire_ht
        self.montant_ttc = self.montant_ht * (1 + self.taux_tva / 100)
        super().save(*args, **kwargs)



