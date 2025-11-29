# Generated manually to add compte_comptable after comptabilite is created

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('commerciale', '0002_initial'),
        ('comptabilite', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='facture',
            name='compte_comptable',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, to='comptabilite.compte'),
        ),
    ]






