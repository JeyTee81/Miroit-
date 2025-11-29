"""
Fonctions de calcul d'inertie selon les normes Eurocode et DTU
Basé sur PI-INERTIE 6.0
"""
from decimal import Decimal
from math import pi, sqrt


def calcul_inertie_tube_rectangulaire(hauteur_cm, largeur_cm, epaisseur_cm):
    """
    Calcule l'inertie Ixx et Iyy d'un tube rectangulaire creux
    
    Formule pour un tube rectangulaire creux :
    Ixx = (b*h³ - (b-2e)*(h-2e)³) / 12
    Iyy = (h*b³ - (h-2e)*(b-2e)³) / 12
    
    où :
    - b = largeur
    - h = hauteur
    - e = épaisseur
    """
    h = Decimal(str(hauteur_cm))
    b = Decimal(str(largeur_cm))
    e = Decimal(str(epaisseur_cm))
    
    # Inertie Ixx (par rapport à l'axe horizontal)
    ixx = (b * h**3 - (b - 2*e) * (h - 2*e)**3) / Decimal('12')
    
    # Inertie Iyy (par rapport à l'axe vertical)
    iyy = (h * b**3 - (h - 2*e) * (b - 2*e)**3) / Decimal('12')
    
    return {
        'ixx': float(ixx),
        'iyy': float(iyy)
    }


def calcul_pression_vent(region_vent, categorie_terrain, hauteur_sol=None, pente_toiture=None):
    """
    Calcule la pression au vent selon NF EN 1991-1-4/NA
    
    Cette fonction est simplifiée. Dans la réalité, le calcul est complexe
    et dépend de nombreux paramètres (coefficient d'exposition, coefficient de pression, etc.)
    """
    # Valeurs de base de pression dynamique selon région (en Pa)
    pressions_base = {
        '01': 800,   # Région 01
        '02': 1000,  # Région 02
        '03': 1200,  # Région 03
        '04': 1400,  # Région 04
    }
    
    # Coefficients selon catégorie de terrain
    coeff_terrain = {
        '0': 1.0,
        'I': 0.8,
        'II': 0.7,
        'III': 0.6,
        'IV': 0.5,
    }
    
    pression_base = pressions_base.get(region_vent, 1000)
    coeff = coeff_terrain.get(categorie_terrain, 1.0)
    
    # Application de coefficients supplémentaires selon hauteur et pente
    # (simplifié pour l'instant)
    pression = Decimal(str(pression_base)) * Decimal(str(coeff))
    
    if hauteur_sol:
        # Coefficient d'exposition selon hauteur (simplifié)
        if hauteur_sol > 20:
            pression *= Decimal('1.2')
        elif hauteur_sol > 10:
            pression *= Decimal('1.1')
    
    return float(pression)


