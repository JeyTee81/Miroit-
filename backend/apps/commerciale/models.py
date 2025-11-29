from django.db import models
from django.core.validators import MinValueValidator
import uuid
from django.conf import settings


class Client(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    type = models.CharField(
        max_length=20,
        choices=[
            ('particulier', 'Particulier'),
            ('professionnel', 'Professionnel'),
            ('entreprise', 'Entreprise'),
        ]
    )
    raison_sociale = models.CharField(max_length=200, null=True, blank=True)
    nom = models.CharField(max_length=100)
    prenom = models.CharField(max_length=100, null=True, blank=True)
    siret = models.CharField(max_length=14, null=True, blank=True, unique=True)
    adresse = models.TextField()
    code_postal = models.CharField(max_length=10)
    ville = models.CharField(max_length=100)
    pays = models.CharField(max_length=100, default='France')
    telephone = models.CharField(max_length=20, null=True, blank=True)
    email = models.EmailField(null=True, blank=True)
    commercial = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='clients'
    )
    zone_geographique = models.CharField(max_length=100, null=True, blank=True)
    famille_client = models.CharField(max_length=100, null=True, blank=True)
    date_creation = models.DateField(auto_now_add=True)
    actif = models.BooleanField(default=True)
    notes = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'clients'
        verbose_name = 'Client'
        verbose_name_plural = 'Clients'

    def __str__(self):
        if self.raison_sociale:
            return self.raison_sociale
        return f"{self.prenom} {self.nom}"


class Chantier(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    nom = models.CharField(max_length=200)
    client = models.ForeignKey(Client, on_delete=models.CASCADE, related_name='chantiers')
    adresse_livraison = models.TextField()
    date_debut = models.DateField()
    date_fin_prevue = models.DateField()
    date_fin_reelle = models.DateField(null=True, blank=True)
    statut = models.CharField(
        max_length=20,
        choices=[
            ('planifie', 'Planifié'),
            ('en_cours', 'En cours'),
            ('termine', 'Terminé'),
            ('annule', 'Annulé'),
        ],
        default='planifie'
    )
    chef_chantier = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='chantiers_chef'
    )
    commercial = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='chantiers_commercial'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'commerciale_chantiers'
        verbose_name = 'Chantier'
        verbose_name_plural = 'Chantiers'

    def __str__(self):
        return f"{self.nom} - {self.client}"


class Devis(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    numero_devis = models.CharField(max_length=50, unique=True)
    client = models.ForeignKey(Client, on_delete=models.CASCADE, related_name='devis')
    date_creation = models.DateField(auto_now_add=True)
    date_validite = models.DateField()
    montant_ht = models.DecimalField(max_digits=10, decimal_places=2, default=0)
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
    commercial = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        related_name='devis'
    )
    chantier = models.ForeignKey(
        Chantier,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='devis'
    )
    remise_pourcentage = models.DecimalField(max_digits=5, decimal_places=2, default=0)
    notes = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'commerciale_devis'
        verbose_name = 'Devis'
        verbose_name_plural = 'Devis'

    def __str__(self):
        return f"{self.numero_devis} - {self.client}"


