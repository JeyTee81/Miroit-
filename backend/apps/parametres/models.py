from django.db import models
import uuid


class Imprimante(models.Model):
    """Modèle pour gérer les imprimantes locales et réseau"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    nom = models.CharField(max_length=200, help_text="Nom de l'imprimante")
    type_imprimante = models.CharField(
        max_length=20,
        choices=[
            ('locale', 'Locale'),
            ('reseau', 'Réseau'),
        ],
        default='locale'
    )
    # Pour imprimante locale
    nom_systeme = models.CharField(
        max_length=200,
        null=True,
        blank=True,
        help_text="Nom système de l'imprimante (ex: HP LaserJet Pro)"
    )
    # Pour imprimante réseau
    adresse_ip = models.GenericIPAddressField(
        null=True,
        blank=True,
        help_text="Adresse IP de l'imprimante réseau"
    )
    port = models.IntegerField(
        default=9100,
        help_text="Port de l'imprimante réseau (par défaut: 9100 pour RAW, 515 pour LPR)"
    )
    protocole = models.CharField(
        max_length=20,
        choices=[
            ('raw', 'RAW (Port 9100)'),
            ('lpr', 'LPR/LPD (Port 515)'),
            ('ipp', 'IPP (Port 631)'),
            ('http', 'HTTP'),
        ],
        default='raw',
        help_text="Protocole de communication avec l'imprimante réseau"
    )
    nom_reseau = models.CharField(
        max_length=200,
        null=True,
        blank=True,
        help_text="Nom réseau de l'imprimante (ex: \\\\SERVER\\PRINTER)"
    )
    # Paramètres généraux
    format_papier = models.CharField(
        max_length=20,
        choices=[
            ('A4', 'A4'),
            ('A3', 'A3'),
            ('Letter', 'Letter'),
            ('Legal', 'Legal'),
        ],
        default='A4'
    )
    orientation = models.CharField(
        max_length=10,
        choices=[
            ('portrait', 'Portrait'),
            ('paysage', 'Paysage'),
        ],
        default='portrait'
    )
    actif = models.BooleanField(default=True, help_text="Imprimante active et disponible")
    imprimante_par_defaut = models.BooleanField(
        default=False,
        help_text="Imprimante utilisée par défaut"
    )
    description = models.TextField(null=True, blank=True, help_text="Description ou notes")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'parametres_imprimantes'
        verbose_name = 'Imprimante'
        verbose_name_plural = 'Imprimantes'
        ordering = ['nom']

    def __str__(self):
        return f"{self.nom} ({self.get_type_imprimante_display()})"

    def save(self, *args, **kwargs):
        # S'assurer qu'une seule imprimante est par défaut
        if self.imprimante_par_defaut:
            queryset = Imprimante.objects.filter(imprimante_par_defaut=True)
            if self.id:
                queryset = queryset.exclude(id=self.id)
            queryset.update(imprimante_par_defaut=False)
        super().save(*args, **kwargs)

    def get_connection_string(self):
        """Retourne la chaîne de connexion selon le type"""
        if self.type_imprimante == 'locale':
            return self.nom_systeme or self.nom or 'N/A'
        else:  # réseau
            if not self.adresse_ip:
                return 'N/A'
            if self.protocole == 'raw':
                return f"{self.adresse_ip}:{self.port}"
            elif self.protocole == 'lpr':
                return f"lpr://{self.adresse_ip}/{self.nom_reseau or 'printer'}"
            elif self.protocole == 'ipp':
                return f"ipp://{self.adresse_ip}:{self.port}/{self.nom_reseau or 'printer'}"
            elif self.protocole == 'http':
                return f"http://{self.adresse_ip}:{self.port}"
            return f"{self.adresse_ip}:{self.port}"

