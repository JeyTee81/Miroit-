-- Script SQL pour la base de données PostgreSQL
-- Application de gestion Miroiterie/Menuiserie
-- Généré à partir des modèles Django

-- Extension UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLE: users (Authentification)
-- ============================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(150) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(128) NOT NULL,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'commercial',
    actif BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    is_superuser BOOLEAN DEFAULT FALSE,
    is_staff BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    date_joined TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_actif ON users(actif);

-- ============================================
-- TABLE: clients (Commerciale)
-- ============================================
CREATE TABLE clients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type VARCHAR(20) NOT NULL,
    raison_sociale VARCHAR(200),
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100),
    siret VARCHAR(14) UNIQUE,
    adresse TEXT NOT NULL,
    code_postal VARCHAR(10) NOT NULL,
    ville VARCHAR(100) NOT NULL,
    pays VARCHAR(100) DEFAULT 'France',
    telephone VARCHAR(20),
    email VARCHAR(255),
    commercial_id UUID REFERENCES users(id) ON DELETE SET NULL,
    zone_geographique VARCHAR(100),
    famille_client VARCHAR(100),
    date_creation DATE DEFAULT CURRENT_DATE,
    actif BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_clients_commercial ON clients(commercial_id);
CREATE INDEX idx_clients_actif ON clients(actif);
CREATE INDEX idx_clients_zone ON clients(zone_geographique);

-- ============================================
-- TABLE: commerciale_chantiers
-- ============================================
CREATE TABLE commerciale_chantiers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nom VARCHAR(200) NOT NULL,
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    adresse_livraison TEXT NOT NULL,
    date_debut DATE NOT NULL,
    date_fin_prevue DATE NOT NULL,
    date_fin_reelle DATE,
    statut VARCHAR(20) DEFAULT 'planifie',
    chef_chantier_id UUID REFERENCES users(id) ON DELETE SET NULL,
    commercial_id UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_chantiers_client ON commerciale_chantiers(client_id);
CREATE INDEX idx_chantiers_statut ON commerciale_chantiers(statut);

