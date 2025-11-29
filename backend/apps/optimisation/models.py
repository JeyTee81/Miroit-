from django.db import models
import uuid
from django.conf import settings
from decimal import Decimal


class Matiere(models.Model):
    """Bibliothèque de matières pour les débits"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    code = models.CharField(max_length=50, unique=True)
    designation = models.CharField(max_length=200)
    type_matiere = models.CharField(
        max_length=20,
        choices=[
            ('plaque', 'Plaque'),
            ('barre', 'Barre'),
            ('bobine', 'Bobine'),
            ('panneau', 'Panneau'),
            ('tole', 'Tôle'),
            ('vitrage', 'Vitrage'),
            ('plastique', 'Plastique'),
            ('autre', 'Autre'),
        ]
    )
    epaisseur = models.DecimalField(max_digits=8, decimal_places=2, null=True, blank=True)  # en mm
    largeur_standard = models.DecimalField(max_digits=8, decimal_places=2, null=True, blank=True)  # en mm
    longueur_standard = models.DecimalField(max_digits=8, decimal_places=2, null=True, blank=True)  # en mm
    unite = models.CharField(max_length=10, default='mm')
    prix_unitaire = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    actif = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'optimisation_matieres'
        verbose_name = 'Matière'
        verbose_name_plural = 'Matières'

    def __str__(self):
        return f"{self.code} - {self.designation}"


class ParametresDebit(models.Model):
    """Paramètres de débit (ré-équerrage, épaisseur lame, etc.)"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    nom = models.CharField(max_length=100, unique=True)
    reequerrage = models.DecimalField(max_digits=5, decimal_places=2, default=0)  # en mm
    epaisseur_lame = models.DecimalField(max_digits=5, decimal_places=2, default=3)  # en mm
    dimension_chute_jetee = models.DecimalField(max_digits=8, decimal_places=2, default=50)  # en mm
    dimension_chute_facturee = models.DecimalField(max_digits=8, decimal_places=2, default=100)  # en mm
    sens_coupe_par_defaut = models.CharField(
        max_length=20,
        choices=[
            ('transversal', 'Transversal'),
            ('longitudinal', 'Longitudinal'),
        ],
        default='transversal'
    )
    actif = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'optimisation_parametres_debit'
        verbose_name = 'Paramètres de débit'
        verbose_name_plural = 'Paramètres de débit'

    def __str__(self):
        return self.nom


