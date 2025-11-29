# Schéma de Base de Données - Application Miroiterie/Menuiserie

Ce document décrit l'architecture de la base de données PostgreSQL pour l'application de gestion de miroiterie/menuiserie.

## Vue d'ensemble

La base de données est organisée en modules correspondant aux 10 modules fonctionnels de l'application. Chaque module a ses propres tables avec des relations inter-modules.

---

## 1. MODULE: Gestion Commerciale / Affaires

### Tables principales

#### `commerciale_devis`
- `id` (PK, UUID)
- `numero_devis` (VARCHAR, unique)
- `client_id` (FK → clients)
- `date_creation` (DATE)
- `date_validite` (DATE)
- `montant_ht` (DECIMAL)
- `montant_ttc` (DECIMAL)
- `statut` (VARCHAR: 'brouillon', 'envoye', 'accepte', 'refuse')
- `commercial_id` (FK → users)
- `chantier_id` (FK → commerciale_chantiers, nullable)
- `remise_pourcentage` (DECIMAL)
- `notes` (TEXT)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

#### `commerciale_lignes_devis`
- `id` (PK, UUID)
- `devis_id` (FK → commerciale_devis)
- `article_id` (FK → stock_articles, nullable)
- `designation` (VARCHAR)
- `quantite` (DECIMAL)
- `prix_unitaire_ht` (DECIMAL)
- `taux_tva` (DECIMAL)
- `remise_pourcentage` (DECIMAL)
- `ordre` (INTEGER)

#### `commerciale_factures`
- `id` (PK, UUID)
- `numero_facture` (VARCHAR, unique)
- `devis_id` (FK → commerciale_devis, nullable)
- `client_id` (FK → clients)
- `date_facture` (DATE)
- `date_echeance` (DATE)
- `montant_ht` (DECIMAL)
- `montant_ttc` (DECIMAL)
- `montant_paye` (DECIMAL, default 0)
- `statut` (VARCHAR: 'brouillon', 'emise', 'payee', 'partielle', 'impayee')
- `commercial_id` (FK → users)
- `chantier_id` (FK → commerciale_chantiers, nullable)
- `compte_comptable_id` (FK → comptabilite_comptes, nullable)
- `pdf_path` (VARCHAR)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

#### `commerciale_ventes_comptoir`
- `id` (PK, UUID)
- `numero_vente` (VARCHAR, unique)
- `client_id` (FK → clients, nullable)
- `date_vente` (DATE)
- `montant_ht` (DECIMAL)
- `montant_ttc` (DECIMAL)
- `mode_paiement` (VARCHAR: 'especes', 'carte', 'cheque', 'virement')
- `caisse_id` (FK → commerciale_caisses)
- `created_at` (TIMESTAMP)

#### `commerciale_chantiers`
- `id` (PK, UUID)
- `nom` (VARCHAR)
- `client_id` (FK → clients)
- `adresse_livraison` (TEXT)
- `date_debut` (DATE)
- `date_fin_prevue` (DATE)
- `date_fin_reelle` (DATE, nullable)
- `statut` (VARCHAR: 'planifie', 'en_cours', 'termine', 'annule')
- `chef_chantier_id` (FK → users, nullable)
- `commercial_id` (FK → users)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

#### `commerciale_paiements`
- `id` (PK, UUID)
- `facture_id` (FK → commerciale_factures)
- `montant` (DECIMAL)
- `date_paiement` (DATE)
- `mode_paiement` (VARCHAR)
- `numero_piece` (VARCHAR, nullable)
- `banque_id` (FK → comptabilite_banques, nullable)
- `created_at` (TIMESTAMP)

#### `commerciale_commandes_fournisseurs`
- `id` (PK, UUID)
- `numero_commande` (VARCHAR, unique)
- `fournisseur_id` (FK → stock_fournisseurs)
- `date_commande` (DATE)
- `date_livraison_prevue` (DATE)
- `montant_ht` (DECIMAL)
- `montant_ttc` (DECIMAL)
- `statut` (VARCHAR: 'brouillon', 'envoyee', 'recue', 'partielle', 'annulee')
- `created_by` (FK → users)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

#### `commerciale_relances`
- `id` (PK, UUID)
- `facture_id` (FK → commerciale_factures)
- `date_relance` (DATE)
- `type_relance` (VARCHAR: 'devis', 'facture')
- `statut` (VARCHAR: 'envoyee', 'payee', 'annulee')
- `created_at` (TIMESTAMP)