class LigneDevis(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    devis = models.ForeignKey(Devis, on_delete=models.CASCADE, related_name='lignes')
    article = models.ForeignKey(
        'stock.Article',
        on_delete=models.SET_NULL,
        null=True,
        blank=True
    )
    designation = models.CharField(max_length=200)
    quantite = models.DecimalField(max_digits=10, decimal_places=2, validators=[MinValueValidator(0)])
    prix_unitaire_ht = models.DecimalField(max_digits=10, decimal_places=2)
    taux_tva = models.DecimalField(max_digits=5, decimal_places=2, default=20)
    remise_pourcentage = models.DecimalField(max_digits=5, decimal_places=2, default=0)
    ordre = models.IntegerField(default=0)

    class Meta:
        db_table = 'commerciale_lignes_devis'
        verbose_name = 'Ligne de devis'
        verbose_name_plural = 'Lignes de devis'
        ordering = ['ordre']

    def __str__(self):
        return f"{self.devis.numero_devis} - {self.designation}"


class Facture(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    numero_facture = models.CharField(max_length=50, unique=True, blank=True)
    devis = models.ForeignKey(
        Devis,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='factures'
    )
    client = models.ForeignKey(Client, on_delete=models.CASCADE, related_name='factures')
    date_facture = models.DateField()
    date_echeance = models.DateField()
    montant_ht = models.DecimalField(max_digits=10, decimal_places=2)
    montant_ttc = models.DecimalField(max_digits=10, decimal_places=2)
    montant_paye = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    statut = models.CharField(
        max_length=20,
        choices=[
            ('brouillon', 'Brouillon'),
            ('emise', 'Emise'),
            ('payee', 'Payée'),
            ('partielle', 'Partiellement payée'),
            ('impayee', 'Impayée'),
        ],
        default='brouillon'
    )
    commercial = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        related_name='factures'
    )
    chantier = models.ForeignKey(
        Chantier,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='factures'
    )
    compte_comptable = models.ForeignKey(
        'comptabilite.Compte',
        on_delete=models.SET_NULL,
        null=True,
        blank=True
    )
    pdf_path = models.CharField(max_length=500, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'commerciale_factures'
        verbose_name = 'Facture'
        verbose_name_plural = 'Factures'

    def __str__(self):
        return f"{self.numero_facture} - {self.client}"


class Paiement(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    facture = models.ForeignKey(Facture, on_delete=models.CASCADE, related_name='paiements')
    montant = models.DecimalField(max_digits=10, decimal_places=2)
    date_paiement = models.DateField()
    mode_paiement = models.CharField(
        max_length=20,
        choices=[
            ('especes', 'Espèces'),
            ('cheque', 'Chèque'),
            ('virement', 'Virement'),
            ('carte', 'Carte bancaire'),
            ('traite', 'Traite'),
        ]
    )
    numero_piece = models.CharField(max_length=100, null=True, blank=True)
    banque = models.ForeignKey(
        'comptabilite.Banque',
        on_delete=models.SET_NULL,
        null=True,
        blank=True
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'commerciale_paiements'
        verbose_name = 'Paiement'
        verbose_name_plural = 'Paiements'

    def __str__(self):
        return f"{self.facture.numero_facture} - {self.montant}€"


class VenteComptoir(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    numero_vente = models.CharField(max_length=50, unique=True)
    client = models.ForeignKey(
        Client,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='ventes_comptoir'
    )
    date_vente = models.DateField(auto_now_add=True)
    montant_ht = models.DecimalField(max_digits=10, decimal_places=2)
    montant_ttc = models.DecimalField(max_digits=10, decimal_places=2)
    mode_paiement = models.CharField(
        max_length=20,
        choices=[
            ('especes', 'Espèces'),
            ('carte', 'Carte bancaire'),
            ('cheque', 'Chèque'),
            ('virement', 'Virement'),
        ]
    )
    caisse = models.ForeignKey(
        'Caisse',
        on_delete=models.SET_NULL,
        null=True,
        related_name='ventes'
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'commerciale_ventes_comptoir'
        verbose_name = 'Vente comptoir'
        verbose_name_plural = 'Ventes comptoir'

    def __str__(self):
        return f"{self.numero_vente} - {self.date_vente}"


class Caisse(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    nom = models.CharField(max_length=100)
    solde_initial = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    solde_actuel = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    actif = models.BooleanField(default=True)

    class Meta:
        db_table = 'commerciale_caisses'
        verbose_name = 'Caisse'
        verbose_name_plural = 'Caisses'

    def __str__(self):
        return self.nom


# CommandeFournisseur a été déplacé vers stock.models pour éviter les dépendances circulaires
# Utiliser 'stock.CommandeFournisseur' pour les références


class Relance(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    facture = models.ForeignKey(Facture, on_delete=models.CASCADE, related_name='relances')
    date_relance = models.DateField()
    type_relance = models.CharField(
        max_length=20,
        choices=[
            ('devis', 'Devis'),
            ('facture', 'Facture'),
        ]
    )
    statut = models.CharField(
        max_length=20,
        choices=[
            ('envoyee', 'Envoyée'),
            ('payee', 'Payée'),
            ('annulee', 'Annulée'),
        ],
        default='envoyee'
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'commerciale_relances'
        verbose_name = 'Relance'
        verbose_name_plural = 'Relances'

    def __str__(self):
        return f"Relance {self.type_relance} - {self.facture.numero_facture}"