-- ============================================
-- TABLE: commerciale_devis
-- ============================================
CREATE TABLE commerciale_devis (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    numero_devis VARCHAR(50) UNIQUE NOT NULL,
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    date_creation DATE DEFAULT CURRENT_DATE,
    date_validite DATE NOT NULL,
    montant_ht DECIMAL(10,2) DEFAULT 0,
    montant_ttc DECIMAL(10,2) DEFAULT 0,
    statut VARCHAR(20) DEFAULT 'brouillon',
    commercial_id UUID REFERENCES users(id) ON DELETE SET NULL,
    chantier_id UUID REFERENCES commerciale_chantiers(id) ON DELETE SET NULL,
    remise_pourcentage DECIMAL(5,2) DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_devis_client ON commerciale_devis(client_id);
CREATE INDEX idx_devis_numero ON commerciale_devis(numero_devis);
CREATE INDEX idx_devis_statut ON commerciale_devis(statut);

-- ============================================
-- TABLE: commerciale_lignes_devis
-- ============================================
CREATE TABLE commerciale_lignes_devis (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    devis_id UUID NOT NULL REFERENCES commerciale_devis(id) ON DELETE CASCADE,
    article_id UUID REFERENCES stock_articles(id) ON DELETE SET NULL,
    designation VARCHAR(200) NOT NULL,
    quantite DECIMAL(10,2) NOT NULL CHECK (quantite >= 0),
    prix_unitaire_ht DECIMAL(10,2) NOT NULL,
    taux_tva DECIMAL(5,2) DEFAULT 20,
    remise_pourcentage DECIMAL(5,2) DEFAULT 0,
    ordre INTEGER DEFAULT 0
);

CREATE INDEX idx_lignes_devis ON commerciale_lignes_devis(devis_id);

-- ============================================
-- TABLE: commerciale_factures
-- ============================================
CREATE TABLE commerciale_factures (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    numero_facture VARCHAR(50) UNIQUE NOT NULL,
    devis_id UUID REFERENCES commerciale_devis(id) ON DELETE SET NULL,
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    date_facture DATE NOT NULL,
    date_echeance DATE NOT NULL,
    montant_ht DECIMAL(10,2) NOT NULL,
    montant_ttc DECIMAL(10,2) NOT NULL,
    montant_paye DECIMAL(10,2) DEFAULT 0,
    statut VARCHAR(20) DEFAULT 'brouillon',
    commercial_id UUID REFERENCES users(id) ON DELETE SET NULL,
    chantier_id UUID REFERENCES commerciale_chantiers(id) ON DELETE SET NULL,
    compte_comptable_id UUID REFERENCES comptabilite_comptes(id) ON DELETE SET NULL,
    pdf_path VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_factures_client ON commerciale_factures(client_id);
CREATE INDEX idx_factures_numero ON commerciale_factures(numero_facture);
CREATE INDEX idx_factures_statut ON commerciale_factures(statut);

-- ============================================
-- TABLE: stock_categories
-- ============================================
CREATE TABLE stock_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nom VARCHAR(100) UNIQUE NOT NULL,
    parent_id UUID REFERENCES stock_categories(id) ON DELETE SET NULL,
    description TEXT
);

-- ============================================
-- TABLE: stock_articles
-- ============================================
CREATE TABLE stock_articles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference VARCHAR(100) UNIQUE NOT NULL,
    designation VARCHAR(200) NOT NULL,
    categorie_id UUID NOT NULL REFERENCES stock_categories(id) ON DELETE PROTECT,
    unite_mesure VARCHAR(10) DEFAULT 'unite',
    prix_achat_ht DECIMAL(10,2) NOT NULL,
    prix_vente_ht DECIMAL(10,2) NOT NULL,
    taux_tva DECIMAL(5,2) DEFAULT 20,
    stock_minimum DECIMAL(10,2) DEFAULT 0,
    stock_actuel DECIMAL(10,2) DEFAULT 0,
    actif BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_articles_categorie ON stock_articles(categorie_id);
CREATE INDEX idx_articles_reference ON stock_articles(reference);
CREATE INDEX idx_articles_actif ON stock_articles(actif);

-- ============================================
-- TABLE: stock_fournisseurs
-- ============================================
CREATE TABLE stock_fournisseurs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    raison_sociale VARCHAR(200) NOT NULL,
    siret VARCHAR(14) UNIQUE,
    adresse TEXT NOT NULL,
    code_postal VARCHAR(10) NOT NULL,
    ville VARCHAR(100) NOT NULL,
    pays VARCHAR(100) DEFAULT 'France',
    telephone VARCHAR(20),
    email VARCHAR(255),
    contact VARCHAR(100),
    actif BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLE: stock_mouvements
-- ============================================
CREATE TABLE stock_mouvements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    article_id UUID NOT NULL REFERENCES stock_articles(id) ON DELETE PROTECT,
    type_mouvement VARCHAR(20) NOT NULL,
    quantite DECIMAL(10,2) NOT NULL CHECK (quantite >= 0),
    prix_unitaire_ht DECIMAL(10,2),
    date_mouvement DATE NOT NULL,
    reference_document VARCHAR(100),
    chantier_id UUID REFERENCES commerciale_chantiers(id) ON DELETE SET NULL,
    commande_fournisseur_id UUID REFERENCES commerciale_commandes_fournisseurs(id) ON DELETE SET NULL,
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_mouvements_article ON stock_mouvements(article_id);
CREATE INDEX idx_mouvements_date ON stock_mouvements(date_mouvement);

-- Note: Les autres tables suivent le même modèle.
-- Ce script est un exemple de base. Pour générer le script complet,
-- utilisez: python manage.py sqlmigrate --all > schema_complet.sql