def calcul_inertie_raidisseur_vent(
    portee_mm,
    trame_mm,
    pression_vent_pa,
    type_charge,
    module_elasticite,
    fleche_admissible_mm
):
    """
    Calcule l'inertie requise pour un raidisseur travaillant au vent
    
    Formule simplifiée selon le type de charge :
    - Rectangulaire sur 2 appuis : I = (5*q*L⁴) / (384*E*f)
    - 1 encastrement + 1 appui : I = (q*L⁴) / (185*E*f)
    - Rectangulaire sur 3 appuis : I = (q*L⁴) / (145*E*f)
    - Trapézoïdale : formule plus complexe
    
    où :
    - q = charge linéaire (N/mm) = pression * trame / 1000
    - L = portée (mm)
    - E = module d'élasticité (daN/mm² = N/mm² * 10)
    - f = flèche admissible (mm)
    """
    L = Decimal(str(portee_mm))
    trame = Decimal(str(trame_mm))
    pression = Decimal(str(pression_vent_pa))
    E = Decimal(str(module_elasticite)) * Decimal('10')  # Conversion daN/mm² -> N/mm²
    f = Decimal(str(fleche_admissible_mm))
    
    # Charge linéaire q = pression * trame / 1000 (en N/mm)
    q = (pression * trame) / Decimal('1000')
    
    # Coefficients selon type de charge
    coeffs = {
        'rectangulaire_2_appuis': Decimal('384'),
        'encastrement_appui': Decimal('185'),
        'rectangulaire_3_appuis': Decimal('145'),
        'trapezoidale': Decimal('200'),  # Approximation
    }
    
    coeff = coeffs.get(type_charge, Decimal('384'))
    
    # Calcul de l'inertie I = (coeff_num * q * L⁴) / (coeff * E * f)
    if type_charge == 'rectangulaire_2_appuis':
        coeff_num = Decimal('5')
    elif type_charge == 'encastrement_appui':
        coeff_num = Decimal('1')
    elif type_charge == 'rectangulaire_3_appuis':
        coeff_num = Decimal('1')
    else:  # trapézoïdale
        coeff_num = Decimal('1')
    
    # I en mm⁴, conversion en cm⁴ (diviser par 10⁴)
    I_mm4 = (coeff_num * q * L**4) / (coeff * E * f)
    I_cm4 = I_mm4 / Decimal('10000')
    
    return float(I_cm4)


def calcul_inertie_traverse_poids(
    portee_mm,
    trame_verticale_mm,
    poids_remplissage_kg_m2,
    poids_traverse_kg_m,
    distance_blocage_mm,
    module_elasticite,
    fleche_admissible_mm
):
    """
    Calcule l'inertie requise pour une traverse travaillant au poids
    
    Charge totale = (poids_remplissage * trame_verticale / 1000) + poids_traverse
    Charge linéaire q = charge_totale (en N/mm)
    
    Formule : I = (5*q*L⁴) / (384*E*f)
    """
    L = Decimal(str(portee_mm))
    trame_v = Decimal(str(trame_verticale_mm))
    poids_remp = Decimal(str(poids_remplissage_kg_m2))
    poids_trav = Decimal(str(poids_traverse_kg_m))
    E = Decimal(str(module_elasticite)) * Decimal('10')  # Conversion daN/mm² -> N/mm²
    f = Decimal(str(fleche_admissible_mm))
    
    # Charge totale en kg/m
    # Poids remplissage par mètre linéaire = poids_remplissage * trame_verticale / 1000
    charge_remplissage = (poids_remp * trame_v) / Decimal('1000')
    charge_totale = charge_remplissage + poids_trav
    
    # Conversion en N/mm (1 kg = 9.81 N, mais on simplifie à 10 N)
    q = (charge_totale * Decimal('10')) / Decimal('1000')  # N/mm
    
    # Calcul de l'inertie I = (5*q*L⁴) / (384*E*f)
    # I en mm⁴, conversion en cm⁴
    I_mm4 = (Decimal('5') * q * L**4) / (Decimal('384') * E * f)
    I_cm4 = I_mm4 / Decimal('10000')
    
    return float(I_cm4)