#### `commerciale_caisses`
- `id` (PK, UUID)
- `nom` (VARCHAR)
- `solde_initial` (DECIMAL)
- `solde_actuel` (DECIMAL)
- `actif` (BOOLEAN)

---

## 2. MODULE: Menuiserie

### Tables principales

#### `menuiserie_projets`
- `id` (PK, UUID)
- `numero_projet` (VARCHAR, unique)
- `devis_id` (FK → commerciale_devis)
- `chantier_id` (FK → commerciale_chantiers, nullable)
- `nom` (VARCHAR)
- `date_creation` (DATE)
- `statut` (VARCHAR: 'brouillon', 'en_cours', 'termine')
- `created_by` (FK → users)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

#### `menuiserie_articles`
- `id` (PK, UUID)
- `projet_id` (FK → menuiserie_projets)
- `designation` (VARCHAR)
- `type_article` (VARCHAR: 'fenetre', 'porte', 'baie', 'autre')
- `largeur` (DECIMAL)
- `hauteur` (DECIMAL)
- `profondeur` (DECIMAL, nullable)
- `quantite` (INTEGER)
- `prix_unitaire_ht` (DECIMAL)
- `dessin_path` (VARCHAR, nullable)
- `options_obligatoires` (JSONB)
- `options_facultatives` (JSONB)
- `tarif_fournisseur_id` (FK → menuiserie_tarifs_fournisseurs, nullable)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

#### `menuiserie_tarifs_fournisseurs`
- `id` (PK, UUID)
- `fournisseur_id` (FK → stock_fournisseurs)
- `reference_fournisseur` (VARCHAR)
- `designation` (VARCHAR)
- `prix_unitaire_ht` (DECIMAL)
- `unite` (VARCHAR: 'unite', 'm2', 'ml', 'kg')
- `date_validite_debut` (DATE)
- `date_validite_fin` (DATE, nullable)
- `actif` (BOOLEAN)
- `created_at` (TIMESTAMP)

#### `menuiserie_dessins`
- `id` (PK, UUID)
- `article_id` (FK → menuiserie_articles)
- `fichier_path` (VARCHAR)
- `echelle` (VARCHAR)
- `format` (VARCHAR: 'pdf', 'dwg', 'dxf')
- `created_at` (TIMESTAMP)

---

## 3. MODULE: Stock

### Tables principales

#### `stock_categories`
- `id` (PK, UUID)
- `nom` (VARCHAR, unique)
- `parent_id` (FK → stock_categories, nullable)
- `description` (TEXT, nullable)

#### `stock_articles`
- `id` (PK, UUID)
- `reference` (VARCHAR, unique)
- `designation` (VARCHAR)
- `categorie_id` (FK → stock_categories)
- `unite_mesure` (VARCHAR: 'unite', 'm2', 'ml', 'kg', 'm3')
- `prix_achat_ht` (DECIMAL)
- `prix_vente_ht` (DECIMAL)
- `taux_tva` (DECIMAL)
- `stock_minimum` (DECIMAL)
- `stock_actuel` (DECIMAL, default 0)
- `actif` (BOOLEAN, default true)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

#### `stock_mouvements`
- `id` (PK, UUID)
- `article_id` (FK → stock_articles)
- `type_mouvement` (VARCHAR: 'entree', 'sortie', 'inventaire', 'ajustement')
- `quantite` (DECIMAL)
- `prix_unitaire_ht` (DECIMAL, nullable)
- `date_mouvement` (DATE)
- `reference_document` (VARCHAR, nullable)
- `chantier_id` (FK → commerciale_chantiers, nullable)
- `commande_fournisseur_id` (FK → commerciale_commandes_fournisseurs, nullable)
- `created_by` (FK → users)
- `notes` (TEXT, nullable)
- `created_at` (TIMESTAMP)

#### `stock_fournisseurs`
- `id` (PK, UUID)
- `raison_sociale` (VARCHAR)
- `siret` (VARCHAR, unique, nullable)
- `adresse` (TEXT)
- `code_postal` (VARCHAR)
- `ville` (VARCHAR)
- `pays` (VARCHAR, default 'France')
- `telephone` (VARCHAR, nullable)
- `email` (VARCHAR, nullable)
- `contact` (VARCHAR, nullable)
- `actif` (BOOLEAN, default true)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

#### `stock_commandes_fournisseurs_lignes`
- `id` (PK, UUID)
- `commande_fournisseur_id` (FK → commerciale_commandes_fournisseurs)
- `article_id` (FK → stock_articles)
- `quantite_commandee` (DECIMAL)
- `quantite_recue` (DECIMAL, default 0)
- `prix_unitaire_ht` (DECIMAL)
- `date_livraison_prevue` (DATE, nullable)

