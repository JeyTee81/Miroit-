from django.db import models
import uuid
from django.conf import settings
from decimal import Decimal


class FamilleMateriau(models.Model):
    """Famille de matériaux (ACIER, ALUMINIUM, VERRE)"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    nom = models.CharField(max_length=100, unique=True)  # ACIER, ALUMINIUM, VERRE
    module_elasticite = models.DecimalField(
        max_digits=10, 
        decimal_places=2,
        help_text="Module d'élasticité en daN/mm²"
    )
    actif = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'inertie_familles_materiaux'
        verbose_name = 'Famille de matériau'
        verbose_name_plural = 'Familles de matériaux'

    def __str__(self):
        return self.nom


class Profil(models.Model):
    """Profil avec inerties Ixx et Iyy"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    famille_materiau = models.ForeignKey(
        FamilleMateriau,
        on_delete=models.CASCADE,
        related_name='profils'
    )
    code_profil = models.CharField(max_length=100)  # Ex: 100x50x3.2
    designation = models.CharField(max_length=200)
    inertie_ixx = models.DecimalField(
        max_digits=15,
        decimal_places=2,
        help_text="Inertie Ixx en cm⁴"
    )
    inertie_iyy = models.DecimalField(
        max_digits=15,
        decimal_places=2,
        help_text="Inertie Iyy en cm⁴"
    )
    actif = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'inertie_profils'
        verbose_name = 'Profil'
        verbose_name_plural = 'Profils'
        unique_together = [['famille_materiau', 'code_profil']]

    def __str__(self):
        return f"{self.code_profil} - {self.designation}"


class Projet(models.Model):
    """Projet de calcul d'inertie"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    numero_projet = models.CharField(max_length=50, unique=True)
    chantier = models.ForeignKey(
        'commerciale.Chantier',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='projets_inertie'
    )
    nom = models.CharField(max_length=200)
    date_creation = models.DateField(auto_now_add=True)
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        related_name='projets_inertie'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'inertie_projets'
        verbose_name = 'Projet inertie'
        verbose_name_plural = 'Projets inertie'

    def __str__(self):
        return f"{self.numero_projet} - {self.nom}"


class CalculRaidisseur(models.Model):
    """Calcul d'inertie pour raidisseurs travaillant au vent et/ou à la neige"""
    TYPE_CHARGE_CHOICES = [
        ('rectangulaire_2_appuis', 'Rectangulaire sur 2 appuis'),
        ('encastrement_appui', '1 encastrement et 1 appui'),
        ('rectangulaire_3_appuis', 'Rectangulaire sur 3 appuis'),
        ('trapezoidale', 'Trapézoïdale'),
    ]
    
    REGION_VENT_CHOICES = [
        ('01', 'Région 01'),
        ('02', 'Région 02'),
        ('03', 'Région 03'),
        ('04', 'Région 04'),
    ]
    
    CATEGORIE_TERRAIN_CHOICES = [
        ('0', 'Catégorie 0'),
        ('I', 'Catégorie I'),
        ('II', 'Catégorie II'),
        ('III', 'Catégorie III'),
        ('IV', 'Catégorie IV'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    projet = models.ForeignKey(Projet, on_delete=models.CASCADE, related_name='calculs_raidisseur')
    nom_calcul = models.CharField(max_length=200, default="NF DTU 30.1 (2008 - fiche Technique N°45/2010)")
    
    # Type de charge
    type_charge = models.CharField(max_length=30, choices=TYPE_CHARGE_CHOICES)
    
    # Matériau
    famille_materiau = models.ForeignKey(FamilleMateriau, on_delete=models.PROTECT)
    module_elasticite = models.DecimalField(max_digits=10, decimal_places=2)  # daN/mm²
    
    # Dimensions
    portee = models.DecimalField(max_digits=10, decimal_places=2, help_text="Portée en mm")
    trame = models.DecimalField(max_digits=10, decimal_places=2, help_text="Trame en mm")
    
    # Flèche
    fleche_admissible = models.DecimalField(max_digits=10, decimal_places=2, help_text="Flèche admissible en mm")
    
    # Vent
    region_vent = models.CharField(max_length=2, choices=REGION_VENT_CHOICES, default='01')
    categorie_terrain = models.CharField(max_length=3, choices=CATEGORIE_TERRAIN_CHOICES, default='0')
    hauteur_sol = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True, help_text="Hauteur au dessus du sol en m")
    pente_toiture = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True, help_text="Pente de toiture en degrés")
    pente_obstacles = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True, help_text="Pente d'obstacles voisins en m")
    constructions_voisines = models.BooleanField(default=False, help_text="Constructions avoisinantes > 20m")
    
    # Neige (si applicable)
    region_neige = models.CharField(max_length=1, null=True, blank=True, choices=[('A', 'A'), ('B', 'B'), ('C', 'C')])
    
    # Résultats
    pression_vent = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True, help_text="Pression au vent en Pa")
    inertie_requise = models.DecimalField(max_digits=15, decimal_places=2, null=True, blank=True, help_text="Inertie Ixx requise en cm⁴")
    profil_selectionne = models.ForeignKey(Profil, on_delete=models.SET_NULL, null=True, blank=True)
    
    # Options
    calcul_avec_renfort = models.BooleanField(default=False)
    choix_automatique_profil = models.BooleanField(default=False)
    
    # Norme
    norme_utilisee = models.CharField(max_length=100, default='NF EN 1991-1-4/NA')
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'inertie_calculs_raidisseur'
        verbose_name = 'Calcul raidisseur'
        verbose_name_plural = 'Calculs raidisseur'

    def __str__(self):
        return f"{self.projet.numero_projet} - Raidisseur {self.type_charge}"


