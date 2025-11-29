from django.db import models
from django.core.validators import MinValueValidator
import uuid
from django.conf import settings


class Categorie(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    nom = models.CharField(max_length=100, unique=True)
    parent = models.ForeignKey(
        'self',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='sous_categories'
    )
    description = models.TextField(null=True, blank=True)

    class Meta:
        db_table = 'stock_categories'
        verbose_name = 'Catégorie'
        verbose_name_plural = 'Catégories'

    def __str__(self):
        return self.nom


class Article(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    reference = models.CharField(max_length=100, unique=True)
    designation = models.CharField(max_length=200)
    categorie = models.ForeignKey(Categorie, on_delete=models.PROTECT, related_name='articles')
    unite_mesure = models.CharField(
        max_length=10,
        choices=[
            ('unite', 'Unité'),
            ('m2', 'm²'),
            ('ml', 'mètre linéaire'),
            ('kg', 'Kilogramme'),
            ('m3', 'm³'),
        ],
        default='unite'
    )
    prix_achat_ht = models.DecimalField(max_digits=10, decimal_places=2)
    prix_vente_ht = models.DecimalField(max_digits=10, decimal_places=2)
    taux_tva = models.DecimalField(max_digits=5, decimal_places=2, default=20)
    stock_minimum = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    stock_actuel = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    actif = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'stock_articles'
        verbose_name = 'Article'
        verbose_name_plural = 'Articles'

    def __str__(self):
        return f"{self.reference} - {self.designation}"


class Fournisseur(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    raison_sociale = models.CharField(max_length=200)
    siret = models.CharField(max_length=14, null=True, blank=True, unique=True)
    adresse = models.TextField()
    code_postal = models.CharField(max_length=10)
    ville = models.CharField(max_length=100)
    pays = models.CharField(max_length=100, default='France')
    telephone = models.CharField(max_length=20, null=True, blank=True)
    email = models.EmailField(null=True, blank=True)
    contact = models.CharField(max_length=100, null=True, blank=True)
    actif = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'stock_fournisseurs'
        verbose_name = 'Fournisseur'
        verbose_name_plural = 'Fournisseurs'

    def __str__(self):
        return self.raison_sociale


class CommandeFournisseur(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    numero_commande = models.CharField(max_length=50, unique=True)
    fournisseur = models.ForeignKey(
        Fournisseur,
        on_delete=models.CASCADE,
        related_name='commandes'
    )
    date_commande = models.DateField()
    date_livraison_prevue = models.DateField()
    montant_ht = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    montant_ttc = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    statut = models.CharField(
        max_length=20,
        choices=[
            ('brouillon', 'Brouillon'),
            ('envoyee', 'Envoyée'),
            ('recue', 'Reçue'),
            ('partielle', 'Partielle'),
            ('annulee', 'Annulée'),
        ],
        default='brouillon'
    )
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        related_name='commandes_fournisseurs'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'stock_commandes_fournisseurs'
        verbose_name = 'Commande fournisseur'
        verbose_name_plural = 'Commandes fournisseurs'

    def __str__(self):
        return f"{self.numero_commande} - {self.fournisseur}"


class Mouvement(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    article = models.ForeignKey(Article, on_delete=models.PROTECT, related_name='mouvements')
    type_mouvement = models.CharField(
        max_length=20,
        choices=[
            ('entree', 'Entrée'),
            ('sortie', 'Sortie'),
            ('inventaire', 'Inventaire'),
            ('ajustement', 'Ajustement'),
        ]
    )
    quantite = models.DecimalField(max_digits=10, decimal_places=2, validators=[MinValueValidator(0)])
    prix_unitaire_ht = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        null=True,
        blank=True
    )
    date_mouvement = models.DateField()
    reference_document = models.CharField(max_length=100, null=True, blank=True)
    chantier = models.ForeignKey(
        'commerciale.Chantier',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='mouvements_stock'
    )
    commande_fournisseur = models.ForeignKey(
        CommandeFournisseur,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='mouvements'
    )
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        related_name='mouvements_stock'
    )
    notes = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'stock_mouvements'
        verbose_name = 'Mouvement'
        verbose_name_plural = 'Mouvements'

    def __str__(self):
        return f"{self.type_mouvement} - {self.article.reference} - {self.quantite}"


class CommandeFournisseurLigne(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    commande_fournisseur = models.ForeignKey(
        CommandeFournisseur,
        on_delete=models.CASCADE,
        related_name='lignes'
    )
    article = models.ForeignKey(Article, on_delete=models.PROTECT)
    quantite_commandee = models.DecimalField(max_digits=10, decimal_places=2)
    quantite_recue = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    prix_unitaire_ht = models.DecimalField(max_digits=10, decimal_places=2)
    date_livraison_prevue = models.DateField(null=True, blank=True)

    class Meta:
        db_table = 'stock_commandes_fournisseurs_lignes'
        verbose_name = 'Ligne commande fournisseur'
        verbose_name_plural = 'Lignes commandes fournisseurs'

    def __str__(self):
        return f"{self.commande_fournisseur.numero_commande} - {self.article.reference}"

