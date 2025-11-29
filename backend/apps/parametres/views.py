from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
import platform
import subprocess
import json
import os
from .models import Imprimante
from .serializers import ImprimanteSerializer
from .import_access import AccessImporter
from .model_discovery import ModelDiscovery


class ImprimanteViewSet(viewsets.ModelViewSet):
    queryset = Imprimante.objects.all()
    serializer_class = ImprimanteSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['type_imprimante', 'actif', 'imprimante_par_defaut']
    search_fields = ['nom', 'adresse_ip', 'nom_reseau', 'nom_systeme']

    @action(detail=False, methods=['get'])
    def par_defaut(self, request):
        """Retourne l'imprimante par défaut"""
        imprimante = Imprimante.objects.filter(imprimante_par_defaut=True, actif=True).first()
        if imprimante:
            serializer = self.get_serializer(imprimante)
            return Response(serializer.data)
        return Response({'message': 'Aucune imprimante par défaut'}, status=status.HTTP_404_NOT_FOUND)

    @action(detail=False, methods=['get'])
    def actives(self, request):
        """Retourne toutes les imprimantes actives"""
        imprimantes = Imprimante.objects.filter(actif=True)
        serializer = self.get_serializer(imprimantes, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['post'])
    def definir_par_defaut(self, request, pk=None):
        """Définit cette imprimante comme imprimante par défaut"""
        imprimante = self.get_object()
        Imprimante.objects.filter(imprimante_par_defaut=True).update(imprimante_par_defaut=False)
        imprimante.imprimante_par_defaut = True
        imprimante.save()
        serializer = self.get_serializer(imprimante)
        return Response(serializer.data)

    @action(detail=True, methods=['post'])
    def tester(self, request, pk=None):
        """Teste la connexion à l'imprimante"""
        imprimante = self.get_object()
        # TODO: Implémenter un test de connexion réel
        # Pour l'instant, on retourne juste un message
        return Response({
            'message': f'Test de connexion à {imprimante.nom}',
            'connection_string': imprimante.get_connection_string(),
            'status': 'success'  # ou 'error' en cas d'échec
        })

    @action(detail=False, methods=['get'])
    def detecter_windows(self, request):
        """Détecte les imprimantes installées sur Windows"""
        if platform.system() != 'Windows':
            return Response({
                'error': 'Cette fonctionnalité est uniquement disponible sur Windows'
            }, status=status.HTTP_400_BAD_REQUEST)

        try:
            # Utiliser PowerShell pour lister les imprimantes Windows
            ps_command = """
            Get-Printer | Select-Object Name, PrinterStatus, DriverName, PortName | 
            ConvertTo-Json -Depth 3
            """
            
            result = subprocess.run(
                ['powershell', '-Command', ps_command],
                capture_output=True,
                text=True,
                encoding='utf-8'
            )
            
            if result.returncode != 0:
                return Response({
                    'error': f'Erreur lors de la détection: {result.stderr}'
                }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

            # Parser le JSON retourné par PowerShell
            try:
                printers_data = json.loads(result.stdout)
                # PowerShell peut retourner un objet unique ou un tableau
                if not isinstance(printers_data, list):
                    printers_data = [printers_data]
                
                printers = []
                for printer in printers_data:
                    printers.append({
                        'nom': printer.get('Name', ''),
                        'nom_systeme': printer.get('Name', ''),
                        'statut': printer.get('PrinterStatus', 'Unknown'),
                        'pilote': printer.get('DriverName', ''),
                        'port': printer.get('PortName', ''),
                    })
                
                return Response({
                    'printers': printers,
                    'count': len(printers)
                })
            except json.JSONDecodeError:
                return Response({
                    'error': 'Erreur lors du parsing des données',
                    'raw_output': result.stdout
                }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        except Exception as e:
            return Response({
                'error': f'Erreur: {str(e)}'
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    @action(detail=True, methods=['post'])
    def imprimer_test(self, request, pk=None):
        """Imprime une page de test sur l'imprimante"""
        imprimante = self.get_object()
        
        if platform.system() != 'Windows':
            return Response({
                'error': 'L\'impression directe est uniquement disponible sur Windows'
            }, status=status.HTTP_400_BAD_REQUEST)

        try:
            if imprimante.type_imprimante == 'locale':
                # Pour les imprimantes locales, utiliser le nom système
                printer_name = imprimante.nom_systeme or imprimante.nom
                
                # Créer un fichier texte de test
                test_content = f"""
========================================
PAGE DE TEST D'IMPRESSION
========================================

Imprimante: {imprimante.nom}
Type: {imprimante.get_type_imprimante_display()}
Date: {request.data.get('date', 'N/A')}

Ceci est une page de test pour vérifier que
l'imprimante fonctionne correctement.

Si vous voyez ce texte, l'impression fonctionne !

========================================
"""
                
                # Utiliser PowerShell pour imprimer
                ps_command = f"""
                $content = @'
{test_content}
'@
                $content | Out-Printer -Name "{printer_name}"
                """
                
                result = subprocess.run(
                    ['powershell', '-Command', ps_command],
                    capture_output=True,
                    text=True,
                    encoding='utf-8'
                )
                
                if result.returncode == 0:
                    return Response({
                        'message': f'Page de test envoyée à {imprimante.nom}',
                        'status': 'success'
                    })
                else:
                    return Response({
                        'error': f'Erreur lors de l\'impression: {result.stderr}',
                        'status': 'error'
                    }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
            
            else:
                # Pour les imprimantes réseau, on peut utiliser une connexion TCP/IP
                # Note: Cette implémentation est basique, une vraie implémentation
                # nécessiterait d'envoyer des commandes RAW ou utiliser un protocole spécifique
                return Response({
                    'message': f'Impression réseau vers {imprimante.adresse_ip}',
                    'connection_string': imprimante.get_connection_string(),
                    'note': 'L\'impression réseau nécessite une configuration spécifique',
                    'status': 'info'
                })

        except Exception as e:
            return Response({
                'error': f'Erreur: {str(e)}',
                'status': 'error'
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class ImportAccessViewSet(viewsets.ViewSet):
    """ViewSet pour l'import depuis Access"""
    permission_classes = [IsAuthenticated]
    
    @action(detail=False, methods=['get'])
    def verifier_disponibilite(self, request):
        """Vérifie si pyodbc est disponible"""
        try:
            from .import_access import PYODBC_AVAILABLE
            if PYODBC_AVAILABLE:
                return Response({
                    'available': True,
                    'message': 'pyodbc est disponible'
                })
            else:
                return Response({
                    'available': False,
                    'message': 'pyodbc n\'est pas installé ou n\'est pas compatible',
                    'instructions': (
                        'Pour utiliser l\'import Access, vous devez installer pyodbc. '
                        'Note: pyodbc nécessite une compilation et peut ne pas être compatible '
                        'avec toutes les versions de Python. Python 3.8-3.13 est recommandé.'
                    )
                }, status=status.HTTP_503_SERVICE_UNAVAILABLE)
        except Exception as e:
            return Response({
                'available': False,
                'error': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    @action(detail=False, methods=['post'])
    def tester_connexion(self, request):
        """Teste la connexion à un fichier Access"""
        file_path = request.data.get('file_path')
        if not file_path:
            return Response({
                'error': 'Le chemin du fichier est requis'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        if not os.path.exists(file_path):
            return Response({
                'error': f'Le fichier n\'existe pas: {file_path}'
            }, status=status.HTTP_404_NOT_FOUND)
        
        try:
            result = AccessImporter.test_connection(file_path)
            if result['success']:
                return Response(result, status=status.HTTP_200_OK)
            else:
                return Response(result, status=status.HTTP_400_BAD_REQUEST)
        except ImportError as e:
            return Response({
                'error': str(e),
                'available': False
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)
        except Exception as e:
            return Response({
                'error': f'Erreur: {str(e)}'
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    @action(detail=False, methods=['post'])
    def lister_tables(self, request):
        """Liste toutes les tables d'un fichier Access"""
        file_path = request.data.get('file_path')
        if not file_path:
            return Response({
                'error': 'Le chemin du fichier est requis'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        if not os.path.exists(file_path):
            return Response({
                'error': f'Le fichier n\'existe pas: {file_path}'
            }, status=status.HTTP_404_NOT_FOUND)
        
        try:
            tables = AccessImporter.list_tables(file_path)
            return Response({
                'tables': tables,
                'count': len(tables)
            }, status=status.HTTP_200_OK)
        except ImportError as e:
            return Response({
                'error': str(e),
                'available': False
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)
        except Exception as e:
            return Response({
                'error': f'Erreur lors de la lecture des tables: {str(e)}'
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    @action(detail=False, methods=['post'])
    def lister_colonnes(self, request):
        """Liste les colonnes d'une table Access"""
        file_path = request.data.get('file_path')
        table_name = request.data.get('table_name')
        
        if not file_path or not table_name:
            return Response({
                'error': 'Le chemin du fichier et le nom de la table sont requis'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        if not os.path.exists(file_path):
            return Response({
                'error': f'Le fichier n\'existe pas: {file_path}'
            }, status=status.HTTP_404_NOT_FOUND)
        
        try:
            columns = AccessImporter.get_table_columns(file_path, table_name)
            return Response({
                'columns': columns,
                'count': len(columns)
            }, status=status.HTTP_200_OK)
        except ImportError as e:
            return Response({
                'error': str(e),
                'available': False
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)
        except Exception as e:
            return Response({
                'error': f'Erreur lors de la lecture des colonnes: {str(e)}'
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    @action(detail=False, methods=['post'])
    def apercu_donnees(self, request):
        """Aperçu des données d'une table avec filtres optionnels"""
        file_path = request.data.get('file_path')
        table_name = request.data.get('table_name')
        limit = request.data.get('limit', 10)
        where_clause = request.data.get('where_clause', None)
        
        if not file_path or not table_name:
            return Response({
                'error': 'Le chemin du fichier et le nom de la table sont requis'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        if not os.path.exists(file_path):
            return Response({
                'error': f'Le fichier n\'existe pas: {file_path}'
            }, status=status.HTTP_404_NOT_FOUND)
        
        try:
            data = AccessImporter.get_table_data_filtered(
                file_path, 
                table_name, 
                where_clause=where_clause,
                limit=int(limit)
            )
            row_count = AccessImporter.get_row_count(file_path, table_name, where_clause=where_clause)
            return Response({
                'data': data,
                'row_count': row_count,
                'preview_count': len(data)
            }, status=status.HTTP_200_OK)
        except ImportError as e:
            return Response({
                'error': str(e),
                'available': False
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)
        except Exception as e:
            return Response({
                'error': f'Erreur lors de la lecture des données: {str(e)}'
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    @action(detail=False, methods=['get'])
    def lister_modeles(self, request):
        """Liste tous les modèles Django disponibles"""
        try:
            models = ModelDiscovery.get_all_models()
            return Response({
                'models': models,
                'count': len(models)
            }, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({
                'error': f'Erreur lors de la liste des modèles: {str(e)}'
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    @action(detail=False, methods=['post'])
    def obtenir_champs_modele(self, request):
        """Obtient les champs d'un modèle Django"""
        app_label = request.data.get('app_label')
        model_name = request.data.get('model_name')
        
        if not app_label or not model_name:
            return Response({
                'error': 'app_label et model_name sont requis'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            fields = ModelDiscovery.get_model_fields(app_label, model_name)
            model_info = ModelDiscovery.get_model_info(app_label, model_name)
            return Response({
                'model': model_info,
                'fields': fields,
                'count': len(fields)
            }, status=status.HTTP_200_OK)
        except ValueError as e:
            return Response({
                'error': str(e)
            }, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            return Response({
                'error': f'Erreur: {str(e)}'
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    @action(detail=False, methods=['post'])
    def importer_donnees(self, request):
        """
        Importe les données d'une table Access vers un modèle Django
        Supporte le filtrage et le mapping flexible
        """
        file_path = request.data.get('file_path')
        table_name = request.data.get('table_name')
        app_label = request.data.get('app_label')  # Ex: 'commerciale'
        model_name = request.data.get('model_name')  # Ex: 'Client'
        column_mapping = request.data.get('column_mapping', {})  # {'nom_access': 'champ_django'}
        where_clause = request.data.get('where_clause', None)  # Filtre SQL optionnel
        options = request.data.get('options', {})  # Options d'import
        
        if not file_path or not table_name or not app_label or not model_name:
            return Response({
                'error': 'Le chemin du fichier, le nom de la table, app_label et model_name sont requis'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        if not column_mapping:
            return Response({
                'error': 'Le mapping des colonnes est requis'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        if not os.path.exists(file_path):
            return Response({
                'error': f'Le fichier n\'existe pas: {file_path}'
            }, status=status.HTTP_404_NOT_FOUND)
        
        try:
            # Récupérer les données avec filtre optionnel
            data = AccessImporter.get_table_data_filtered(
                file_path, 
                table_name,
                where_clause=where_clause
            )
            
            # Importer vers le modèle
            result = ModelDiscovery.import_to_model(
                app_label,
                model_name,
                data,
                column_mapping,
                options
            )
            
            return Response({
                'success': True,
                **result
            }, status=status.HTTP_200_OK)
            
        except ImportError as e:
            return Response({
                'error': str(e),
                'available': False
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)
        except ValueError as e:
            return Response({
                'error': str(e)
            }, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({
                'error': f'Erreur lors de l\'import: {str(e)}'
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    @action(detail=False, methods=['post'])
    def serialiser_donnees(self, request):
        """
        Sérialise les données d'une table Access dans différents formats
        """
        file_path = request.data.get('file_path')
        table_name = request.data.get('table_name')
        where_clause = request.data.get('where_clause', None)
        format_type = request.data.get('format', 'json')  # json ou csv
        
        if not file_path or not table_name:
            return Response({
                'error': 'Le chemin du fichier et le nom de la table sont requis'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        if format_type not in ['json', 'csv']:
            return Response({
                'error': 'Format non supporté. Formats disponibles: json, csv'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        if not os.path.exists(file_path):
            return Response({
                'error': f'Le fichier n\'existe pas: {file_path}'
            }, status=status.HTTP_404_NOT_FOUND)
        
        try:
            # Récupérer toutes les données avec filtre
            data = AccessImporter.get_table_data_filtered(
                file_path,
                table_name,
                where_clause=where_clause
            )
            
            # Sérialiser
            serialized = AccessImporter.serialize_data(data, format_type)
            
            return Response({
                'success': True,
                'format': format_type,
                'data': serialized,
                'row_count': len(data)
            }, status=status.HTTP_200_OK)
            
        except ImportError as e:
            return Response({
                'error': str(e),
                'available': False
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)
        except Exception as e:
            return Response({
                'error': f'Erreur lors de la sérialisation: {str(e)}'
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