class CalculTraverse(models.Model):
    """Calcul d'inertie pour traverses travaillant au poids"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    projet = models.ForeignKey(Projet, on_delete=models.CASCADE, related_name='calculs_traverse')
    
    # Dimensions
    portee = models.DecimalField(max_digits=10, decimal_places=2, help_text="Portée en mm")
    trame_verticale = models.DecimalField(max_digits=10, decimal_places=2, help_text="Trame verticale au dessus de la traverse en mm")
    
    # Charges
    poids_remplissage = models.DecimalField(max_digits=10, decimal_places=2, help_text="Poids du remplissage en kg/m²")
    poids_traverse = models.DecimalField(max_digits=10, decimal_places=2, help_text="Poids de la traverse en kg/m")
    distance_blocage = models.DecimalField(max_digits=10, decimal_places=2, default=40, help_text="Distance de blocage en mm (défaut 40mm selon NF DTU 39 P1-1)")
    
    # Matériau
    famille_materiau = models.ForeignKey(FamilleMateriau, on_delete=models.PROTECT)
    module_elasticite = models.DecimalField(max_digits=10, decimal_places=2)  # daN/mm²
    
    # Flèche
    type_fleche = models.CharField(
        max_length=20,
        choices=[
            ('portee_200', 'Portée / 200'),
            ('portee_300', 'Portée / 300'),
            ('personnalise', 'Personnalisée'),
        ],
        default='portee_200'
    )
    fleche_admissible = models.DecimalField(max_digits=10, decimal_places=2, help_text="Flèche admissible en mm")
    
    # Résultats
    inertie_requise = models.DecimalField(max_digits=15, decimal_places=2, null=True, blank=True, help_text="Inertie Iy requise en cm⁴")
    profil_selectionne = models.ForeignKey(Profil, on_delete=models.SET_NULL, null=True, blank=True)
    
    # Options
    choix_automatique_profil = models.BooleanField(default=False)
    
    # Norme
    norme_utilisee = models.CharField(max_length=100, default='NF DTU 39 P1-1')
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'inertie_calculs_traverse'
        verbose_name = 'Calcul traverse'
        verbose_name_plural = 'Calculs traverse'

    def __str__(self):
        return f"{self.projet.numero_projet} - Traverse"


class CalculEI(models.Model):
    """Calcul EI pour menuiserie travaillant au vent"""
    TYPE_CHARGE_CHOICES = [
        ('type1', 'Type 1'),
        ('type2', 'Type 2'),
        ('type3', 'Type 3'),
        # Ajouter les autres types selon le document
    ]
    
    CATEGORIE_TERRAIN_CHOICES = [
        ('0', 'Catégorie 0'),
        ('I', 'Catégorie I'),
        ('II', 'Catégorie II'),
        ('III', 'Catégorie III'),
        ('IV', 'Catégorie IV'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    projet = models.ForeignKey(Projet, on_delete=models.CASCADE, related_name='calculs_ei')
    
    # Type de charge
    type_charge = models.CharField(max_length=30, choices=TYPE_CHARGE_CHOICES)
    
    # Matériau
    famille_materiau = models.ForeignKey(FamilleMateriau, on_delete=models.PROTECT)
    module_elasticite = models.DecimalField(max_digits=10, decimal_places=2)  # daN/mm²
    
    # Dimensions (selon le type de charge)
    dimensions = models.JSONField(default=dict, help_text="Dimensions selon le type de charge (S1, S2, S3, Q, etc.)")
    
    # Catégorie terrain
    categorie_terrain = models.CharField(max_length=3, choices=CATEGORIE_TERRAIN_CHOICES, default='0')
    
    # Résultats
    e1 = models.DecimalField(max_digits=15, decimal_places=6, null=True, blank=True)
    e2 = models.DecimalField(max_digits=15, decimal_places=6, null=True, blank=True)
    e3 = models.DecimalField(max_digits=15, decimal_places=6, null=True, blank=True)
    charge_exercee = models.DecimalField(max_digits=15, decimal_places=6, null=True, blank=True, help_text="Charge exercée")
    charge_admissible = models.DecimalField(max_digits=15, decimal_places=6, null=True, blank=True, help_text="Charge admissible")
    i_mini = models.DecimalField(max_digits=15, decimal_places=6, null=True, blank=True, help_text="I mini en cm⁴")
    i_reel = models.DecimalField(max_digits=15, decimal_places=6, null=True, blank=True, help_text="I réel en cm⁴")
    i_besoin = models.DecimalField(max_digits=15, decimal_places=6, null=True, blank=True, help_text="I besoin en cm⁴")
    pression_calcul = models.DecimalField(max_digits=15, decimal_places=2, null=True, blank=True, help_text="Pression de calcul en daN/m²")
    
    # Norme
    norme_utilisee = models.CharField(max_length=100, default='NF EN 1991-1-4:2005')
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'inertie_calculs_ei'
        verbose_name = 'Calcul EI'
        verbose_name_plural = 'Calculs EI'

    def __str__(self):
        return f"{self.projet.numero_projet} - Calcul EI {self.type_charge}"


class Configuration(models.Model):
    """Configuration par défaut et en-tête des notes de calcul"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    # En-tête
    client = models.CharField(max_length=200, blank=True)
    projet = models.CharField(max_length=200, blank=True)
    adresse = models.TextField(blank=True)
    reference = models.CharField(max_length=100, blank=True)
    titre_document = models.CharField(max_length=200, default="Note de calcul d'inertie")
    societe = models.CharField(max_length=200, blank=True)
    fichier_logo = models.CharField(max_length=500, blank=True)
    commentaires = models.TextField(blank=True)
    
    # Valeurs par défaut
    region_vent_defaut = models.CharField(max_length=2, default='01', choices=CalculRaidisseur.REGION_VENT_CHOICES)
    categorie_terrain_defaut = models.CharField(max_length=3, default='0', choices=CalculRaidisseur.CATEGORIE_TERRAIN_CHOICES)
    neige_defaut = models.CharField(max_length=1, default='A', choices=[('A', 'A'), ('B', 'B'), ('C', 'C')])
    
    # Normes
    norme_calcul = models.CharField(max_length=100, default='NF EN 1991-1-4:2005')
    type_calcul = models.CharField(
        max_length=20,
        choices=[
            ('eurocode1', 'Eurocode 1'),
            ('dtu39', 'DTU 39 P1-1'),
        ],
        default='eurocode1'
    )
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'inertie_configuration'
        verbose_name = 'Configuration'
        verbose_name_plural = 'Configurations'

    def __str__(self):
        return "Configuration inertie"