---

## 4. MODULE: Gestion Travaux et Heures

### Tables principales

#### `travaux_chantiers`
- `id` (PK, UUID)
- `chantier_id` (FK → commerciale_chantiers)
- `date_debut` (DATE)
- `date_fin` (DATE, nullable)
- `statut` (VARCHAR: 'planifie', 'en_cours', 'suspendu', 'termine')
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

#### `travaux_heures`
- `id` (PK, UUID)
- `chantier_id` (FK → commerciale_chantiers)
- `salarie_id` (FK → users)
- `date_travail` (DATE)
- `heures_normales` (DECIMAL)
- `heures_supplementaires` (DECIMAL, default 0)
- `taux_horaire` (DECIMAL)
- `activite` (VARCHAR: 'fabrication', 'pose', 'livraison', 'autre')
- `notes` (TEXT, nullable)
- `valide_par` (FK → users, nullable)
- `valide_le` (DATE, nullable)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

#### `travaux_bilans_chantiers`
- `id` (PK, UUID)
- `chantier_id` (FK → commerciale_chantiers)
- `periode_debut` (DATE)
- `periode_fin` (DATE)
- `heures_totales` (DECIMAL)
- `cout_total` (DECIMAL)
- `avancement_pourcentage` (DECIMAL)
- `created_at` (TIMESTAMP)

---

## 5. MODULE: Planning

### Tables principales

#### `planning_rendez_vous`
- `id` (PK, UUID)
- `titre` (VARCHAR)
- `description` (TEXT, nullable)
- `date_debut` (TIMESTAMP)
- `date_fin` (TIMESTAMP)
- `type` (VARCHAR: 'commercial', 'travaux', 'livraison')
- `utilisateur_id` (FK → users)
- `client_id` (FK → clients, nullable)
- `chantier_id` (FK → commerciale_chantiers, nullable)
- `lieu` (VARCHAR, nullable)
- `statut` (VARCHAR: 'planifie', 'confirme', 'annule', 'termine')
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

---

## 6. MODULE: Tournées (Livraison)

### Tables principales

#### `tournees_vehicules`
- `id` (PK, UUID)
- `immatriculation` (VARCHAR, unique)
- `marque` (VARCHAR)
- `modele` (VARCHAR)
- `type` (VARCHAR: 'utilitaire', 'camion', 'fourgon')
- `capacite_charge` (DECIMAL, nullable)
- `actif` (BOOLEAN, default true)
- `created_at` (TIMESTAMP)

#### `tournees_chauffeurs`
- `id` (PK, UUID)
- `user_id` (FK → users, unique)
- `numero_permis` (VARCHAR)
- `date_expiration_permis` (DATE)
- `actif` (BOOLEAN, default true)

#### `tournees_tournees`
- `id` (PK, UUID)
- `numero_tournee` (VARCHAR, unique)
- `date_tournee` (DATE)
- `vehicule_id` (FK → tournees_vehicules)
- `chauffeur_id` (FK → tournees_chauffeurs)
- `statut` (VARCHAR: 'planifiee', 'en_cours', 'terminee', 'annulee')
- `itineraire_optimise` (JSONB)
- `distance_totale` (DECIMAL, nullable)
- `duree_estimee` (INTEGER, nullable)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

#### `tournees_livraisons`
- `id` (PK, UUID)
- `tournee_id` (FK → tournees_tournees)
- `facture_id` (FK → commerciale_factures, nullable)
- `chantier_id` (FK → commerciale_chantiers)
- `ordre_livraison` (INTEGER)
- `adresse_livraison` (TEXT)
- `latitude` (DECIMAL, nullable)
- `longitude` (DECIMAL, nullable)
- `statut` (VARCHAR: 'planifiee', 'en_transit', 'livree', 'echec')
- `date_livraison_prevue` (TIMESTAMP)
- `date_livraison_reelle` (TIMESTAMP, nullable)
- `signature_path` (VARCHAR, nullable)
- `notes` (TEXT, nullable)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

#### `tournees_chariots`
- `id` (PK, UUID)
- `numero` (VARCHAR, unique)
- `type` (VARCHAR)
- `capacite` (DECIMAL, nullable)
- `actif` (BOOLEAN, default true)
- `created_at` (TIMESTAMP)

#### `tournees_livraisons_chariots`
- `id` (PK, UUID)
- `livraison_id` (FK → tournees_livraisons)
- `chariot_id` (FK → tournees_chariots)
- `quantite` (INTEGER)