class Affaire(models.Model):
    """Affaire contenant plusieurs lancements de débits"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    numero_affaire = models.CharField(max_length=50, unique=True)
    nom = models.CharField(max_length=200)
    chantier = models.ForeignKey(
        'commerciale.Chantier',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='affaires_debit'
    )
    description = models.TextField(null=True, blank=True)
    statut = models.CharField(
        max_length=20,
        choices=[
            ('brouillon', 'Brouillon'),
            ('en_cours', 'En cours'),
            ('termine', 'Terminé'),
            ('archive', 'Archivé'),
        ],
        default='brouillon'
    )
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        related_name='affaires_debit'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'optimisation_affaires'
        verbose_name = 'Affaire'
        verbose_name_plural = 'Affaires'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.numero_affaire} - {self.nom}"

    def save(self, *args, **kwargs):
        if not self.numero_affaire:
            from django.utils import timezone
            count = Affaire.objects.filter(
                created_at__year=timezone.now().year
            ).count()
            self.numero_affaire = f"DEB-{timezone.now().year}-{count + 1:04d}"
        super().save(*args, **kwargs)


class Lancement(models.Model):
    """Lancement de débit dans une affaire"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    affaire = models.ForeignKey(Affaire, on_delete=models.CASCADE, related_name='lancements')
    numero_lancement = models.CharField(max_length=50)
    date_lancement = models.DateField(auto_now_add=True)
    matiere = models.ForeignKey(Matiere, on_delete=models.PROTECT, related_name='lancements')
    parametres = models.ForeignKey(
        ParametresDebit,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='lancements'
    )
    description = models.TextField(null=True, blank=True)
    statut = models.CharField(
        max_length=20,
        choices=[
            ('brouillon', 'Brouillon'),
            ('optimise', 'Optimisé'),
            ('valide', 'Validé'),
            ('envoye_cnc', 'Envoyé CNC'),
        ],
        default='brouillon'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'optimisation_lancements'
        verbose_name = 'Lancement'
        verbose_name_plural = 'Lancements'
        ordering = ['-date_lancement', '-created_at']
        unique_together = [['affaire', 'numero_lancement']]

    def __str__(self):
        return f"{self.affaire.numero_affaire} - {self.numero_lancement}"


class Debit(models.Model):
    """Débit optimisé (plan de coupe)"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    lancement = models.ForeignKey(Lancement, on_delete=models.CASCADE, related_name='debits')
    numero_debit = models.CharField(max_length=50)
    
    # Dimensions de la plaque/barre source
    largeur_source = models.DecimalField(max_digits=8, decimal_places=2)  # en mm
    longueur_source = models.DecimalField(max_digits=8, decimal_places=2)  # en mm
    epaisseur = models.DecimalField(max_digits=8, decimal_places=2, null=True, blank=True)  # en mm
    
    # Pièces à découper
    pieces = models.JSONField(default=list)  # Liste de dicts: [{'largeur': 100, 'longueur': 200, 'quantite': 5, 'nom': 'Piece A'}]
    
    # Résultat de l'optimisation
    resultat_optimisation = models.JSONField(default=dict)  # Détails de l'optimisation
    plan_coupe = models.JSONField(default=list)  # Plan de coupe détaillé
    taux_utilisation = models.DecimalField(max_digits=5, decimal_places=2, default=0)  # en %
    nombre_plaques_necessaires = models.IntegerField(default=1)
    
    # Sens de coupe
    sens_coupe = models.CharField(
        max_length=20,
        choices=[
            ('transversal', 'Transversal'),
            ('longitudinal', 'Longitudinal'),
        ],
        default='transversal'
    )
    
    # Chutes générées
    chutes_reutilisables = models.JSONField(default=list)  # Liste des chutes réutilisables
    
    # Fichiers générés
    pdf_path = models.CharField(max_length=500, null=True, blank=True)
    fichier_cnc_path = models.CharField(max_length=500, null=True, blank=True)
    fichier_ascii_path = models.CharField(max_length=500, null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'optimisation_debits'
        verbose_name = 'Débit'
        verbose_name_plural = 'Débits'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.lancement.affaire.numero_affaire} - {self.numero_debit}"


class Chute(models.Model):
    """Chute réutilisable issue d'un débit"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    matiere = models.ForeignKey(Matiere, on_delete=models.CASCADE, related_name='chutes')
    debit = models.ForeignKey(
        Debit,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='chutes'
    )
    largeur = models.DecimalField(max_digits=8, decimal_places=2, null=True, blank=True)  # en mm
    longueur = models.DecimalField(max_digits=8, decimal_places=2, null=True, blank=True)  # en mm
    epaisseur = models.DecimalField(max_digits=8, decimal_places=2, null=True, blank=True)  # en mm
    quantite = models.IntegerField(default=1)
    surface = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)  # en mm²
    # Champ legacy pour compatibilité avec anciennes données
    dimensions = models.JSONField(default=dict, null=True, blank=True)
    statut = models.CharField(
        max_length=20,
        choices=[
            ('disponible', 'Disponible'),
            ('reservee', 'Réservée'),
            ('utilisee', 'Utilisée'),
            ('jetee', 'Jetée'),
        ],
        default='disponible'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'optimisation_chutes'
        verbose_name = 'Chute'
        verbose_name_plural = 'Chutes'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.matiere.code} - {self.largeur}x{self.longueur}mm"

    def save(self, *args, **kwargs):
        # Migrer depuis dimensions si nécessaire
        if self.dimensions and not self.largeur and not self.longueur:
            if isinstance(self.dimensions, dict):
                self.largeur = self.dimensions.get('largeur')
                self.longueur = self.dimensions.get('longueur')
        
        # Calculer la surface automatiquement
        if self.largeur and self.longueur:
            self.surface = self.largeur * self.longueur
        super().save(*args, **kwargs)


class StockMatiere(models.Model):
    """Stock de matières (plaques, barres) disponibles"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    matiere = models.ForeignKey(Matiere, on_delete=models.CASCADE, related_name='stocks')
    largeur = models.DecimalField(max_digits=8, decimal_places=2)  # en mm
    longueur = models.DecimalField(max_digits=8, decimal_places=2)  # en mm
    epaisseur = models.DecimalField(max_digits=8, decimal_places=2, null=True, blank=True)  # en mm
    quantite = models.IntegerField(default=1)
    quantite_reservee = models.IntegerField(default=0)
    prix_unitaire = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    emplacement = models.CharField(max_length=100, null=True, blank=True)
    date_reception = models.DateField(null=True, blank=True)
    date_peremption = models.DateField(null=True, blank=True)
    statut = models.CharField(
        max_length=20,
        choices=[
            ('disponible', 'Disponible'),
            ('reserve', 'Réservé'),
            ('epuise', 'Épuisé'),
        ],
        default='disponible'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'optimisation_stocks_matiere'
        verbose_name = 'Stock matière'
        verbose_name_plural = 'Stocks matières'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.matiere.code} - {self.largeur}x{self.longueur}mm (x{self.quantite})"

    @property
    def quantite_disponible(self):
        return self.quantite - self.quantite_reservee
