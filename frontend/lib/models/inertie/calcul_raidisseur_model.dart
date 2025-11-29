import 'utils.dart';

class CalculRaidisseur {
  final String? id;
  final String projetId;
  final String? projetNom;
  final String nomCalcul;
  final String typeCharge;
  final String familleMateriauId;
  final String? familleMateriauNom;
  final double moduleElasticite;
  final double portee;
  final double trame;
  final double flecheAdmissible;
  final String regionVent;
  final String categorieTerrain;
  final double? hauteurSol;
  final double? penteToiture;
  final double? penteObstacles;
  final bool constructionsVoisines;
  final String? regionNeige;
  final double? pressionVent;
  final double? inertieRequise;
  final String? profilSelectionneId;
  final String? profilSelectionneCode;
  final bool calculAvecRenfort;
  final bool choixAutomatiqueProfil;
  final String normeUtilisee;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CalculRaidisseur({
    this.id,
    required this.projetId,
    this.projetNom,
    this.nomCalcul = "NF DTU 30.1 (2008 - fiche Technique N°45/2010)",
    required this.typeCharge,
    required this.familleMateriauId,
    this.familleMateriauNom,
    required this.moduleElasticite,
    required this.portee,
    required this.trame,
    required this.flecheAdmissible,
    this.regionVent = '01',
    this.categorieTerrain = '0',
    this.hauteurSol,
    this.penteToiture,
    this.penteObstacles,
    this.constructionsVoisines = false,
    this.regionNeige,
    this.pressionVent,
    this.inertieRequise,
    this.profilSelectionneId,
    this.profilSelectionneCode,
    this.calculAvecRenfort = false,
    this.choixAutomatiqueProfil = false,
    this.normeUtilisee = 'NF EN 1991-1-4/NA',
    this.createdAt,
    this.updatedAt,
  });

  factory CalculRaidisseur.fromJson(Map<String, dynamic> json) {
    // Gérer le cas où famille_materiau peut être un objet ou une string
    String familleId;
    if (json['famille_materiau'] is String) {
      familleId = json['famille_materiau'];
    } else if (json['famille_materiau'] is Map) {
      familleId = json['famille_materiau']['id'] ?? '';
    } else {
      familleId = '';
    }
    
    return CalculRaidisseur(
      id: json['id'],
      projetId: json['projet'] is String ? json['projet'] : (json['projet']?['id'] ?? ''),
      projetNom: json['projet_nom'],
      nomCalcul: json['nom_calcul'] ?? "NF DTU 30.1 (2008 - fiche Technique N°45/2010)",
      typeCharge: json['type_charge'],
      familleMateriauId: familleId,
      familleMateriauNom: json['famille_materiau_nom'],
      moduleElasticite: parseDouble(json['module_elasticite']),
      portee: parseDouble(json['portee']),
      trame: parseDouble(json['trame']),
      flecheAdmissible: parseDouble(json['fleche_admissible']),
      regionVent: json['region_vent'] ?? '01',
      categorieTerrain: json['categorie_terrain'] ?? '0',
      hauteurSol: parseDoubleNullable(json['hauteur_sol']),
      penteToiture: parseDoubleNullable(json['pente_toiture']),
      penteObstacles: parseDoubleNullable(json['pente_obstacles']),
      constructionsVoisines: json['constructions_voisines'] ?? false,
      regionNeige: json['region_neige'],
      pressionVent: parseDoubleNullable(json['pression_vent']),
      inertieRequise: parseDoubleNullable(json['inertie_requise']),
      profilSelectionneId: json['profil_selectionne'] is String 
          ? json['profil_selectionne'] 
          : (json['profil_selectionne']?['id']),
      profilSelectionneCode: json['profil_selectionne_code'],
      calculAvecRenfort: json['calcul_avec_renfort'] ?? false,
      choixAutomatiqueProfil: json['choix_automatique_profil'] ?? false,
      normeUtilisee: json['norme_utilisee'] ?? 'NF EN 1991-1-4/NA',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'projet': projetId,
      'nom_calcul': nomCalcul,
      'type_charge': typeCharge,
      'famille_materiau': familleMateriauId,
      'module_elasticite': moduleElasticite,
      'portee': portee,
      'trame': trame,
      'fleche_admissible': flecheAdmissible,
      'region_vent': regionVent,
      'categorie_terrain': categorieTerrain,
      if (hauteurSol != null) 'hauteur_sol': hauteurSol,
      if (penteToiture != null) 'pente_toiture': penteToiture,
      if (penteObstacles != null) 'pente_obstacles': penteObstacles,
      'constructions_voisines': constructionsVoisines,
      if (regionNeige != null) 'region_neige': regionNeige,
      'calcul_avec_renfort': calculAvecRenfort,
      'choix_automatique_profil': choixAutomatiqueProfil,
      'norme_utilisee': normeUtilisee,
    };
  }

  static List<String> get typeChargeOptions => [
    'rectangulaire_2_appuis',
    'encastrement_appui',
    'rectangulaire_3_appuis',
    'trapezoidale',
  ];

  String get typeChargeLabel {
    switch (typeCharge) {
      case 'rectangulaire_2_appuis':
        return 'Rectangulaire sur 2 appuis';
      case 'encastrement_appui':
        return '1 encastrement et 1 appui';
      case 'rectangulaire_3_appuis':
        return 'Rectangulaire sur 3 appuis';
      case 'trapezoidale':
        return 'Trapézoïdale';
      default:
        return typeCharge;
    }
  }
}