---

## 7. MODULE: Suivi Client (CRM)

### Tables principales

#### `clients`
- `id` (PK, UUID)
- `type` (VARCHAR: 'particulier', 'professionnel', 'entreprise')
- `raison_sociale` (VARCHAR, nullable)
- `nom` (VARCHAR)
- `prenom` (VARCHAR, nullable)
- `siret` (VARCHAR, nullable)
- `adresse` (TEXT)
- `code_postal` (VARCHAR)
- `ville` (VARCHAR)
- `pays` (VARCHAR, default 'France')
- `telephone` (VARCHAR, nullable)
- `email` (VARCHAR, nullable)
- `commercial_id` (FK → users, nullable)
- `zone_geographique` (VARCHAR, nullable)
- `famille_client` (VARCHAR, nullable)
- `date_creation` (DATE)
- `actif` (BOOLEAN, default true)
- `notes` (TEXT, nullable)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

#### `crm_visites`
- `id` (PK, UUID)
- `client_id` (FK → clients)
- `commercial_id` (FK → users)
- `date_visite` (DATE)
- `type_visite` (VARCHAR: 'prise_contact', 'devis', 'suivi', 'relance')
- `notes` (TEXT)
- `resultat` (VARCHAR, nullable)
- `created_at` (TIMESTAMP)

#### `crm_statistiques`
- `id` (PK, UUID)
- `client_id` (FK → clients, nullable)
- `commercial_id` (FK → users, nullable)
- `periode_debut` (DATE)
- `periode_fin` (DATE)
- `ca_ht` (DECIMAL)
- `ca_ttc` (DECIMAL)
- `nombre_devis` (INTEGER)
- `nombre_factures` (INTEGER)
- `famille_client` (VARCHAR, nullable)
- `zone_geographique` (VARCHAR, nullable)
- `created_at` (TIMESTAMP)

---

## 8. MODULE: Gestion Vitrages

### Tables principales

#### `vitrages_projets`
- `id` (PK, UUID)
- `numero_projet` (VARCHAR, unique)
- `chantier_id` (FK → commerciale_chantiers, nullable)
- `nom` (VARCHAR)
- `date_creation` (DATE)
- `created_by` (FK → users)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

#### `vitrages_calculs`
- `id` (PK, UUID)
- `projet_id` (FK → vitrages_projets)
- `largeur` (DECIMAL)
- `hauteur` (DECIMAL)
- `epaisseur_vitrage` (DECIMAL)
- `type_vitrage` (VARCHAR: 'monolithique', 'feuilleté', 'isolation', 'autre')
- `region_vent` (VARCHAR)
- `region_neige` (VARCHAR)
- `categorie_terrain` (VARCHAR)
- `altitude` (DECIMAL, nullable)
- `resultat_calcul` (JSONB)
- `norme_utilisee` (VARCHAR: 'NF DTU 39')
- `cahier_cstb` (VARCHAR, nullable)
- `pdf_path` (VARCHAR, nullable)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

#### `vitrages_configurations`
- `id` (PK, UUID)
- `nom` (VARCHAR)
- `type_vitrage` (VARCHAR)
- `epaisseur` (DECIMAL)
- `coefficients` (JSONB)
- `actif` (BOOLEAN, default true)

---

## 9. MODULE: Optimisation de Débits

### Tables principales

#### `optimisation_plans_coupe`
- `id` (PK, UUID)
- `numero_plan` (VARCHAR, unique)
- `chantier_id` (FK → commerciale_chantiers, nullable)
- `type_matiere` (VARCHAR: 'plaque', 'barre')
- `matiere_id` (FK → stock_articles)
- `dimensions_plaque` (JSONB)
- `dimensions_commandes` (JSONB)
- `resultat_optimisation` (JSONB)
- `taux_utilisation` (DECIMAL)
- `chutes_reutilisables` (JSONB)
- `statut` (VARCHAR: 'brouillon', 'valide', 'envoye_cnc')
- `fichier_cnc_path` (VARCHAR, nullable)
- `pdf_path` (VARCHAR, nullable)
- `created_by` (FK → users)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

#### `optimisation_chutes`
- `id` (PK, UUID)
- `matiere_id` (FK → stock_articles)
- `dimensions` (JSONB)
- `quantite` (INTEGER)
- `statut` (VARCHAR: 'disponible', 'reservee', 'utilisee')
- `plan_coupe_id` (FK → optimisation_plans_coupe, nullable)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

