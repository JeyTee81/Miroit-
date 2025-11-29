"""
Algorithmes d'optimisation de débit
- Bin Packing pour les plaques
- Guillotine Cut (First Fit, Best Fit)
- Optimisation linéaire pour les barres
"""
from decimal import Decimal
from typing import List, Dict, Tuple
import math


class OptimiseurDebit:
    """Classe principale pour l'optimisation des débits"""
    
    def __init__(self, largeur_source: Decimal, longueur_source: Decimal, 
                 epaisseur_lame: Decimal = Decimal('3'),
                 reequerrage: Decimal = Decimal('0')):
        self.largeur_source = largeur_source
        self.longueur_source = longueur_source
        self.epaisseur_lame = epaisseur_lame
        self.reequerrage = reequerrage
        
    def optimiser_guillotine(self, pieces: List[Dict], sens_coupe: str = 'transversal') -> Dict:
        """
        Optimise le débit en utilisant l'algorithme Guillotine Cut
        
        Args:
            pieces: Liste de dicts avec 'largeur', 'longueur', 'quantite', 'nom'
            sens_coupe: 'transversal' ou 'longitudinal'
        
        Returns:
            Dict avec 'plan_coupe', 'taux_utilisation', 'chutes', 'nombre_plaques'
        """
        # Trier les pièces par surface décroissante
        pieces_triees = sorted(
            pieces,
            key=lambda p: Decimal(str(p['largeur'])) * Decimal(str(p['longueur'])) * p['quantite'],
            reverse=True
        )
        
        plan_coupe = []
        chutes = []
        nombre_plaques = 0
        surface_totale_pieces = Decimal('0')
        surface_totale_plaques = Decimal('0')
        
        # Créer la liste étendue des pièces (avec quantités)
        pieces_etendues = []
        for piece in pieces_triees:
            for _ in range(piece['quantite']):
                pieces_etendues.append({
                    'largeur': Decimal(str(piece['largeur'])),
                    'longueur': Decimal(str(piece['longueur'])),
                    'nom': piece.get('nom', ''),
                })
                surface_totale_pieces += Decimal(str(piece['largeur'])) * Decimal(str(piece['longueur']))
        
        # Placer les pièces sur les plaques
        pieces_placees = []
        plaque_courante = {
            'numero': 1,
            'largeur': self.largeur_source,
            'longueur': self.longueur_source,
            'pieces': [],
            'chutes': [],
        }
        
        for piece in pieces_etendues:
            # Essayer de placer la pièce sur la plaque courante
            if sens_coupe == 'transversal':
                # Coupe transversale : on coupe d'abord en largeur
                placee = self._placer_piece_transversal(
                    plaque_courante, piece, self.epaisseur_lame
                )
            else:
                # Coupe longitudinale : on coupe d'abord en longueur
                placee = self._placer_piece_longitudinal(
                    plaque_courante, piece, self.epaisseur_lame
                )
            
            if not placee:
                # La pièce ne rentre pas, créer une nouvelle plaque
                plan_coupe.append(plaque_courante)
                nombre_plaques += 1
                surface_totale_plaques += plaque_courante['largeur'] * plaque_courante['longueur']
                
                # Identifier les chutes réutilisables
                for chute in plaque_courante['chutes']:
                    if chute['largeur'] >= Decimal('100') and chute['longueur'] >= Decimal('100'):
                        chutes.append(chute)
                
                # Nouvelle plaque
                plaque_courante = {
                    'numero': nombre_plaques + 1,
                    'largeur': self.largeur_source,
                    'longueur': self.longueur_source,
                    'pieces': [],
                    'chutes': [],
                }
                
                # Réessayer de placer la pièce
                if sens_coupe == 'transversal':
                    self._placer_piece_transversal(plaque_courante, piece, self.epaisseur_lame)
                else:
                    self._placer_piece_longitudinal(plaque_courante, piece, self.epaisseur_lame)
        
        # Ajouter la dernière plaque
        if plaque_courante['pieces']:
            plan_coupe.append(plaque_courante)
            nombre_plaques += 1
            surface_totale_plaques += plaque_courante['largeur'] * plaque_courante['longueur']
            
            for chute in plaque_courante['chutes']:
                if chute['largeur'] >= Decimal('100') and chute['longueur'] >= Decimal('100'):
                    chutes.append(chute)
        
        # Calculer le taux d'utilisation
        if surface_totale_plaques > 0:
            taux_utilisation = (surface_totale_pieces / surface_totale_plaques) * Decimal('100')
        else:
            taux_utilisation = Decimal('0')
        
        return {
            'plan_coupe': plan_coupe,
            'taux_utilisation': float(taux_utilisation),
            'chutes': chutes,
            'nombre_plaques': nombre_plaques,
            'surface_totale_pieces': float(surface_totale_pieces),
            'surface_totale_plaques': float(surface_totale_plaques),
        }
    
    def _placer_piece_transversal(self, plaque: Dict, piece: Dict, epaisseur_lame: Decimal) -> bool:
        """Place une pièce sur une plaque avec coupe transversale"""
        largeur_piece = piece['largeur']
        longueur_piece = piece['longueur']
        
        # Vérifier si la pièce rentre dans la plaque
        if largeur_piece > plaque['largeur'] or longueur_piece > plaque['longueur']:
            return False
        
        # Chercher un emplacement disponible
        # Algorithme simple : placer en haut à gauche
        x = Decimal('0')
        y = Decimal('0')
        
        # Vérifier les collisions avec les pièces existantes
        for piece_existante in plaque['pieces']:
            # Si la nouvelle pièce chevauche une pièce existante, décaler
            if not (x + largeur_piece <= piece_existante['x'] or 
                   x >= piece_existante['x'] + piece_existante['largeur'] or
                   y + longueur_piece <= piece_existante['y'] or
                   y >= piece_existante['y'] + piece_existante['longueur']):
                # Collision, essayer de décaler
                y = piece_existante['y'] + piece_existante['longueur'] + epaisseur_lame
                if y + longueur_piece > plaque['longueur']:
                    return False
        
        # Vérifier que la pièce rentre toujours
        if x + largeur_piece > plaque['largeur'] or y + longueur_piece > plaque['longueur']:
            return False
        
        # Placer la pièce
        plaque['pieces'].append({
            'x': float(x),
            'y': float(y),
            'largeur': float(largeur_piece),
            'longueur': float(longueur_piece),
            'nom': piece.get('nom', ''),
        })
        
        # Mettre à jour les chutes (simplifié)
        # TODO: Implémenter un algorithme plus sophistiqué pour identifier les chutes
        
        return True
    
    def _placer_piece_longitudinal(self, plaque: Dict, piece: Dict, epaisseur_lame: Decimal) -> bool:
        """Place une pièce sur une plaque avec coupe longitudinale"""
        # Pour la coupe longitudinale, on inverse largeur et longueur
        largeur_piece = piece['longueur']  # Inversé
        longueur_piece = piece['largeur']  # Inversé
        
        if largeur_piece > plaque['largeur'] or longueur_piece > plaque['longueur']:
            return False
        
        x = Decimal('0')
        y = Decimal('0')
        
        for piece_existante in plaque['pieces']:
            if not (x + largeur_piece <= piece_existante['x'] or 
                   x >= piece_existante['x'] + piece_existante['largeur'] or
                   y + longueur_piece <= piece_existante['y'] or
                   y >= piece_existante['y'] + piece_existante['longueur']):
                y = piece_existante['y'] + piece_existante['longueur'] + epaisseur_lame
                if y + longueur_piece > plaque['longueur']:
                    return False
        
        if x + largeur_piece > plaque['largeur'] or y + longueur_piece > plaque['longueur']:
            return False
        
        plaque['pieces'].append({
            'x': float(x),
            'y': float(y),
            'largeur': float(largeur_piece),
            'longueur': float(longueur_piece),
            'nom': piece.get('nom', ''),
            'rotation': 90,  # Indiquer la rotation
        })
        
        return True
    
    def optimiser_barre(self, pieces: List[Dict], longueur_barre: Decimal) -> Dict:
        """
        Optimise le débit pour une barre (linéaire)
        
        Args:
            pieces: Liste de dicts avec 'longueur', 'quantite', 'nom'
            longueur_barre: Longueur de la barre source
        
        Returns:
            Dict avec 'plan_coupe', 'taux_utilisation', 'chutes', 'nombre_barres'
        """
        # Trier les pièces par longueur décroissante
        pieces_triees = sorted(
            pieces,
            key=lambda p: Decimal(str(p['longueur'])),
            reverse=True
        )
        
        plan_coupe = []
        chutes = []
        nombre_barres = 0
        longueur_totale_pieces = Decimal('0')
        longueur_totale_barres = Decimal('0')
        
        # Créer la liste étendue
        pieces_etendues = []
        for piece in pieces_triees:
            for _ in range(piece['quantite']):
                pieces_etendues.append({
                    'longueur': Decimal(str(piece['longueur'])),
                    'nom': piece.get('nom', ''),
                })
                longueur_totale_pieces += Decimal(str(piece['longueur']))
        
        # Placer les pièces sur les barres
        barre_courante = {
            'numero': 1,
            'longueur': longueur_barre,
            'pieces': [],
            'longueur_utilisee': Decimal('0'),
        }
        
        for piece in pieces_etendues:
            longueur_piece = piece['longueur']
            longueur_necessaire = longueur_piece + self.epaisseur_lame  # Ajouter l'épaisseur de la lame
            
            if barre_courante['longueur_utilisee'] + longueur_necessaire <= longueur_barre:
                # Placer sur la barre courante
                barre_courante['pieces'].append({
                    'position': float(barre_courante['longueur_utilisee']),
                    'longueur': float(longueur_piece),
                    'nom': piece.get('nom', ''),
                })
                barre_courante['longueur_utilisee'] += longueur_necessaire
            else:
                # Nouvelle barre
                chute_longueur = longueur_barre - barre_courante['longueur_utilisee']
                if chute_longueur >= Decimal('100'):  # Chute réutilisable si >= 100mm
                    chutes.append({
                        'longueur': float(chute_longueur),
                    })
                
                plan_coupe.append(barre_courante)
                nombre_barres += 1
                longueur_totale_barres += longueur_barre
                
                # Nouvelle barre
                barre_courante = {
                    'numero': nombre_barres + 1,
                    'longueur': longueur_barre,
                    'pieces': [],
                    'longueur_utilisee': Decimal('0'),
                }
                
                # Placer la pièce sur la nouvelle barre
                barre_courante['pieces'].append({
                    'position': 0,
                    'longueur': float(longueur_piece),
                    'nom': piece.get('nom', ''),
                })
                barre_courante['longueur_utilisee'] = longueur_necessaire
        
        # Ajouter la dernière barre
        if barre_courante['pieces']:
            chute_longueur = longueur_barre - barre_courante['longueur_utilisee']
            if chute_longueur >= Decimal('100'):
                chutes.append({
                    'longueur': float(chute_longueur),
                })
            
            plan_coupe.append(barre_courante)
            nombre_barres += 1
            longueur_totale_barres += longueur_barre
        
        # Calculer le taux d'utilisation
        if longueur_totale_barres > 0:
            taux_utilisation = (longueur_totale_pieces / longueur_totale_barres) * Decimal('100')
        else:
            taux_utilisation = Decimal('0')
        
        return {
            'plan_coupe': plan_coupe,
            'taux_utilisation': float(taux_utilisation),
            'chutes': chutes,
            'nombre_barres': nombre_barres,
            'longueur_totale_pieces': float(longueur_totale_pieces),
            'longueur_totale_barres': float(longueur_totale_barres),
        }




