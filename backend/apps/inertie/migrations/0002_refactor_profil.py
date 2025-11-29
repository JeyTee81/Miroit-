# Generated manually to handle model refactoring

from django.db import migrations, models
import django.db.models.deletion
import uuid


def migrate_profil_data(apps, schema_editor):
    """Migrate old Profil data to new structure"""
    Profil = apps.get_model('inertie', 'Profil')
    FamilleMateriau = apps.get_model('inertie', 'FamilleMateriau')
    
    # Create default famille if it doesn't exist
    famille, _ = FamilleMateriau.objects.get_or_create(
        nom='ACIER',
        defaults={'module_elasticite': 21000}
    )
    
    # Migrate existing profils
    for profil in Profil.objects.all():
        # Use reference as code_profil if it exists
        if hasattr(profil, 'reference') and profil.reference:
            profil.code_profil = profil.reference
        else:
            # Generate a default code
            profil.code_profil = f"PROFIL_{profil.id.hex[:8]}"
        
        # Use nom as designation if it exists
        if hasattr(profil, 'nom') and profil.nom:
            profil.designation = profil.nom
        else:
            profil.designation = "Profil sans nom"
        
        # Set default inerties if they don't exist
        if not hasattr(profil, 'inertie_ixx') or profil.inertie_ixx is None:
            profil.inertie_ixx = 0
        if not hasattr(profil, 'inertie_iyy') or profil.inertie_iyy is None:
            profil.inertie_iyy = 0
        
        # Set default famille_materiau
        if not hasattr(profil, 'famille_materiau') or profil.famille_materiau is None:
            profil.famille_materiau = famille
        
        profil.save()


class Migration(migrations.Migration):

    dependencies = [
        ('inertie', '0001_initial'),
    ]

    operations = [
        # Create FamilleMateriau first
        migrations.CreateModel(
            name='FamilleMateriau',
            fields=[
                ('id', models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)),
                ('nom', models.CharField(max_length=100, unique=True)),
                ('module_elasticite', models.DecimalField(decimal_places=2, max_digits=10)),
                ('actif', models.BooleanField(default=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
            ],
            options={
                'db_table': 'inertie_familles_materiaux',
                'verbose_name': 'Famille de matériau',
                'verbose_name_plural': 'Familles de matériaux',
            },
        ),
        # Add new fields to Profil
        migrations.AddField(
            model_name='profil',
            name='code_profil',
            field=models.CharField(max_length=100, null=True),
        ),
        migrations.AddField(
            model_name='profil',
            name='designation',
            field=models.CharField(max_length=200, null=True),
        ),
        migrations.AddField(
            model_name='profil',
            name='inertie_ixx',
            field=models.DecimalField(decimal_places=2, max_digits=15, null=True),
        ),
        migrations.AddField(
            model_name='profil',
            name='inertie_iyy',
            field=models.DecimalField(decimal_places=2, max_digits=15, null=True),
        ),
        migrations.AddField(
            model_name='profil',
            name='famille_materiau',
            field=models.ForeignKey(null=True, on_delete=django.db.models.deletion.CASCADE, related_name='profils', to='inertie.famillemateriau'),
        ),
        migrations.AddField(
            model_name='profil',
            name='updated_at',
            field=models.DateTimeField(auto_now=True, null=True),
        ),
        # Migrate data
        migrations.RunPython(migrate_profil_data, migrations.RunPython.noop),
        # Make fields non-nullable
        migrations.AlterField(
            model_name='profil',
            name='code_profil',
            field=models.CharField(max_length=100),
        ),
        migrations.AlterField(
            model_name='profil',
            name='designation',
            field=models.CharField(max_length=200),
        ),
        migrations.AlterField(
            model_name='profil',
            name='inertie_ixx',
            field=models.DecimalField(decimal_places=2, max_digits=15),
        ),
        migrations.AlterField(
            model_name='profil',
            name='inertie_iyy',
            field=models.DecimalField(decimal_places=2, max_digits=15),
        ),
        migrations.AlterField(
            model_name='profil',
            name='famille_materiau',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='profils', to='inertie.famillemateriau'),
        ),
        # Remove old fields
        migrations.RemoveField(
            model_name='profil',
            name='reference',
        ),
        migrations.RemoveField(
            model_name='profil',
            name='nom',
        ),
        migrations.RemoveField(
            model_name='profil',
            name='type',
        ),
        migrations.RemoveField(
            model_name='profil',
            name='materiau',
        ),
        migrations.RemoveField(
            model_name='profil',
            name='dimensions',
        ),
        migrations.RemoveField(
            model_name='profil',
            name='caracteristiques',
        ),
        # Add unique constraint
        migrations.AlterUniqueTogether(
            name='profil',
            unique_together={('famille_materiau', 'code_profil')},
        ),
    ]

