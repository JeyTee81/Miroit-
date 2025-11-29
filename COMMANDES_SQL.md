# Commandes SQL pour la Base de Données

Ce fichier contient les commandes SQL nécessaires pour créer et configurer la base de données PostgreSQL.

## 1. Création de la Base de Données

```sql
-- Se connecter à PostgreSQL en tant que superutilisateur
-- Puis exécuter:

CREATE DATABASE miroiterie_db
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'French_France.1252'
    LC_CTYPE = 'French_France.1252'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

-- Ou plus simplement:
CREATE DATABASE miroiterie_db;
```

## 2. Création d'un Utilisateur (Optionnel)

```sql
CREATE USER miroiterie_user WITH PASSWORD 'votre_mot_de_passe';
GRANT ALL PRIVILEGES ON DATABASE miroiterie_db TO miroiterie_user;
```

## 3. Se Connecter à la Base de Données

```sql
\c miroiterie_db
```

## 4. Activer l'Extension UUID

```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

## 5. Génération Automatique avec Django

**Recommandé**: Utiliser Django pour générer les tables automatiquement:

```bash
cd backend
python manage.py makemigrations
python manage.py migrate
```

Cela créera toutes les tables selon les modèles Django définis.

## 6. Vérification des Tables Créées

```sql
-- Lister toutes les tables
\dt

-- Voir la structure d'une table
\d nom_de_la_table

-- Voir toutes les tables avec leur schéma
SELECT table_schema, table_name 
FROM information_schema.tables 
WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
ORDER BY table_schema, table_name;
```

## 7. Commandes Utiles PostgreSQL

```sql
-- Voir la taille de la base de données
SELECT pg_size_pretty(pg_database_size('miroiterie_db'));

-- Voir la taille de toutes les tables
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Voir les index d'une table
\di nom_de_la_table

-- Voir les contraintes d'une table
SELECT conname, contype, consrc
FROM pg_constraint
WHERE conrelid = 'nom_de_la_table'::regclass;
```

## 8. Sauvegarde et Restauration

### Sauvegarde

```bash
pg_dump -U postgres -d miroiterie_db -f backup.sql
```

### Restauration

```bash
psql -U postgres -d miroiterie_db -f backup.sql
```

## 9. Script de Création Manuelle (Alternative)

Si vous préférez créer les tables manuellement, référez-vous au fichier:
- `backend/schema.sql` - Exemple de script SQL
- `DATABASE_SCHEMA.md` - Documentation complète du schéma

**Note**: La méthode recommandée est d'utiliser les migrations Django (`python manage.py migrate`) car:
- Elle gère automatiquement les relations
- Elle crée les index appropriés
- Elle respecte l'ordre des dépendances
- Elle peut être versionnée et réversible

## 10. Configuration Django

Dans `backend/miroiterie/settings.py` ou `.env`:

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'miroiterie_db',
        'USER': 'postgres',
        'PASSWORD': 'votre_mot_de_passe',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}
```

## 11. Vérification de la Connexion

```bash
cd backend
python manage.py dbshell
```

Si la connexion fonctionne, vous serez dans le shell PostgreSQL.

## 12. Création des Données Initiales

```bash
# Créer un superutilisateur Django
python manage.py createsuperuser

# Charger des données de test (si fixtures créées)
python manage.py loaddata fixtures/initial_data.json
```

## 13. Index et Optimisations

Les index sont créés automatiquement par Django lors des migrations. Pour vérifier:

```sql
-- Voir tous les index
SELECT 
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
```

## 14. Maintenance

```sql
-- Analyser les tables pour optimiser les requêtes
ANALYZE;

-- Vider les tables (ATTENTION: supprime toutes les données)
TRUNCATE TABLE nom_table CASCADE;

-- Réinitialiser les séquences (après suppression de données)
SELECT setval('nom_sequence', 1, false);
```

## Notes Importantes

1. **Toujours faire des sauvegardes** avant des opérations importantes
2. **Utiliser les migrations Django** plutôt que des scripts SQL manuels
3. **Vérifier les contraintes** d'intégrité référentielle
4. **Tester les requêtes** dans un environnement de développement d'abord
5. **Documenter** toute modification manuelle de la base de données

## Dépannage

### Erreur: "relation does not exist"
- Vérifier que les migrations ont été appliquées: `python manage.py migrate`
- Vérifier que vous êtes connecté à la bonne base de données

### Erreur: "permission denied"
- Vérifier les permissions de l'utilisateur PostgreSQL
- Vérifier les paramètres dans `settings.py`

### Erreur: "extension does not exist"
- Exécuter: `CREATE EXTENSION IF NOT EXISTS "uuid-ossp";`






