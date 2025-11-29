# Generated manually to avoid circular dependency

from django.db import migrations, models
import django.db.models.deletion
import uuid


class Migration(migrations.Migration):

    dependencies = [
        ('comptabilite', '0001_initial'),
        ('commerciale', '0002_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='Ecriture',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('date_ecriture', models.DateField()),
                ('montant', models.DecimalField(decimal_places=2, max_digits=10)),
                ('libelle', models.CharField(max_length=200)),
                ('reference_document', models.CharField(blank=True, max_length=100, null=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('compte_credit', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, related_name='ecritures_credit', to='comptabilite.compte')),
                ('compte_debit', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, related_name='ecritures_debit', to='comptabilite.compte')),
                ('facture', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='ecritures', to='commerciale.facture')),
            ],
            options={
                'verbose_name': 'Écriture',
                'verbose_name_plural': 'Écritures',
                'db_table': 'comptabilite_ecritures',
            },
        ),
    ]






