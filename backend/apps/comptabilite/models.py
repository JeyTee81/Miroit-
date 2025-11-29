from django.db import models
import uuid


class Compte(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    numero_compte = models.CharField(max_length=20, unique=True)
    libelle = models.CharField(max_length=200)
    type_compte = models.CharField(
        max_length=20,
        choices=[
            ('classe1', 'Classe 1'),
            ('classe2', 'Classe 2'),
            ('classe3', 'Classe 3'),
            ('classe4', 'Classe 4'),
            ('classe5', 'Classe 5'),
            ('classe6', 'Classe 6'),
            ('classe7', 'Classe 7'),
        ]
    )
    actif = models.BooleanField(default=True)

    class Meta:
        db_table = 'comptabilite_comptes'
        verbose_name = 'Compte'
        verbose_name_plural = 'Comptes'

    def __str__(self):
        return f"{self.numero_compte} - {self.libelle}"


class Ecriture(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    date_ecriture = models.DateField()
    compte_debit = models.ForeignKey(
        Compte,
        on_delete=models.PROTECT,
        related_name='ecritures_debit'
    )
    compte_credit = models.ForeignKey(
        Compte,
        on_delete=models.PROTECT,
        related_name='ecritures_credit'
    )
    montant = models.DecimalField(max_digits=10, decimal_places=2)
    libelle = models.CharField(max_length=200)
    reference_document = models.CharField(max_length=100, null=True, blank=True)
    facture = models.ForeignKey(
        'commerciale.Facture',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='ecritures'
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'comptabilite_ecritures'
        verbose_name = 'Écriture'
        verbose_name_plural = 'Écritures'

    def __str__(self):
        return f"{self.date_ecriture} - {self.libelle}"


class Banque(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    nom = models.CharField(max_length=200)
    numero_compte = models.CharField(max_length=50)
    iban = models.CharField(max_length=34, null=True, blank=True)
    bic = models.CharField(max_length=11, null=True, blank=True)
    actif = models.BooleanField(default=True)

    class Meta:
        db_table = 'comptabilite_banques'
        verbose_name = 'Banque'
        verbose_name_plural = 'Banques'

    def __str__(self):
        return f"{self.nom} - {self.numero_compte}"






