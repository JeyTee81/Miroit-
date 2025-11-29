class OptionMenuiserie {
  final String? id;
  final String code;
  final String libelle;
  final String typeOption; // 'obligatoire' ou 'facultatif'
  final String typeArticle; // 'fenetre', 'porte', 'baie', 'autre', 'tous'
  final String? ajoutDesignation;
  final String impactPrixType; // 'fixe', 'pourcentage', 'aucun'
  final double impactPrixValeur;
  final Map<String, dynamic>? impactDessin;
  final bool actif;
  final int ordreAffichage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OptionMenuiserie({
    this.id,
    required this.code,
    required this.libelle,
    required this.typeOption,
    required this.typeArticle,
    this.ajoutDesignation,
    required this.impactPrixType,
    this.impactPrixValeur = 0,
    this.impactDessin,
    this.actif = true,
    this.ordreAffichage = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory OptionMenuiserie.fromJson(Map<String, dynamic> json) {
    return OptionMenuiserie(
      id: json['id'],
      code: json['code'] ?? '',
      libelle: json['libelle'] ?? '',
      typeOption: json['type_option'] ?? 'facultatif',
      typeArticle: json['type_article'] ?? 'tous',
      ajoutDesignation: json['ajout_designation'],
      impactPrixType: json['impact_prix_type'] ?? 'aucun',
      impactPrixValeur: (json['impact_prix_valeur'] as num?)?.toDouble() ?? 0.0,
      impactDessin: json['impact_dessin'] is Map
          ? Map<String, dynamic>.from(json['impact_dessin'])
          : null,
      actif: json['actif'] ?? true,
      ordreAffichage: json['ordre_affichage'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'code': code,
      'libelle': libelle,
      'type_option': typeOption,
      'type_article': typeArticle,
      if (ajoutDesignation != null) 'ajout_designation': ajoutDesignation,
      'impact_prix_type': impactPrixType,
      'impact_prix_valeur': impactPrixValeur,
      if (impactDessin != null) 'impact_dessin': impactDessin,
      'actif': actif,
      'ordre_affichage': ordreAffichage,
    };
  }

  String get typeOptionLabel {
    switch (typeOption) {
      case 'obligatoire':
        return 'Obligatoire';
      case 'facultatif':
        return 'Facultatif';
      default:
        return typeOption;
    }
  }

  String get impactPrixLabel {
    switch (impactPrixType) {
      case 'fixe':
        return '${impactPrixValeur.toStringAsFixed(2)} €';
      case 'pourcentage':
        return '${impactPrixValeur.toStringAsFixed(2)} %';
      default:
        return 'Aucun';
    }
  }
}




