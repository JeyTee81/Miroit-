class Matiere {
  final String? id;
  final String code;
  final String designation;
  final String typeMatiere; // 'plaque', 'barre', 'bobine', etc.
  final double? epaisseur; // en mm
  final double? largeurStandard; // en mm
  final double? longueurStandard; // en mm
  final String unite;
  final double? prixUnitaire;
  final bool actif;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Matiere({
    this.id,
    required this.code,
    required this.designation,
    required this.typeMatiere,
    this.epaisseur,
    this.largeurStandard,
    this.longueurStandard,
    this.unite = 'mm',
    this.prixUnitaire,
    this.actif = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Matiere.fromJson(Map<String, dynamic> json) {
    return Matiere(
      id: json['id'],
      code: json['code'] ?? '',
      designation: json['designation'] ?? '',
      typeMatiere: json['type_matiere'] ?? 'plaque',
      epaisseur: json['epaisseur'] != null
          ? (json['epaisseur'] is num
              ? (json['epaisseur'] as num).toDouble()
              : double.tryParse(json['epaisseur'].toString()))
          : null,
      largeurStandard: json['largeur_standard'] != null
          ? (json['largeur_standard'] is num
              ? (json['largeur_standard'] as num).toDouble()
              : double.tryParse(json['largeur_standard'].toString()))
          : null,
      longueurStandard: json['longueur_standard'] != null
          ? (json['longueur_standard'] is num
              ? (json['longueur_standard'] as num).toDouble()
              : double.tryParse(json['longueur_standard'].toString()))
          : null,
      unite: json['unite'] ?? 'mm',
      prixUnitaire: json['prix_unitaire'] != null
          ? (json['prix_unitaire'] is num
              ? (json['prix_unitaire'] as num).toDouble()
              : double.tryParse(json['prix_unitaire'].toString()))
          : null,
      actif: json['actif'] ?? true,
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
      'designation': designation,
      'type_matiere': typeMatiere,
      if (epaisseur != null) 'epaisseur': epaisseur,
      if (largeurStandard != null) 'largeur_standard': largeurStandard,
      if (longueurStandard != null) 'longueur_standard': longueurStandard,
      'unite': unite,
      if (prixUnitaire != null) 'prix_unitaire': prixUnitaire,
      'actif': actif,
    };
  }

  String get typeLabel {
    switch (typeMatiere) {
      case 'plaque':
        return 'Plaque';
      case 'barre':
        return 'Barre';
      case 'bobine':
        return 'Bobine';
      case 'panneau':
        return 'Panneau';
      case 'tole':
        return 'Tôle';
      case 'vitrage':
        return 'Vitrage';
      case 'plastique':
        return 'Plastique';
      case 'autre':
        return 'Autre';
      default:
        return typeMatiere;
    }
  }
}




