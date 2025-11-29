from django.db import models
import uuid
from django.conf import settings


class Projet(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    numero_projet = models.CharField(max_length=50, unique=True)
    devis = models.ForeignKey(
        'commerciale.Devis',
        on_delete=models.CASCADE,
        related_name='projets_menuiserie'
    )
    chantier = models.ForeignKey(
        'commerciale.Chantier',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='projets_menuiserie'
    )
    nom = models.CharField(max_length=200)
    date_creation = models.DateField(auto_now_add=True)
    statut = models.CharField(
        max_length=20,
        choices=[
            ('brouillon', 'Brouillon'),
            ('en_cours', 'En cours'),
            ('termine', 'Terminé'),
        ],
        default='brouillon'
    )
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        related_name='projets_menuiserie'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'menuiserie_projets'
        verbose_name = 'Projet menuiserie'
        verbose_name_plural = 'Projets menuiserie'

    def __str__(self):
        return f"{self.numero_projet} - {self.nom}"


class TarifFournisseur(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    fournisseur = models.ForeignKey(
        'stock.Fournisseur',
        on_delete=models.CASCADE,
        related_name='tarifs'
    )
    reference_fournisseur = models.CharField(max_length=100)
    designation = models.CharField(max_length=200)
    prix_unitaire_ht = models.DecimalField(max_digits=10, decimal_places=2)
    unite = models.CharField(
        max_length=10,
        choices=[
            ('unite', 'Unité'),
            ('m2', 'm²'),
            ('ml', 'mètre linéaire'),
            ('kg', 'Kilogramme'),
        ],
        default='unite'
    )
    date_validite_debut = models.DateField()
    date_validite_fin = models.DateField(null=True, blank=True)
    actif = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'menuiserie_tarifs_fournisseurs'
        verbose_name = 'Tarif fournisseur'
        verbose_name_plural = 'Tarifs fournisseurs'

    def __str__(self):
        return f"{self.fournisseur} - {self.designation}"


class OptionMenuiserie(models.Model):
    """Options disponibles pour les articles menuiserie (obligatoires ou facultatives)"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    code = models.CharField(max_length=50, unique=True)  # Ex: "FER_OB", "PETITS_BOIS"
    libelle = models.CharField(max_length=200)  # Ex: "Ferrage OB", "Petits bois"
    type_option = models.CharField(
        max_length=20,
        choices=[
            ('obligatoire', 'Obligatoire'),
            ('facultatif', 'Facultatif'),
        ]
    )
    type_article = models.CharField(
        max_length=20,
        choices=[
            ('fenetre', 'Fenêtre'),
            ('porte', 'Porte'),
            ('baie', 'Baie vitrée'),
            ('autre', 'Autre'),
            ('tous', 'Tous'),
        ],
        default='tous'
    )
    # Impact sur la désignation : texte à ajouter dans la désignation
    ajout_designation = models.CharField(max_length=200, null=True, blank=True)
    # Impact sur le prix : montant fixe ou pourcentage
    impact_prix_type = models.CharField(
        max_length=20,
        choices=[
            ('fixe', 'Montant fixe'),
            ('pourcentage', 'Pourcentage'),
            ('aucun', 'Aucun'),
        ],
        default='aucun'
    )
    impact_prix_valeur = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=0,
        help_text="Montant fixe en € ou pourcentage selon impact_prix_type"
    )
    # Impact sur le dessin : paramètres JSON pour modifier le dessin
    impact_dessin = models.JSONField(
        default=dict,
        blank=True,
        help_text="Paramètres pour modifier le dessin (ex: {ajout_element: 'ferrage', position: 'bas'})"
    )
    actif = models.BooleanField(default=True)
    ordre_affichage = models.IntegerField(default=0, help_text="Ordre d'affichage dans les listes")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'menuiserie_options'
        verbose_name = 'Option menuiserie'
        verbose_name_plural = 'Options menuiserie'
        ordering = ['type_option', 'ordre_affichage', 'libelle']

    def __str__(self):
        return f"{self.libelle} ({self.get_type_option_display()})"


class Article(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    projet = models.ForeignKey(Projet, on_delete=models.CASCADE, related_name='articles')
    designation = models.CharField(max_length=500)  # Augmenté pour la désignation générée
    designation_base = models.CharField(
        max_length=200,
        null=True,
        blank=True,
        help_text="Désignation de base avant ajout des options"
    )
    type_article = models.CharField(
        max_length=20,
        choices=[
            ('fenetre', 'Fenêtre'),
            ('porte', 'Porte'),
            ('baie', 'Baie vitrée'),
            ('autre', 'Autre'),
        ]
    )
    largeur = models.DecimalField(max_digits=10, decimal_places=2)
    hauteur = models.DecimalField(max_digits=10, decimal_places=2)
    profondeur = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    quantite = models.IntegerField(default=1)
    prix_unitaire_ht = models.DecimalField(max_digits=10, decimal_places=2)
    prix_base_ht = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        null=True,
        blank=True,
        help_text="Prix de base avant application des options"
    )
    dessin_path = models.CharField(max_length=500, null=True, blank=True)
    echelle_dessin = models.CharField(max_length=20, default='1:1', help_text="Échelle du dessin")
    # Stockage des IDs des options sélectionnées
    options_obligatoires = models.JSONField(
        default=list,
        help_text="Liste des IDs des options obligatoires sélectionnées"
    )
    options_facultatives = models.JSONField(
        default=list,
        help_text="Liste des IDs des options facultatives sélectionnées"
    )
    tarif_fournisseur = models.ForeignKey(
        TarifFournisseur,
        on_delete=models.SET_NULL,
        null=True,
        blank=True
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'menuiserie_articles'
        verbose_name = 'Article menuiserie'
        verbose_name_plural = 'Articles menuiserie'

    def __str__(self):
        return f"{self.projet.numero_projet} - {self.designation}"

    def calculer_prix_avec_options(self):
        """Calcule le prix unitaire HT en fonction du tarif fournisseur et des options"""
        from decimal import Decimal
        
        # Prix de base : tarif fournisseur ou prix_base_ht
        if self.tarif_fournisseur:
            prix_base = self.tarif_fournisseur.prix_unitaire_ht
            # Ajuster selon l'unité du tarif
            if self.tarif_fournisseur.unite == 'm2':
                surface = float(self.largeur * self.hauteur) / 10000  # cm² -> m²
                prix_base = Decimal(str(surface)) * prix_base
            elif self.tarif_fournisseur.unite == 'ml':
                perimetre = float(self.largeur + self.hauteur) * 2 / 100  # cm -> m
                prix_base = Decimal(str(perimetre)) * prix_base
        elif self.prix_base_ht:
            prix_base = self.prix_base_ht
        else:
            prix_base = self.prix_unitaire_ht
        
        prix_final = prix_base
        
        # Appliquer les options obligatoires
        if self.options_obligatoires:
            for option_id in self.options_obligatoires:
                try:
                    # Convertir en UUID si c'est une string
                    from uuid import UUID
                    if isinstance(option_id, str):
                        option_id = UUID(option_id)
                    option = OptionMenuiserie.objects.get(id=option_id, actif=True)
                    prix_final = self._appliquer_impact_prix(prix_final, option, prix_base)
                except (OptionMenuiserie.DoesNotExist, ValueError, TypeError):
                    pass
        
        # Appliquer les options facultatives
        if self.options_facultatives:
            for option_id in self.options_facultatives:
                try:
                    # Convertir en UUID si c'est une string
                    from uuid import UUID
                    if isinstance(option_id, str):
                        option_id = UUID(option_id)
                    option = OptionMenuiserie.objects.get(id=option_id, actif=True)
                    prix_final = self._appliquer_impact_prix(prix_final, option, prix_base)
                except (OptionMenuiserie.DoesNotExist, ValueError, TypeError):
                    pass
        
        return prix_final

    def _appliquer_impact_prix(self, prix_actuel, option, prix_base):
        """Applique l'impact d'une option sur le prix"""
        from decimal import Decimal
        
        if option.impact_prix_type == 'fixe':
            return prix_actuel + option.impact_prix_valeur
        elif option.impact_prix_type == 'pourcentage':
            return prix_actuel + (prix_base * option.impact_prix_valeur / Decimal('100'))
        return prix_actuel

    def generer_designation(self):
        """Génère la désignation complète en fonction des options"""
        designation_parts = []
        
        # Désignation de base
        if self.designation_base:
            designation_parts.append(self.designation_base)
        else:
            # Générer une désignation par défaut
            type_labels = {
                'fenetre': 'Fenêtre',
                'porte': 'Porte',
                'baie': 'Baie vitrée',
                'autre': 'Autre'
            }
            type_label = type_labels.get(self.type_article, self.type_article)
            try:
                designation_parts.append(f"{type_label} {int(self.largeur)}x{int(self.hauteur)}")
            except (ValueError, TypeError):
                designation_parts.append(f"{type_label}")
        
        # Ajouter les options obligatoires
        if self.options_obligatoires:
            for option_id in self.options_obligatoires:
                try:
                    # Convertir en UUID si c'est une string
                    from uuid import UUID
                    if isinstance(option_id, str):
                        option_id = UUID(option_id)
                    option = OptionMenuiserie.objects.get(id=option_id, actif=True)
                    if option.ajout_designation:
                        designation_parts.append(option.ajout_designation)
                except (OptionMenuiserie.DoesNotExist, ValueError, TypeError):
                    pass
        
        # Ajouter les options facultatives
        if self.options_facultatives:
            for option_id in self.options_facultatives:
                try:
                    # Convertir en UUID si c'est une string
                    from uuid import UUID
                    if isinstance(option_id, str):
                        option_id = UUID(option_id)
                    option = OptionMenuiserie.objects.get(id=option_id, actif=True)
                    if option.ajout_designation:
                        designation_parts.append(option.ajout_designation)
                except (OptionMenuiserie.DoesNotExist, ValueError, TypeError):
                    pass
        
        result = " - ".join(designation_parts) if designation_parts else self.designation
        # S'assurer qu'on retourne toujours quelque chose
        if not result:
            result = f"Article {self.type_article}"
        return result

    def save(self, *args, **kwargs):
        """Override save pour générer automatiquement la désignation et calculer le prix"""
        # Générer la désignation si elle n'est pas définie manuellement
        if not self.designation or (self.designation_base and self.designation == self.designation_base):
            try:
                self.designation = self.generer_designation()
            except Exception:
                # En cas d'erreur, utiliser une désignation par défaut
                if not self.designation:
                    self.designation = f"Article {self.type_article}"
        
        # Calculer le prix avec les options (seulement si tarif ou prix_base fourni)
        if self.tarif_fournisseur or self.prix_base_ht:
            try:
                self.prix_unitaire_ht = self.calculer_prix_avec_options()
            except Exception:
                # En cas d'erreur, garder le prix_unitaire_ht existant
                pass
        
        super().save(*args, **kwargs)


class Dessin(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    article = models.ForeignKey(Article, on_delete=models.CASCADE, related_name='dessins')
    fichier_path = models.CharField(max_length=500)
    echelle = models.CharField(max_length=20)
    format = models.CharField(
        max_length=10,
        choices=[
            ('pdf', 'PDF'),
            ('dwg', 'DWG'),
            ('dxf', 'DXF'),
        ]
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'menuiserie_dessins'
        verbose_name = 'Dessin'
        verbose_name_plural = 'Dessins'

    def __str__(self):
        return f"{self.article.designation} - {self.format}"



