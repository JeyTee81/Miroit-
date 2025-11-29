"""
Commande pour corriger les profils avec code_profil = "TEMP"
Utilise la référence existante ou génère un code unique
"""
from django.core.management.base import BaseCommand
from apps.inertie.models import Profil, FamilleMateriau


class Command(BaseCommand):
    help = 'Corrige les profils avec code_profil = "TEMP"'

    def handle(self, *args, **options):
        # Récupérer ou créer une famille par défaut
        famille, _ = FamilleMateriau.objects.get_or_create(
            nom='ACIER',
            defaults={'module_elasticite': 21000}
        )

        # Trouver tous les profils avec "TEMP"
        profils_temp = Profil.objects.filter(code_profil='TEMP')
        
        if not profils_temp.exists():
            self.stdout.write(self.style.SUCCESS('Aucun profil avec code_profil="TEMP" trouvé.'))
            return

        self.stdout.write(f'Trouvé {profils_temp.count()} profil(s) à corriger.')

        for profil in profils_temp:
            # Essayer d'utiliser l'ancien champ 'reference' s'il existe encore
            if hasattr(profil, 'reference') and profil.reference:
                nouveau_code = profil.reference
            else:
                # Générer un code basé sur l'ID
                nouveau_code = f"PROFIL_{str(profil.id)[:8].upper()}"
            
            # Vérifier que le code n'existe pas déjà pour cette famille
            compteur = 1
            code_final = nouveau_code
            while Profil.objects.filter(famille_materiau=famille, code_profil=code_final).exclude(id=profil.id).exists():
                code_final = f"{nouveau_code}_{compteur}"
                compteur += 1
            
            profil.code_profil = code_final
            
            # S'assurer que la famille est définie
            if not profil.famille_materiau:
                profil.famille_materiau = famille
            
            # S'assurer que la désignation est définie
            if not profil.designation or profil.designation == '':
                if hasattr(profil, 'nom') and profil.nom:
                    profil.designation = profil.nom
                else:
                    profil.designation = f"Profil {code_final}"
            
            # S'assurer que les inerties sont définies
            if not profil.inertie_ixx or profil.inertie_ixx == 0:
                profil.inertie_ixx = 0
            if not profil.inertie_iyy or profil.inertie_iyy == 0:
                profil.inertie_iyy = 0
            
            profil.save()
            self.stdout.write(f'  ✓ Profil {profil.id} mis à jour: code_profil="{code_final}"')

        self.stdout.write(self.style.SUCCESS(f'\n{profils_temp.count()} profil(s) corrigé(s) avec succès!'))





