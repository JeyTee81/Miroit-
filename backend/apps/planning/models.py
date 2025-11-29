from django.db import models
import uuid
from django.conf import settings


class RendezVous(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    titre = models.CharField(max_length=200)
    description = models.TextField(null=True, blank=True)
    date_debut = models.DateTimeField()
    date_fin = models.DateTimeField()
    type = models.CharField(
        max_length=20,
        choices=[
            ('commercial', 'Commercial'),
            ('travaux', 'Travaux'),
            ('livraison', 'Livraison'),
        ]
    )
    utilisateur = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='rendez_vous'
    )
    client = models.ForeignKey(
        'commerciale.Client',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='rendez_vous'
    )
    chantier = models.ForeignKey(
        'commerciale.Chantier',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='rendez_vous'
    )
    lieu = models.CharField(max_length=200, null=True, blank=True)
    statut = models.CharField(
        max_length=20,
        choices=[
            ('planifie', 'Planifié'),
            ('confirme', 'Confirmé'),
            ('annule', 'Annulé'),
            ('termine', 'Terminé'),
        ],
        default='planifie'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'planning_rendez_vous'
        verbose_name = 'Rendez-vous'
        verbose_name_plural = 'Rendez-vous'

    def __str__(self):
        return f"{self.titre} - {self.date_debut}"