---

## 10. MODULE: Calcul d'Inertie

### Tables principales

#### `inertie_projets`
- `id` (PK, UUID)
- `numero_projet` (VARCHAR, unique)
- `chantier_id` (FK → commerciale_chantiers, nullable)
- `nom` (VARCHAR)
- `date_creation` (DATE)
- `created_by` (FK → users)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

#### `inertie_profils`
- `id` (PK, UUID)
- `reference` (VARCHAR, unique)
- `nom` (VARCHAR)
- `type` (VARCHAR: 'montant', 'traverse', 'raidisseur')
- `materiau` (VARCHAR: 'alu', 'pvc', 'bois', 'acier')
- `dimensions` (JSONB)
- `caracteristiques` (JSONB)
- `actif` (BOOLEAN, default true)
- `created_at` (TIMESTAMP)

#### `inertie_calculs`
- `id` (PK, UUID)
- `projet_id` (FK → inertie_projets)
- `profil_id` (FK → inertie_profils)
- `longueur` (DECIMAL)
- `charges` (JSONB)
- `contraintes` (JSONB)
- `validation` (JSONB)
- `norme_utilisee` (VARCHAR: 'NF EN 1991')
- `resultat_ei` (DECIMAL)
- `contrainte_max` (DECIMAL)
- `contrainte_admissible` (DECIMAL)
- `valide` (BOOLEAN)
- `pdf_path` (VARCHAR, nullable)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

---

## Tables Système

### Authentification et Utilisateurs

#### `users`
- `id` (PK, UUID)
- `username` (VARCHAR, unique)
- `email` (VARCHAR, unique)
- `password_hash` (VARCHAR)
- `nom` (VARCHAR)
- `prenom` (VARCHAR)
- `role` (VARCHAR: 'admin', 'commercial', 'atelier', 'logistique', 'comptable')
- `actif` (BOOLEAN, default true)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)
- `last_login` (TIMESTAMP, nullable)

### Comptabilité

#### `comptabilite_comptes`
- `id` (PK, UUID)
- `numero_compte` (VARCHAR, unique)
- `libelle` (VARCHAR)
- `type_compte` (VARCHAR: 'classe1', 'classe2', 'classe3', 'classe4', 'classe5', 'classe6', 'classe7')
- `actif` (BOOLEAN, default true)

#### `comptabilite_ecritures`
- `id` (PK, UUID)
- `date_ecriture` (DATE)
- `compte_debit_id` (FK → comptabilite_comptes)
- `compte_credit_id` (FK → comptabilite_comptes)
- `montant` (DECIMAL)
- `libelle` (VARCHAR)
- `reference_document` (VARCHAR, nullable)
- `facture_id` (FK → commerciale_factures, nullable)
- `created_at` (TIMESTAMP)

#### `comptabilite_banques`
- `id` (PK, UUID)
- `nom` (VARCHAR)
- `numero_compte` (VARCHAR)
- `iban` (VARCHAR, nullable)
- `bic` (VARCHAR, nullable)
- `actif` (BOOLEAN, default true)

---

## Relations Inter-Modules

### Relations principales:
1. **Commerciale ↔ Stock**: Commandes fournisseurs, lignes de devis/factures
2. **Commerciale ↔ Chantiers**: Tous les documents liés aux chantiers
3. **Commerciale ↔ CRM**: Clients, statistiques
4. **Travaux ↔ Chantiers**: Heures, bilans
5. **Planning ↔ Commerciale/Travaux**: Rendez-vous
6. **Tournées ↔ Chantiers**: Livraisons
7. **Menuiserie ↔ Commerciale**: Projets liés aux devis
8. **Vitrages ↔ Chantiers**: Calculs liés aux chantiers
9. **Optimisation ↔ Stock**: Matières et chutes
10. **Inertie ↔ Chantiers**: Calculs liés aux chantiers

---

## Index recommandés

- Index sur toutes les clés étrangères
- Index sur `numero_devis`, `numero_facture`, `numero_commande`
- Index sur `date_creation`, `date_facture`, `date_travail`
- Index sur `statut` pour toutes les tables avec statut
- Index composite sur `client_id` + `date_creation` pour les statistiques

---

## Notes d'implémentation

- Utilisation de UUID pour toutes les clés primaires
- Timestamps automatiques (created_at, updated_at)
- Soft delete possible avec champ `deleted_at` (TIMESTAMP, nullable)
- JSONB pour les données flexibles (options, résultats calculs)
- Contraintes d'intégrité référentielle strictes






