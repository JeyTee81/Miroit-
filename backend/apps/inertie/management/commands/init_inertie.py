"""
Commande pour initialiser les données par défaut du module inertie
Crée les familles de matériaux et corrige les profils existants
"""
from django.core.management.base import BaseCommand
from apps.inertie.models import FamilleMateriau, Profil


class Command(BaseCommand):
    help = 'Initialise les données par défaut du module inertie'

    def handle(self, *args, **options):
        self.stdout.write('Initialisation du module inertie...')
        
        # Créer les familles de matériaux par défaut
        self.stdout.write('\n1. Création des familles de matériaux...')
        
        acier, created = FamilleMateriau.objects.get_or_create(
            nom='ACIER',
            defaults={'module_elasticite': 21000}
        )
        if created:
            self.stdout.write(self.style.SUCCESS('  ✓ Famille ACIER créée'))
        else:
            self.stdout.write('  - Famille ACIER existe déjà')
        
        aluminium, created = FamilleMateriau.objects.get_or_create(
            nom='ALUMINIUM',
            defaults={'module_elasticite': 7000}
        )
        if created:
            self.stdout.write(self.style.SUCCESS('  ✓ Famille ALUMINIUM créée'))
        else:
            self.stdout.write('  - Famille ALUMINIUM existe déjà')
        
        verre, created = FamilleMateriau.objects.get_or_create(
            nom='VERRE',
            defaults={'module_elasticite': 70000}
        )
        if created:
            self.stdout.write(self.style.SUCCESS('  ✓ Famille VERRE créée'))
        else:
            self.stdout.write('  - Famille VERRE existe déjà')
        
        # Corriger les profils avec "TEMP"
        self.stdout.write('\n2. Correction des profils avec code_profil="TEMP"...')
        profils_temp = Profil.objects.filter(code_profil='TEMP')
        
        if profils_temp.exists():
            for profil in profils_temp:
                # Générer un code basé sur l'ID
                nouveau_code = f"PROFIL_{str(profil.id)[:8].upper()}"
                
                # Vérifier que le code n'existe pas déjà pour cette famille
                compteur = 1
                code_final = nouveau_code
                famille = profil.famille_materiau or acier
                
                while Profil.objects.filter(
                    famille_materiau=famille, 
                    code_profil=code_final
                ).exclude(id=profil.id).exists():
                    code_final = f"{nouveau_code}_{compteur}"
                    compteur += 1
                
                profil.code_profil = code_final
                
                # S'assurer que la famille est définie
                if not profil.famille_materiau:
                    profil.famille_materiau = acier
                
                # S'assurer que la désignation est définie
                if not profil.designation or profil.designation == '':
                    profil.designation = f"Profil {code_final}"
                
                # S'assurer que les inerties sont définies
                if not profil.inertie_ixx or profil.inertie_ixx == 0:
                    profil.inertie_ixx = 0
                if not profil.inertie_iyy or profil.inertie_iyy == 0:
                    profil.inertie_iyy = 0
                
                profil.save()
                self.stdout.write(f'  ✓ Profil {profil.id} mis à jour: code_profil="{code_final}"')
            
            self.stdout.write(self.style.SUCCESS(f'\n{profils_temp.count()} profil(s) corrigé(s)'))
        else:
            self.stdout.write('  - Aucun profil avec code_profil="TEMP" trouvé')
        
        self.stdout.write(self.style.SUCCESS('\n✓ Initialisation terminée avec succès!'))





