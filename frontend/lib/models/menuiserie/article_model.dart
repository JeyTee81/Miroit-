import 'dart:core';

class Article {
  final String? id;
  final String projetId;
  final String designation;
  final String? designationBase;
  final String? designationGeneree;
  final String typeArticle;
  final double largeur;
  final double hauteur;
  final double? profondeur;
  final int quantite;
  final double prixUnitaireHt;
  final double? prixBaseHt;
  final double? prixCalcule;
  final String? dessinPath;
  final String? echelleDessin;
  final List<String>? optionsObligatoires; // Liste d'IDs
  final List<String>? optionsFacultatives; // Liste d'IDs
  final String? tarifFournisseurId;
  final String? tarifFournisseurNom;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Article({
    this.id,
    required this.projetId,
    required this.designation,
    this.designationBase,
    this.designationGeneree,
    required this.typeArticle,
    required this.largeur,
    required this.hauteur,
    this.profondeur,
    this.quantite = 1,
    required this.prixUnitaireHt,
    this.prixBaseHt,
    this.prixCalcule,
    this.dessinPath,
    this.echelleDessin,
    this.optionsObligatoires,
    this.optionsFacultatives,
    this.tarifFournisseurId,
    this.tarifFournisseurNom,
    this.createdAt,
    this.updatedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    // Gérer les options : peuvent être une liste ou un map (pour compatibilité)
    List<String>? parseOptions(dynamic value) {
      if (value == null) return null;
      if (value is List) {
        return value.map((e) => e is String ? e : e.toString()).toList();
      }
      if (value is Map) {
        // Ancien format (map) - extraire les IDs
        return value.keys.map((e) => e.toString()).toList();
      }
      return null;
    }

    return Article(
      id: json['id'],
      projetId: json['projet'] is String ? json['projet'] : (json['projet']?['id'] ?? ''),
      designation: json['designation'] ?? '',
      designationBase: json['designation_base'],
      designationGeneree: json['designation_generee'],
      typeArticle: json['type_article'] ?? 'fenetre',
      largeur: (json['largeur'] as num?)?.toDouble() ?? 0.0,
      hauteur: (json['hauteur'] as num?)?.toDouble() ?? 0.0,
      profondeur: json['profondeur'] != null 
          ? (json['profondeur'] as num).toDouble() 
          : null,
      quantite: json['quantite'] ?? 1,
      prixUnitaireHt: (json['prix_unitaire_ht'] as num?)?.toDouble() ?? 0.0,
      prixBaseHt: json['prix_base_ht'] != null 
          ? (json['prix_base_ht'] as num).toDouble() 
          : null,
      prixCalcule: json['prix_calcule'] != null 
          ? (json['prix_calcule'] as num).toDouble() 
          : null,
      dessinPath: json['dessin_path'],
      echelleDessin: json['echelle_dessin'],
      optionsObligatoires: parseOptions(json['options_obligatoires']),
      optionsFacultatives: parseOptions(json['options_facultatives']),
      tarifFournisseurId: json['tarif_fournisseur'] is String 
          ? json['tarif_fournisseur'] 
          : (json['tarif_fournisseur']?['id'] ?? null),
      tarifFournisseurNom: json['tarif_fournisseur_nom'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'projet': projetId,
      'designation': designation,
      if (designationBase != null) 'designation_base': designationBase,
      'type_article': typeArticle,
      'largeur': largeur,
      'hauteur': hauteur,
      if (profondeur != null) 'profondeur': profondeur,
      'quantite': quantite,
      'prix_unitaire_ht': prixUnitaireHt,
      if (prixBaseHt != null) 'prix_base_ht': prixBaseHt,
      if (dessinPath != null) 'dessin_path': dessinPath,
      if (echelleDessin != null) 'echelle_dessin': echelleDessin,
      if (optionsObligatoires != null && optionsObligatoires!.isNotEmpty) 
        'options_obligatoires': optionsObligatoires,
      if (optionsFacultatives != null && optionsFacultatives!.isNotEmpty) 
        'options_facultatives': optionsFacultatives,
      if (tarifFournisseurId != null) 'tarif_fournisseur': tarifFournisseurId,
    };
  }

  static List<String> get typeArticleOptions => [
    'fenetre',
    'porte',
    'baie',
    'autre',
  ];

  String get typeArticleLabel {
    switch (typeArticle) {
      case 'fenetre':
        return 'Fenêtre';
      case 'porte':
        return 'Porte';
      case 'baie':
        return 'Baie vitrée';
      case 'autre':
        return 'Autre';
      default:
        return typeArticle;
    }
  }

  double get surface => largeur * hauteur;
  
  double get montantTotalHt => prixUnitaireHt * quantite;
}

