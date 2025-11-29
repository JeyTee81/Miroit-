from django.db import models
import uuid
from django.conf import settings
from decimal import Decimal
import math


class Projet(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    numero_projet = models.CharField(max_length=50, unique=True)
    chantier = models.ForeignKey(
        'commerciale.Chantier',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='projets_vitrages'
    )
    nom = models.CharField(max_length=200)
    date_creation = models.DateField(auto_now_add=True)
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        related_name='projets_vitrages'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'vitrages_projets'
        verbose_name = 'Projet vitrage'
        verbose_name_plural = 'Projets vitrages'

    def __str__(self):
        return f"{self.numero_projet} - {self.nom}"


class RegionVentNeige(models.Model):
    """Régions de vent et de neige selon les normes françaises"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    code_region = models.CharField(max_length=10, unique=True)  # Ex: '1', '2', '3', '4'
    nom = models.CharField(max_length=100)
    pression_vent_reference = models.DecimalField(max_digits=8, decimal_places=2)  # en Pa
    charge_neige_reference = models.DecimalField(max_digits=8, decimal_places=2)  # en Pa
    latitude_min = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    latitude_max = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    longitude_min = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    longitude_max = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    description = models.TextField(null=True, blank=True)
    actif = models.BooleanField(default=True)

    class Meta:
        db_table = 'vitrages_regions_vent_neige'
        verbose_name = 'Région vent/neige'
        verbose_name_plural = 'Régions vent/neige'

    def __str__(self):
        return f"{self.code_region} - {self.nom}"


class CategorieTerrain(models.Model):
    """Catégories de terrains selon les normes"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    code = models.CharField(max_length=10, unique=True)  # Ex: 'I', 'II', 'III', 'IV'
    nom = models.CharField(max_length=100)
    description = models.TextField()
    coefficient_exposition = models.DecimalField(max_digits=5, decimal_places=2)
    photo_path = models.CharField(max_length=500, null=True, blank=True)
    actif = models.BooleanField(default=True)

    class Meta:
        db_table = 'vitrages_categories_terrain'
        verbose_name = 'Catégorie de terrain'
        verbose_name_plural = 'Catégories de terrain'

    def __str__(self):
        return f"{self.code} - {self.nom}"


class CalculVitrage(models.Model):
    """Calcul d'épaisseur de vitrage selon NF DTU 39 et Cahiers CSTB"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    projet = models.ForeignKey(Projet, on_delete=models.CASCADE, related_name='calculs')
    
    # Dimensions
    largeur = models.DecimalField(max_digits=10, decimal_places=2)  # en mm
    hauteur = models.DecimalField(max_digits=10, decimal_places=2)  # en mm
    
    # Type de vitrage
    type_vitrage = models.CharField(
        max_length=50,
        choices=[
            ('monolithique', 'Monolithique'),
            ('feuilleté', 'Feuilleté'),
            ('isolation', 'Isolation'),
            ('aquarium', 'Aquarium'),
            ('bassin', 'Bassin'),
            ('etagere', 'Étagère'),
            ('dalle_sol', 'Dalle de sol'),
            ('vea', 'VEA - Verre Extérieur Agrafé'),
            ('vec', 'VEC - Verre Extérieur Collé'),
            ('autre', 'Autre'),
        ],
        default='monolithique'
    )
    
    # Conditions environnementales
    region_vent = models.ForeignKey(
        RegionVentNeige,
        on_delete=models.PROTECT,
        related_name='calculs_vent',
        null=True,
        blank=True
    )
    region_neige = models.ForeignKey(
        RegionVentNeige,
        on_delete=models.PROTECT,
        related_name='calculs_neige',
        null=True,
        blank=True
    )
    categorie_terrain = models.ForeignKey(
        CategorieTerrain,
        on_delete=models.PROTECT,
        related_name='calculs',
        null=True,
        blank=True
    )
    altitude = models.DecimalField(max_digits=6, decimal_places=2, default=0)  # en mètres
    
    # Paramètres de calcul
    pression_vent = models.DecimalField(max_digits=8, decimal_places=2, null=True, blank=True)  # en Pa
    charge_neige = models.DecimalField(max_digits=8, decimal_places=2, null=True, blank=True)  # en Pa
    coefficient_securite = models.DecimalField(max_digits=5, decimal_places=2, default=2.5)
    
    # Résultats
    epaisseur_calculee = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)  # en mm
    epaisseur_recommandee = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)  # en mm
    resultat_calcul = models.JSONField(default=dict)
    
    # Normes utilisées
    norme_utilisee = models.CharField(max_length=100, default='NF DTU 39 P4')
    cahier_cstb = models.CharField(max_length=100, null=True, blank=True)
    
    # Note de calcul
    pdf_path = models.CharField(max_length=500, null=True, blank=True)
    entete_personnalisee = models.TextField(null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'vitrages_calculs'
        verbose_name = 'Calcul vitrage'
        verbose_name_plural = 'Calculs vitrages'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.projet.numero_projet} - {self.largeur}x{self.hauteur}mm"

    def calculer_epaisseur(self):
        """Calcule l'épaisseur de vitrage selon NF DTU 39"""
        try:
            # Calcul de la pression de vent si non fournie
            if not self.pression_vent and self.region_vent:
                pression_base = self.region_vent.pression_vent_reference
                # Ajustement selon l'altitude
                if self.altitude:
                    altitude_factor = 1 + (self.altitude / 1000) * 0.1
                    pression_base = pression_base * Decimal(str(altitude_factor))
                
                # Ajustement selon la catégorie de terrain
                if self.categorie_terrain:
                    pression_base = pression_base * self.categorie_terrain.coefficient_exposition
                
                self.pression_vent = pression_base
            
            # Calcul de la charge de neige si non fournie
            if not self.charge_neige and self.region_neige:
                charge_base = self.region_neige.charge_neige_reference
                # Ajustement selon l'altitude
                if self.altitude:
                    altitude_factor = 1 + (self.altitude / 1000) * 0.15
                    charge_base = charge_base * Decimal(str(altitude_factor))
                
                self.charge_neige = charge_base
            
            # Calcul selon le type de vitrage
            if self.type_vitrage in ['monolithique', 'feuilleté', 'isolation']:
                epaisseur = self._calculer_epaisseur_standard()
            elif self.type_vitrage == 'aquarium':
                epaisseur = self._calculer_epaisseur_aquarium()
            elif self.type_vitrage == 'bassin':
                epaisseur = self._calculer_epaisseur_bassin()
            elif self.type_vitrage == 'etagere':
                epaisseur = self._calculer_epaisseur_etagere()
            elif self.type_vitrage == 'dalle_sol':
                epaisseur = self._calculer_epaisseur_dalle_sol()
            elif self.type_vitrage in ['vea', 'vec']:
                epaisseur = self._calculer_epaisseur_vea_vec()
            else:
                epaisseur = self._calculer_epaisseur_standard()
            
            self.epaisseur_calculee = epaisseur
            # Épaisseur recommandée (arrondie au supérieur)
            self.epaisseur_recommandee = Decimal(str(math.ceil(float(epaisseur) / 2) * 2))
            
            # Stocker les détails du calcul
            self.resultat_calcul = {
                'pression_vent': float(self.pression_vent) if self.pression_vent else None,
                'charge_neige': float(self.charge_neige) if self.charge_neige else None,
                'epaisseur_calculee': float(epaisseur),
                'epaisseur_recommandee': float(self.epaisseur_recommandee),
                'norme': self.norme_utilisee,
                'cahier_cstb': self.cahier_cstb,
            }
            
            return epaisseur
        except Exception as e:
            self.resultat_calcul['erreur'] = str(e)
            return None

    def _calculer_epaisseur_standard(self):
        """Calcul standard selon NF DTU 39 P4"""
        if not self.pression_vent:
            return Decimal('6')  # Épaisseur minimale par défaut
        
        # Formule simplifiée selon NF DTU 39
        # e = k * sqrt(P * a^2 / sigma)
        # où P = pression, a = dimension, sigma = contrainte admissible
        
        # Contrainte admissible pour le verre (N/mm²)
        sigma_admissible = Decimal('50')  # Valeur standard pour verre trempé
        
        # Coefficient selon le type
        if self.type_vitrage == 'monolithique':
            k = Decimal('0.8')
        elif self.type_vitrage == 'feuilleté':
            k = Decimal('0.7')
        else:  # isolation
            k = Decimal('0.6')
        
        # Dimension la plus grande
        dimension_max = max(self.largeur, self.hauteur)
        
        # Calcul de l'épaisseur
        pression_mm = self.pression_vent / Decimal('1000')  # Conversion Pa en N/mm²
        epaisseur = k * Decimal(str(math.sqrt(float(pression_mm * dimension_max * dimension_max / sigma_admissible))))
        
        # Épaisseur minimale selon norme
        epaisseur_min = Decimal('4')
        return max(epaisseur, epaisseur_min)

    def _calculer_epaisseur_aquarium(self):
        """Calcul pour aquarium selon normes spécifiques"""
        # Pour aquarium, la pression est due à la hauteur d'eau
        hauteur_eau = self.hauteur / Decimal('1000')  # Conversion mm en mètres
        pression_hydrostatique = Decimal('9800') * hauteur_eau  # Pression en Pa (rho * g * h)
        
        # Utiliser la pression hydrostatique au lieu de la pression de vent
        pression = pression_hydrostatique
        dimension_max = max(self.largeur, self.hauteur)
        
        sigma_admissible = Decimal('50')
        k = Decimal('1.0')  # Coefficient plus élevé pour sécurité
        
        pression_mm = pression / Decimal('1000')
        epaisseur = k * Decimal(str(math.sqrt(float(pression_mm * dimension_max * dimension_max / sigma_admissible))))
        
        return max(epaisseur, Decimal('6'))  # Épaisseur minimale pour aquarium

    def _calculer_epaisseur_bassin(self):
        """Calcul pour bassin (similaire à aquarium mais avec charges supplémentaires)"""
        return self._calculer_epaisseur_aquarium() * Decimal('1.2')

    def _calculer_epaisseur_etagere(self):
        """Calcul pour étagère selon charge de neige ou charge d'exploitation"""
        charge = self.charge_neige or Decimal('5000')  # Charge par défaut en Pa
        dimension_max = max(self.largeur, self.hauteur)
        
        sigma_admissible = Decimal('50')
        k = Decimal('0.9')
        
        charge_mm = charge / Decimal('1000')
        epaisseur = k * Decimal(str(math.sqrt(float(charge_mm * dimension_max * dimension_max / sigma_admissible))))
        
        return max(epaisseur, Decimal('8'))  # Épaisseur minimale pour étagère

    def _calculer_epaisseur_dalle_sol(self):
        """Calcul pour dalle de sol selon norme 3443 CSTB"""
        # Charge d'exploitation standard pour dalle de sol
        charge = Decimal('5000')  # 5 kN/m²
        dimension_max = max(self.largeur, self.hauteur)
        
        sigma_admissible = Decimal('50')
        k = Decimal('1.1')  # Coefficient plus élevé pour sécurité
        
        charge_mm = charge / Decimal('1000')
        epaisseur = k * Decimal(str(math.sqrt(float(charge_mm * dimension_max * dimension_max / sigma_admissible))))
        
        return max(epaisseur, Decimal('10'))  # Épaisseur minimale pour dalle de sol

    def _calculer_epaisseur_vea_vec(self):
        """Calcul pour VEA (Verre Extérieur Agrafé) ou VEC (Verre Extérieur Collé)"""
        if not self.pression_vent:
            return Decimal('6')
        
        # Calcul spécifique pour verres agrafés/collés
        dimension_max = max(self.largeur, self.hauteur)
        sigma_admissible = Decimal('50')
        
        if self.type_vitrage == 'vea':
            k = Decimal('0.75')  # Verre agrafé
        else:  # vec
            k = Decimal('0.65')  # Verre collé
        
        pression_mm = self.pression_vent / Decimal('1000')
        epaisseur = k * Decimal(str(math.sqrt(float(pression_mm * dimension_max * dimension_max / sigma_admissible))))
        
        return max(epaisseur, Decimal('6'))


class Configuration(models.Model):
    """Configurations prédéfinies de vitrages"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    nom = models.CharField(max_length=200)
    type_vitrage = models.CharField(max_length=50)
    epaisseur = models.DecimalField(max_digits=5, decimal_places=2)
    coefficients = models.JSONField(default=dict)
    actif = models.BooleanField(default=True)

    class Meta:
        db_table = 'vitrages_configurations'
        verbose_name = 'Configuration vitrage'
        verbose_name_plural = 'Configurations vitrages'

    def __str__(self):
        return f"{self.nom} - {self.type_vitrage}"
