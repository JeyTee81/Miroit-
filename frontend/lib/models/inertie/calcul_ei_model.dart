import 'utils.dart';

class CalculEI {
  final String? id;
  final String projetId;
  final String? projetNom;
  final String typeCharge;
  final String familleMateriauId;
  final String? familleMateriauNom;
  final double moduleElasticite;
  final Map<String, dynamic> dimensions;
  final String categorieTerrain;
  final double? e1;
  final double? e2;
  final double? e3;
  final double? chargeExercee;
  final double? chargeAdmissible;
  final double? iMini;
  final double? iReel;
  final double? iBesoin;
  final double? pressionCalcul;
  final String normeUtilisee;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CalculEI({
    this.id,
    required this.projetId,
    this.projetNom,
    required this.typeCharge,
    required this.familleMateriauId,
    this.familleMateriauNom,
    required this.moduleElasticite,
    required this.dimensions,
    this.categorieTerrain = '0',
    this.e1,
    this.e2,
    this.e3,
    this.chargeExercee,
    this.chargeAdmissible,
    this.iMini,
    this.iReel,
    this.iBesoin,
    this.pressionCalcul,
    this.normeUtilisee = 'NF EN 1991-1-4:2005',
    this.createdAt,
    this.updatedAt,
  });

  factory CalculEI.fromJson(Map<String, dynamic> json) {
    // Gérer le cas où projet et famille_materiau peuvent être des objets ou des strings
    String projetId;
    if (json['projet'] is String) {
      projetId = json['projet'];
    } else if (json['projet'] is Map) {
      projetId = json['projet']['id'] ?? '';
    } else {
      projetId = '';
    }
    
    String familleId;
    if (json['famille_materiau'] is String) {
      familleId = json['famille_materiau'];
    } else if (json['famille_materiau'] is Map) {
      familleId = json['famille_materiau']['id'] ?? '';
    } else {
      familleId = '';
    }
    
    return CalculEI(
      id: json['id'],
      projetId: projetId,
      projetNom: json['projet_nom'],
      typeCharge: json['type_charge'] ?? 'type1',
      familleMateriauId: familleId,
      familleMateriauNom: json['famille_materiau_nom'],
      moduleElasticite: parseDouble(json['module_elasticite']),
      dimensions: json['dimensions'] is Map ? Map<String, dynamic>.from(json['dimensions']) : {},
      categorieTerrain: json['categorie_terrain'] ?? '0',
      e1: parseDoubleNullable(json['e1']),
      e2: parseDoubleNullable(json['e2']),
      e3: parseDoubleNullable(json['e3']),
      chargeExercee: parseDoubleNullable(json['charge_exercee']),
      chargeAdmissible: parseDoubleNullable(json['charge_admissible']),
      iMini: parseDoubleNullable(json['i_mini']),
      iReel: parseDoubleNullable(json['i_reel']),
      iBesoin: parseDoubleNullable(json['i_besoin']),
      pressionCalcul: parseDoubleNullable(json['pression_calcul']),
      normeUtilisee: json['norme_utilisee'] ?? 'NF EN 1991-1-4:2005',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    // Extraire i_reel des dimensions s'il existe
    Map<String, dynamic> dims = Map<String, dynamic>.from(dimensions);
    dynamic iReelValue = dims.remove('i_reel');
    
    final json = {
      if (id != null) 'id': id,
      'projet': projetId,
      'type_charge': typeCharge,
      'famille_materiau': familleMateriauId,
      'module_elasticite': moduleElasticite,
      'dimensions': dims,
      'categorie_terrain': categorieTerrain,
      'norme_utilisee': normeUtilisee,
    };
    
    // Ajouter i_reel directement si présent
    if (iReelValue != null) {
      json['i_reel'] = iReelValue;
    }
    
    return json;
  }

  static List<String> get typeChargeOptions => [
    'type1',
    'type2',
    'type3',
  ];

  String get typeChargeLabel {
    switch (typeCharge) {
      case 'type1':
        return 'Type 1';
      case 'type2':
        return 'Type 2';
      case 'type3':
        return 'Type 3';
      default:
        return typeCharge;
    }
  }
}

