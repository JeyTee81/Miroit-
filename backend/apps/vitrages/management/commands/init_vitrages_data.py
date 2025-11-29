"""
Commande Django pour initialiser les données de référence du module Vitrages
Régions de vent/neige et catégories de terrain selon les normes françaises
"""
from django.core.management.base import BaseCommand
from apps.vitrages.models import RegionVentNeige, CategorieTerrain
from decimal import Decimal


class Command(BaseCommand):
    help = 'Initialise les données de référence pour le module Vitrages (régions vent/neige et catégories de terrain)'

    def handle(self, *args, **options):
        self.stdout.write('Initialisation des données de référence...')
        
        # Créer les régions de vent/neige selon les normes françaises
        self._create_regions_vent_neige()
        
        # Créer les catégories de terrain
        self._create_categories_terrain()
        
        self.stdout.write(self.style.SUCCESS('✓ Données initialisées avec succès'))

    def _create_regions_vent_neige(self):
        """Crée les régions de vent et de neige selon les normes françaises"""
        regions = [
            {
                'code_region': '1',
                'nom': 'Région 1 - Côtes de la Manche et de l\'Atlantique',
                'pression_vent_reference': Decimal('1000'),  # Pa
                'charge_neige_reference': Decimal('450'),  # Pa
                'latitude_min': Decimal('48.0'),
                'latitude_max': Decimal('51.0'),
                'longitude_min': Decimal('-5.0'),
                'longitude_max': Decimal('2.0'),
                'description': 'Région côtière avec vents forts et précipitations modérées',
            },
            {
                'code_region': '2',
                'nom': 'Région 2 - Centre et Nord de la France',
                'pression_vent_reference': Decimal('1100'),
                'charge_neige_reference': Decimal('550'),
                'latitude_min': Decimal('46.0'),
                'latitude_max': Decimal('50.0'),
                'longitude_min': Decimal('0.0'),
                'longitude_max': Decimal('7.0'),
                'description': 'Région continentale avec hivers modérés',
            },
            {
                'code_region': '3',
                'nom': 'Région 3 - Est de la France et massifs montagneux',
                'pression_vent_reference': Decimal('1200'),
                'charge_neige_reference': Decimal('900'),
                'latitude_min': Decimal('44.0'),
                'latitude_max': Decimal('49.0'),
                'longitude_min': Decimal('5.0'),
                'longitude_max': Decimal('8.0'),
                'description': 'Région avec hivers rigoureux et charges de neige importantes',
            },
            {
                'code_region': '4',
                'nom': 'Région 4 - Sud de la France et Méditerranée',
                'pression_vent_reference': Decimal('1300'),
                'charge_neige_reference': Decimal('200'),
                'latitude_min': Decimal('42.0'),
                'latitude_max': Decimal('46.0'),
                'longitude_min': Decimal('2.0'),
                'longitude_max': Decimal('8.0'),
                'description': 'Région méditerranéenne avec vents forts (Mistral, Tramontane) et peu de neige',
            },
        ]

        for region_data in regions:
            region, created = RegionVentNeige.objects.get_or_create(
                code_region=region_data['code_region'],
                defaults=region_data
            )
            if created:
                self.stdout.write(f'  ✓ Région {region.code_region} créée: {region.nom}')
            else:
                self.stdout.write(f'  - Région {region.code_region} existe déjà: {region.nom}')

    def _create_categories_terrain(self):
        """Crée les catégories de terrain selon les normes"""
        categories = [
            {
                'code': 'I',
                'nom': 'Catégorie I - Mer, lacs, zones côtières',
                'description': 'Zones exposées directement aux vents marins, sans obstacles significatifs. Coefficient d\'exposition élevé.',
                'coefficient_exposition': Decimal('1.0'),
            },
            {
                'code': 'II',
                'nom': 'Catégorie II - Campagne ouverte',
                'description': 'Zones rurales avec peu d\'obstacles (champs, prairies). Obstacles isolés de hauteur inférieure à 15 mètres.',
                'coefficient_exposition': Decimal('0.85'),
            },
            {
                'code': 'III',
                'nom': 'Catégorie III - Zones suburbaines, zones industrielles',
                'description': 'Zones avec bâtiments de hauteur uniforme inférieure à 15 mètres, zones industrielles, banlieues.',
                'coefficient_exposition': Decimal('0.70'),
            },
            {
                'code': 'IV',
                'nom': 'Catégorie IV - Zones urbaines denses',
                'description': 'Zones urbaines où au moins 15% des bâtiments ont une hauteur supérieure à 15 mètres et où la hauteur moyenne des bâtiments dépasse 25 mètres.',
                'coefficient_exposition': Decimal('0.60'),
            },
        ]

        for cat_data in categories:
            categorie, created = CategorieTerrain.objects.get_or_create(
                code=cat_data['code'],
                defaults=cat_data
            )
            if created:
                self.stdout.write(f'  ✓ Catégorie {categorie.code} créée: {categorie.nom}')
            else:
                self.stdout.write(f'  - Catégorie {categorie.code} existe déjà: {categorie.nom}')