def calcul_ei_menuiserie(
    type_charge,
    dimensions,
    module_elasticite,
    categorie_terrain,
    i_reel=None
):
    """
    Calcule les valeurs E1, E2, E3, charge exercée, charge admissible, I mini, I besoin
    pour une menuiserie travaillant au vent
    
    Cette fonction est une implémentation simplifiée basée sur les formules standard
    pour les calculs de rigidité EI en menuiserie.
    
    Les formules exactes dépendent du type de charge et des dimensions spécifiques.
    """
    from decimal import Decimal
    
    E = Decimal(str(module_elasticite))  # daN/mm²
    
    # Extraire les dimensions
    S1 = Decimal(str(dimensions.get('S1', 0)))
    S2 = Decimal(str(dimensions.get('S2', 0)))
    S3 = Decimal(str(dimensions.get('S3', 0)))
    Q = Decimal(str(dimensions.get('Q', 0)))  # Charge en daN/m²
    
    # Calculs simplifiés selon le type de charge
    # Les formules exactes doivent être adaptées selon le document PI-INERTIE 6.0
    
    if type_charge == 'type1':
        # Type 1 : Calcul simplifié
        # E1, E2, E3 sont des coefficients de rigidité
        e1 = (E * S1) / Decimal('1000') if S1 > 0 else Decimal('0')
        e2 = (E * S2) / Decimal('1000') if S2 > 0 else Decimal('0')
        e3 = (E * S3) / Decimal('1000') if S3 > 0 else Decimal('0')
        
    elif type_charge == 'type2':
        # Type 2 : Calcul avec moyenne
        e1 = (E * (S1 + S2)) / Decimal('2000') if (S1 + S2) > 0 else Decimal('0')
        e2 = (E * S2) / Decimal('1000') if S2 > 0 else Decimal('0')
        e3 = (E * S3) / Decimal('1000') if S3 > 0 else Decimal('0')
        
    else:  # type3
        # Type 3 : Calcul complexe
        e1 = (E * S1) / Decimal('1000') if S1 > 0 else Decimal('0')
        e2 = (E * (S2 + S3)) / Decimal('2000') if (S2 + S3) > 0 else Decimal('0')
        e3 = (E * S3) / Decimal('1000') if S3 > 0 else Decimal('0')
    
    # Charge exercée (simplifié)
    charge_exercee = Q * (S1 + S2 + S3) / Decimal('3') if (S1 + S2 + S3) > 0 else Q
    
    # Charge admissible (basée sur E et dimensions)
    # Formule simplifiée : charge_admissible = E * I / L²
    # Ici on utilise une approximation
    charge_admissible = E * Decimal('100')  # Approximation
    
    # I mini (inertie minimale requise)
    # I = (charge * L⁴) / (384 * E * f)
    # Approximation simplifiée
    if charge_exercee > 0 and E > 0:
        i_mini = (charge_exercee * Decimal('1000000')) / (E * Decimal('100'))
    else:
        i_mini = Decimal('0')
    
    # I besoin (inertie nécessaire)
    i_besoin = i_mini * Decimal('1.2')  # Coefficient de sécurité
    
    # Pression de calcul (en daN/m²)
    pression_calcul = Q
    
    # Si I réel est fourni, on peut calculer la charge admissible réelle
    if i_reel is not None:
        i_reel_decimal = Decimal(str(i_reel))
        charge_admissible = (E * i_reel_decimal) / Decimal('100000')
    
    return {
        'e1': float(e1),
        'e2': float(e2),
        'e3': float(e3),
        'charge_exercee': float(charge_exercee),
        'charge_admissible': float(charge_admissible),
        'i_mini': float(i_mini),
        'i_reel': float(i_reel) if i_reel is not None else None,
        'i_besoin': float(i_besoin),
        'pression_calcul': float(pression_calcul),
    }


def selection_profil_automatique(famille_materiau, inertie_requise, type_inertie='ixx'):
    """
    Sélectionne automatiquement le profil le plus adapté
    
    Retourne le profil avec l'inertie la plus proche mais supérieure à l'inertie requise
    """
    from .models import Profil
    
    profils = Profil.objects.filter(
        famille_materiau=famille_materiau,
        actif=True
    )
    
    if not profils.exists():
        return None
    
    meilleur_profil = None
    meilleure_inertie = None
    
    for profil in profils:
        if type_inertie == 'ixx':
            inertie_profil = profil.inertie_ixx
        else:
            inertie_profil = profil.inertie_iyy
        
        if inertie_profil >= Decimal(str(inertie_requise)):
            if meilleure_inertie is None or inertie_profil < meilleure_inertie:
                meilleure_inertie = inertie_profil
                meilleur_profil = profil
    
    return meilleur_profil

