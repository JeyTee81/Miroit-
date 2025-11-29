"""
Module pour découvrir et lister les modèles Django disponibles
"""
from django.apps import apps
from django.db import models
from typing import Dict, List, Any, Optional
import inspect
import logging

logger = logging.getLogger(__name__)


class ModelDiscovery:
    """Classe pour découvrir les modèles Django disponibles"""
    
    @staticmethod
    def get_all_models() -> List[Dict[str, Any]]:
        """
        Retourne tous les modèles Django disponibles avec leurs informations
        """
        all_models = []
        
        for app_config in apps.get_app_configs():
            app_name = app_config.name
            app_label = app_config.label
            
            for model in app_config.get_models():
                model_info = {
                    'app_label': app_label,
                    'app_name': app_name,
                    'model_name': model.__name__,
                    'full_name': f"{app_label}.{model.__name__}",
                    'verbose_name': model._meta.verbose_name,
                    'verbose_name_plural': model._meta.verbose_name_plural,
                    'db_table': model._meta.db_table,
                }
                all_models.append(model_info)
        
        return sorted(all_models, key=lambda x: (x['app_label'], x['model_name']))
    
    @staticmethod
    def get_model_fields(app_label: str, model_name: str) -> List[Dict[str, Any]]:
        """
        Retourne tous les champs d'un modèle avec leurs informations
        """
        try:
            model = apps.get_model(app_label, model_name)
        except LookupError:
            raise ValueError(f"Modèle {app_label}.{model_name} introuvable")
        
        fields = []
        
        for field in model._meta.get_fields():
            field_info = {
                'name': field.name,
                'verbose_name': getattr(field, 'verbose_name', field.name),
                'type': type(field).__name__,
                'null': getattr(field, 'null', False),
                'blank': getattr(field, 'blank', False),
                'max_length': getattr(field, 'max_length', None),
                'choices': getattr(field, 'choices', None),
                'default': getattr(field, 'default', None),
                'help_text': getattr(field, 'help_text', ''),
            }
            
            # Informations supplémentaires selon le type de champ
            if isinstance(field, models.ForeignKey):
                field_info['related_model'] = f"{field.related_model._meta.app_label}.{field.related_model.__name__}"
                field_info['related_name'] = getattr(field, 'related_name', None)
            elif isinstance(field, models.ManyToManyField):
                field_info['related_model'] = f"{field.related_model._meta.app_label}.{field.related_model.__name__}"
            elif isinstance(field, models.DateField):
                field_info['auto_now'] = getattr(field, 'auto_now', False)
                field_info['auto_now_add'] = getattr(field, 'auto_now_add', False)
            elif isinstance(field, models.DateTimeField):
                field_info['auto_now'] = getattr(field, 'auto_now', False)
                field_info['auto_now_add'] = getattr(field, 'auto_now_add', False)
            
            fields.append(field_info)
        
        return fields
    
    @staticmethod
    def get_model_info(app_label: str, model_name: str) -> Dict[str, Any]:
        """
        Retourne les informations complètes d'un modèle
        """
        try:
            model = apps.get_model(app_label, model_name)
        except LookupError:
            raise ValueError(f"Modèle {app_label}.{model_name} introuvable")
        
        return {
            'app_label': app_label,
            'model_name': model_name,
            'full_name': f"{app_label}.{model_name}",
            'verbose_name': model._meta.verbose_name,
            'verbose_name_plural': model._meta.verbose_name_plural,
            'db_table': model._meta.db_table,
            'fields': ModelDiscovery.get_model_fields(app_label, model_name),
        }
    
    @staticmethod
    def import_to_model(
        app_label: str,
        model_name: str,
        data: List[Dict[str, Any]],
        column_mapping: Dict[str, str],
        options: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """
        Importe des données vers un modèle Django
        
        Args:
            app_label: Label de l'application Django
            model_name: Nom du modèle
            data: Liste de dictionnaires avec les données à importer
            column_mapping: Mapping {colonne_access: champ_django}
            options: Options d'import (skip_duplicates, update_existing, etc.)
        
        Returns:
            Dictionnaire avec le résultat de l'import
        """
        from django.db import transaction
        
        options = options or {}
        skip_duplicates = options.get('skip_duplicates', False)
        update_existing = options.get('update_existing', False)
        unique_fields = options.get('unique_fields', [])
        
        try:
            model = apps.get_model(app_label, model_name)
        except LookupError:
            raise ValueError(f"Modèle {app_label}.{model_name} introuvable")
        
        imported_count = 0
        updated_count = 0
        skipped_count = 0
        errors = []
        
        with transaction.atomic():
            for row_index, row in enumerate(data, start=1):
                try:
                    # Mapper les colonnes
                    model_data = {}
                    foreign_keys = {}
                    
                    for access_col, django_field in column_mapping.items():
                        if access_col not in row or row[access_col] is None:
                            continue
                        
                        value = row[access_col]
                        
                        # Vérifier si c'est une clé étrangère
                        field = model._meta.get_field(django_field)
                        if isinstance(field, (models.ForeignKey, models.OneToOneField)):
                            # Pour les ForeignKey, on peut passer l'ID ou chercher par un autre champ
                            related_model = field.related_model
                            
                            # Si la valeur est déjà un UUID ou un ID
                            if isinstance(value, str) and len(value) == 36:  # UUID format
                                try:
                                    foreign_keys[django_field] = related_model.objects.get(id=value)
                                except related_model.DoesNotExist:
                                    errors.append(f"Ligne {row_index}: {django_field} - ID {value} introuvable")
                                    continue
                            else:
                                # Chercher par un champ unique (ex: nom, code, etc.)
                                # On essaie de trouver par le premier champ unique
                                unique_field = None
                                for f in related_model._meta.get_fields():
                                    if f.name != 'id' and (getattr(f, 'unique', False) or f.primary_key):
                                        unique_field = f.name
                                        break
                                
                                if unique_field:
                                    try:
                                        foreign_keys[django_field] = related_model.objects.get(**{unique_field: value})
                                    except (related_model.DoesNotExist, related_model.MultipleObjectsReturned):
                                        errors.append(f"Ligne {row_index}: {django_field} - {value} introuvable ou ambigu")
                                        continue
                                else:
                                    errors.append(f"Ligne {row_index}: {django_field} - Impossible de résoudre la relation")
                                    continue
                        else:
                            # Champ normal
                            model_data[django_field] = value
                    
                    # Ajouter les ForeignKeys
                    model_data.update(foreign_keys)
                    
                    # Vérifier les doublons si demandé
                    if skip_duplicates or update_existing:
                        lookup = {}
                        for field_name in unique_fields:
                            if field_name in model_data:
                                lookup[field_name] = model_data[field_name]
                        
                        if lookup:
                            try:
                                existing = model.objects.get(**lookup)
                                if update_existing:
                                    # Mettre à jour l'objet existant
                                    for key, val in model_data.items():
                                        setattr(existing, key, val)
                                    existing.save()
                                    updated_count += 1
                                else:
                                    skipped_count += 1
                                continue
                            except model.DoesNotExist:
                                pass
                            except model.MultipleObjectsReturned:
                                errors.append(f"Ligne {row_index}: Doublon détecté")
                                skipped_count += 1
                                continue
                    
                    # Créer l'objet
                    model.objects.create(**model_data)
                    imported_count += 1
                    
                except Exception as e:
                    errors.append(f"Ligne {row_index}: {str(e)}")
                    logger.error(f"Erreur lors de l'import ligne {row_index}: {e}")
        
        return {
            'imported_count': imported_count,
            'updated_count': updated_count,
            'skipped_count': skipped_count,
            'total_count': len(data),
            'errors': errors,
            'errors_count': len(errors),
        }

