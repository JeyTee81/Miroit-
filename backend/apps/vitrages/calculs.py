"""
Calculs d'épaisseur de vitrage selon NF DTU 39 P4 et Cahiers CSTB
"""
from decimal import Decimal
import math


def calculer_pression_vent_ajustee(pression_base, altitude, coefficient_exposition):
    """Ajuste la pression de vent selon l'altitude et la catégorie de terrain"""
    # Ajustement altitude
    facteur_altitude = 1 + (altitude / 1000) * Decimal('0.1')
    pression = pression_base * facteur_altitude
    
    # Ajustement catégorie de terrain
    pression = pression * coefficient_exposition
    
    return pression


def calculer_charge_neige_ajustee(charge_base, altitude):
    """Ajuste la charge de neige selon l'altitude"""
    facteur_altitude = 1 + (altitude / 1000) * Decimal('0.15')
    return charge_base * facteur_altitude


def calculer_epaisseur_nf_dtu_39(pression, largeur, hauteur, type_vitrage='monolithique'):
    """
    Calcule l'épaisseur selon NF DTU 39 P4
    
    Formule: e = k * sqrt(P * a² / σ)
    où:
    - e = épaisseur (mm)
    - k = coefficient selon type de vitrage
    - P = pression (N/mm²)
    - a = dimension maximale (mm)
    - σ = contrainte admissible (N/mm²)
    """
    # Contrainte admissible pour verre trempé (N/mm²)
    sigma_admissible = Decimal('50')
    
    # Coefficients selon type
    coefficients = {
        'monolithique': Decimal('0.8'),
        'feuilleté': Decimal('0.7'),
        'isolation': Decimal('0.6'),
        'vea': Decimal('0.75'),
        'vec': Decimal('0.65'),
    }
    
    k = coefficients.get(type_vitrage, Decimal('0.8'))
    
    # Dimension maximale
    dimension_max = max(largeur, hauteur)
    
    # Conversion pression en N/mm²
    pression_n_mm2 = pression / Decimal('1000')
    
    # Calcul
    epaisseur = k * Decimal(str(math.sqrt(float(pression_n_mm2 * dimension_max * dimension_max / sigma_admissible))))
    
    # Épaisseur minimale
    epaisseur_min = Decimal('4')
    return max(epaisseur, epaisseur_min)


def calculer_epaisseur_aquarium(hauteur_eau_mm, largeur, hauteur):
    """
    Calcul pour aquarium basé sur la pression hydrostatique
    
    P = ρ * g * h
    où ρ = 1000 kg/m³, g = 9.8 m/s²
    """
    # Hauteur d'eau en mètres
    hauteur_eau_m = hauteur_eau_mm / Decimal('1000')
    
    # Pression hydrostatique (Pa)
    rho = Decimal('1000')  # kg/m³
    g = Decimal('9.8')  # m/s²
    pression = rho * g * hauteur_eau_m
    
    # Utiliser le calcul standard avec cette pression
    return calculer_epaisseur_nf_dtu_39(pression, largeur, hauteur, 'monolithique') * Decimal('1.1')


def calculer_epaisseur_dalle_sol_cstb_3443(charge_exploitation, largeur, hauteur):
    """
    Calcul pour dalle de sol selon norme 3443 des Cahiers CSTB
    """
    sigma_admissible = Decimal('50')
    k = Decimal('1.1')  # Coefficient de sécurité pour dalle
    
    dimension_max = max(largeur, hauteur)
    charge_n_mm2 = charge_exploitation / Decimal('1000')
    
    epaisseur = k * Decimal(str(math.sqrt(float(charge_n_mm2 * dimension_max * dimension_max / sigma_admissible))))
    
    return max(epaisseur, Decimal('10'))  # Épaisseur minimale 10mm




