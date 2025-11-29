from django.db import models
import uuid
from django.conf import settings


class Vehicule(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    immatriculation = models.CharField(max_length=20, unique=True)
    marque = models.CharField(max_length=100)
    modele = models.CharField(max_length=100)
    type = models.CharField(
        max_length=20,
        choices=[
            ('utilitaire', 'Utilitaire'),
            ('camion', 'Camion'),
            ('fourgon', 'Fourgon'),
        ]
    )
    capacite_charge = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    actif = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'tournees_vehicules'
        verbose_name = 'Véhicule'
        verbose_name_plural = 'Véhicules'

    def __str__(self):
        return f"{self.immatriculation} - {self.marque} {self.modele}"


class Chauffeur(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='chauffeur'
    )
    numero_permis = models.CharField(max_length=50)
    date_expiration_permis = models.DateField()
    actif = models.BooleanField(default=True)

    class Meta:
        db_table = 'tournees_chauffeurs'
        verbose_name = 'Chauffeur'
        verbose_name_plural = 'Chauffeurs'

    def __str__(self):
        return f"{self.user.nom} {self.user.prenom}"


class Tournee(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    numero_tournee = models.CharField(max_length=50, unique=True)
    date_tournee = models.DateField()
    vehicule = models.ForeignKey(Vehicule, on_delete=models.PROTECT, related_name='tournees')
    chauffeur = models.ForeignKey(Chauffeur, on_delete=models.PROTECT, related_name='tournees')
    statut = models.CharField(
        max_length=20,
        choices=[
            ('planifiee', 'Planifiée'),
            ('en_cours', 'En cours'),
            ('terminee', 'Terminée'),
            ('annulee', 'Annulée'),
        ],
        default='planifiee'
    )
    itineraire_optimise = models.JSONField(default=dict)
    distance_totale = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    duree_estimee = models.IntegerField(null=True, blank=True)  # en minutes
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'tournees_tournees'
        verbose_name = 'Tournée'
        verbose_name_plural = 'Tournées'

    def __str__(self):
        return f"{self.numero_tournee} - {self.date_tournee}"


class Livraison(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    tournee = models.ForeignKey(Tournee, on_delete=models.CASCADE, related_name='livraisons')
    facture = models.ForeignKey(
        'commerciale.Facture',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='livraisons'
    )
    chantier = models.ForeignKey(
        'commerciale.Chantier',
        on_delete=models.CASCADE,
        related_name='livraisons'
    )
    ordre_livraison = models.IntegerField()
    adresse_livraison = models.TextField()
    latitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    longitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    statut = models.CharField(
        max_length=20,
        choices=[
            ('planifiee', 'Planifiée'),
            ('en_transit', 'En transit'),
            ('livree', 'Livrée'),
            ('echec', 'Échec'),
        ],
        default='planifiee'
    )
    date_livraison_prevue = models.DateTimeField()
    date_livraison_reelle = models.DateTimeField(null=True, blank=True)
    signature_path = models.CharField(max_length=500, null=True, blank=True)
    notes = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'tournees_livraisons'
        verbose_name = 'Livraison'
        verbose_name_plural = 'Livraisons'

    def __str__(self):
        return f"{self.tournee.numero_tournee} - Ordre {self.ordre_livraison}"


class Chariot(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    numero = models.CharField(max_length=50, unique=True)
    type = models.CharField(max_length=100)
    capacite = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    actif = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'tournees_chariots'
        verbose_name = 'Chariot'
        verbose_name_plural = 'Chariots'

    def __str__(self):
        return f"{self.numero} - {self.type}"


class LivraisonChariot(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    livraison = models.ForeignKey(Livraison, on_delete=models.CASCADE, related_name='chariots')
    chariot = models.ForeignKey(Chariot, on_delete=models.PROTECT)
    quantite = models.IntegerField(default=1)

    class Meta:
        db_table = 'tournees_livraisons_chariots'
        verbose_name = 'Livraison chariot'
        verbose_name_plural = 'Livraisons chariots'

    def __str__(self):
        return f"{self.livraison} - {self.chariot.numero}"






