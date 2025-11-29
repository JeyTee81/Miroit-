"""
Module pour l'import de données depuis une base de données Microsoft Access
"""
import os
import logging
from typing import Dict, List, Optional, Any
from django.conf import settings

logger = logging.getLogger(__name__)

# Import optionnel de pyodbc
try:
    import pyodbc
    PYODBC_AVAILABLE = True
except ImportError:
    PYODBC_AVAILABLE = False
    pyodbc = None


class AccessImporter:
    """Classe pour gérer l'import depuis Access"""
    
    @staticmethod
    def check_pyodbc_available():
        """Vérifie si pyodbc est disponible"""
        if not PYODBC_AVAILABLE:
            raise ImportError(
                "pyodbc n'est pas installé ou n'est pas compatible avec cette version de Python. "
                "Veuillez installer pyodbc avec une version compatible de Python (3.8-3.13 recommandé) "
                "ou utiliser une version précompilée de pyodbc."
            )
    
    @staticmethod
    def get_connection_string(file_path: str) -> str:
        """
        Génère la chaîne de connexion ODBC pour un fichier Access
        Supporte .mdb et .accdb
        """
        AccessImporter.check_pyodbc_available()
        
        if not os.path.exists(file_path):
            raise FileNotFoundError(f"Le fichier Access n'existe pas: {file_path}")
        
        # Normaliser le chemin pour Windows
        abs_path = os.path.abspath(file_path)
        abs_path = abs_path.replace('/', '\\')
        
        # Déterminer le driver selon l'extension
        if file_path.lower().endswith('.accdb'):
            # Access 2007 et supérieur
            driver = '{Microsoft Access Driver (*.mdb, *.accdb)}'
        elif file_path.lower().endswith('.mdb'):
            # Access 97-2003
            driver = '{Microsoft Access Driver (*.mdb)}'
        else:
            raise ValueError("Format de fichier non supporté. Utilisez .mdb ou .accdb")
        
        # Chaîne de connexion
        conn_str = (
            f'DRIVER={driver};'
            f'DBQ={abs_path};'
            'ExtendedAnsiSQL=1;'
        )
        
        return conn_str
    
    @staticmethod
    def test_connection(file_path: str) -> Dict[str, Any]:
        """
        Teste la connexion à la base Access
        Retourne un dictionnaire avec le statut et les informations
        """
        try:
            conn_str = AccessImporter.get_connection_string(file_path)
            conn = pyodbc.connect(conn_str)
            conn.close()
            return {
                'success': True,
                'message': 'Connexion réussie',
                'file_path': file_path
            }
        except pyodbc.Error as e:
            logger.error(f"Erreur de connexion Access: {e}")
            return {
                'success': False,
                'message': f'Erreur de connexion: {str(e)}',
                'error': str(e)
            }
        except Exception as e:
            logger.error(f"Erreur inattendue: {e}")
            return {
                'success': False,
                'message': f'Erreur: {str(e)}',
                'error': str(e)
            }
    
    @staticmethod
    def list_tables(file_path: str) -> List[Dict[str, str]]:
        """
        Liste toutes les tables de la base Access
        Retourne une liste de dictionnaires avec le nom de la table
        """
        tables = []
        try:
            conn_str = AccessImporter.get_connection_string(file_path)
            conn = pyodbc.connect(conn_str)
            cursor = conn.cursor()
            
            # Récupérer les noms des tables
            # MSysObjects contient les métadonnées des objets Access
            cursor.execute("""
                SELECT Name 
                FROM MSysObjects 
                WHERE Type=1 AND Flags=0 
                AND Name NOT LIKE 'MSys%'
                ORDER BY Name
            """)
            
            for row in cursor.fetchall():
                tables.append({
                    'name': row[0],
                    'type': 'table'
                })
            
            cursor.close()
            conn.close()
            
        except pyodbc.Error as e:
            logger.error(f"Erreur lors de la liste des tables: {e}")
            raise Exception(f"Erreur lors de la lecture des tables: {str(e)}")
        
        return tables
    
    @staticmethod
    def get_table_columns(file_path: str, table_name: str) -> List[Dict[str, Any]]:
        """
        Récupère les colonnes d'une table avec leurs types
        """
        columns = []
        try:
            conn_str = AccessImporter.get_connection_string(file_path)
            conn = pyodbc.connect(conn_str)
            cursor = conn.cursor()
            
            # Récupérer les colonnes de la table
            cursor.execute(f"SELECT TOP 1 * FROM [{table_name}]")
            
            # Récupérer les informations sur les colonnes
            for column in cursor.description:
                columns.append({
                    'name': column[0],
                    'type': str(column[1]),
                    'nullable': column[6] if len(column) > 6 else True
                })
            
            cursor.close()
            conn.close()
            
        except pyodbc.Error as e:
            logger.error(f"Erreur lors de la lecture des colonnes: {e}")
            raise Exception(f"Erreur lors de la lecture des colonnes: {str(e)}")
        
        return columns
    
    @staticmethod
    def get_table_data(file_path: str, table_name: str, limit: Optional[int] = None) -> List[Dict[str, Any]]:
        """
        Récupère les données d'une table
        """
        data = []
        try:
            conn_str = AccessImporter.get_connection_string(file_path)
            conn = pyodbc.connect(conn_str)
            cursor = conn.cursor()
            
            # Construire la requête avec limite optionnelle
            query = f"SELECT * FROM [{table_name}]"
            if limit:
                query = f"SELECT TOP {limit} * FROM [{table_name}]"
            
            cursor.execute(query)
            
            # Récupérer les noms des colonnes
            columns = [column[0] for column in cursor.description]
            
            # Récupérer les données
            for row in cursor.fetchall():
                row_dict = {}
                for i, value in enumerate(row):
                    # Convertir les valeurs None en None
                    if value is None:
                        row_dict[columns[i]] = None
                    else:
                        # Convertir les bytes en string si nécessaire
                        if isinstance(value, bytes):
                            try:
                                row_dict[columns[i]] = value.decode('utf-8')
                            except:
                                row_dict[columns[i]] = str(value)
                        else:
                            row_dict[columns[i]] = value
                data.append(row_dict)
            
            cursor.close()
            conn.close()
            
        except pyodbc.Error as e:
            logger.error(f"Erreur lors de la lecture des données: {e}")
            raise Exception(f"Erreur lors de la lecture des données: {str(e)}")
        
        return data
    
    @staticmethod
    def get_row_count(file_path: str, table_name: str, where_clause: Optional[str] = None) -> int:
        """
        Compte le nombre de lignes dans une table avec filtre optionnel
        """
        try:
            conn_str = AccessImporter.get_connection_string(file_path)
            conn = pyodbc.connect(conn_str)
            cursor = conn.cursor()
            
            query = f"SELECT COUNT(*) FROM [{table_name}]"
            if where_clause:
                query += f" WHERE {where_clause}"
            
            cursor.execute(query)
            count = cursor.fetchone()[0]
            
            cursor.close()
            conn.close()
            
            return count
            
        except pyodbc.Error as e:
            logger.error(f"Erreur lors du comptage: {e}")
            raise Exception(f"Erreur lors du comptage: {str(e)}")
    
    @staticmethod
    def get_table_data_filtered(
        file_path: str, 
        table_name: str, 
        where_clause: Optional[str] = None,
        limit: Optional[int] = None,
        offset: Optional[int] = None
    ) -> List[Dict[str, Any]]:
        """
        Récupère les données d'une table avec filtres optionnels
        """
        data = []
        try:
            conn_str = AccessImporter.get_connection_string(file_path)
            conn = pyodbc.connect(conn_str)
            cursor = conn.cursor()
            
            # Construire la requête
            query = f"SELECT * FROM [{table_name}]"
            
            if where_clause:
                query += f" WHERE {where_clause}"
            
            # Access ne supporte pas OFFSET directement, on utilise une sous-requête
            if limit or offset:
                if offset:
                    # Pour Access, on doit utiliser une approche différente
                    # On récupère tout et on filtre en Python (pas optimal mais fonctionne)
                    pass
                if limit:
                    query = f"SELECT TOP {limit} * FROM ({query}) AS subquery" if where_clause else f"SELECT TOP {limit} * FROM [{table_name}]"
                    if where_clause and limit:
                        query = f"SELECT TOP {limit} * FROM [{table_name}] WHERE {where_clause}"
            
            cursor.execute(query)
            
            # Récupérer les noms des colonnes
            columns = [column[0] for column in cursor.description]
            
            # Appliquer offset en Python si nécessaire
            rows = cursor.fetchall()
            if offset:
                rows = rows[offset:]
            if limit and not offset:
                rows = rows[:limit]
            
            # Récupérer les données
            for row in rows:
                row_dict = {}
                for i, value in enumerate(row):
                    if value is None:
                        row_dict[columns[i]] = None
                    else:
                        if isinstance(value, bytes):
                            try:
                                row_dict[columns[i]] = value.decode('utf-8')
                            except:
                                row_dict[columns[i]] = str(value)
                        else:
                            row_dict[columns[i]] = value
                data.append(row_dict)
            
            cursor.close()
            conn.close()
            
        except pyodbc.Error as e:
            logger.error(f"Erreur lors de la lecture des données: {e}")
            raise Exception(f"Erreur lors de la lecture des données: {str(e)}")
        
        return data
    
    @staticmethod
    def serialize_data(data: List[Dict[str, Any]], format: str = 'json') -> str:
        """
        Sérialise les données dans différents formats
        Formats supportés: json, csv
        """
        import json
        import csv
        import io
        
        if format.lower() == 'json':
            return json.dumps(data, indent=2, ensure_ascii=False, default=str)
        
        elif format.lower() == 'csv':
            if not data:
                return ''
            
            output = io.StringIO()
            fieldnames = data[0].keys()
            writer = csv.DictWriter(output, fieldnames=fieldnames)
            writer.writeheader()
            
            for row in data:
                # Convertir les valeurs en string pour CSV
                csv_row = {}
                for key, value in row.items():
                    if value is None:
                        csv_row[key] = ''
                    elif isinstance(value, (dict, list)):
                        csv_row[key] = json.dumps(value, ensure_ascii=False)
                    else:
                        csv_row[key] = str(value)
                writer.writerow(csv_row)
            
            return output.getvalue()
        
        else:
            raise ValueError(f"Format non supporté: {format}. Formats disponibles: json, csv")

