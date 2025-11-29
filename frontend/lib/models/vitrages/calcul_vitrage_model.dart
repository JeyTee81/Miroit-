import 'region_vent_neige_model.dart';
import 'categorie_terrain_model.dart';

class CalculVitrage {
  final String? id;
  final String projetId;
  final String? projetNumero;
  final double largeur; // en mm
  final double hauteur; // en mm
  final String typeVitrage; // 'monolithique', 'feuilleté', 'isolation', 'aquarium', etc.
  final String? regionVentId;
  final RegionVentNeige? regionVentDetail;
  final String? regionNeigeId;
  final RegionVentNeige? regionNeigeDetail;
  final String? categorieTerrainId;
  final CategorieTerrain? categorieTerrainDetail;
  final double altitude; // en mètres
  final double? pressionVent; // en Pa
  final double? chargeNeige; // en Pa
  final double coefficientSecurite;
  final double? epaisseurCalculee; // en mm
  final double? epaisseurRecommandee; // en mm
  final Map<String, dynamic>? resultatCalcul;
  final String normeUtilisee;
  final String? cahierCstb;
  final String? pdfPath;
  final String? entetePersonnalisee;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CalculVitrage({
    this.id,
    required this.projetId,
    this.projetNumero,
    required this.largeur,
    required this.hauteur,
    required this.typeVitrage,
    this.regionVentId,
    this.regionVentDetail,
    this.regionNeigeId,
    this.regionNeigeDetail,
    this.categorieTerrainId,
    this.categorieTerrainDetail,
    this.altitude = 0,
    this.pressionVent,
    this.chargeNeige,
    this.coefficientSecurite = 2.5,
    this.epaisseurCalculee,
    this.epaisseurRecommandee,
    this.resultatCalcul,
    this.normeUtilisee = 'NF DTU 39 P4',
    this.cahierCstb,
    this.pdfPath,
    this.entetePersonnalisee,
    this.createdAt,
    this.updatedAt,
  });

  factory CalculVitrage.fromJson(Map<String, dynamic> json) {
    return CalculVitrage(
      id: json['id'],
      projetId: json['projet'] is String
          ? json['projet']
          : (json['projet']?['id'] ?? ''),
      projetNumero: json['projet_numero'],
      largeur: json['largeur'] != null
          ? (json['largeur'] is num
              ? (json['largeur'] as num).toDouble()
              : double.tryParse(json['largeur'].toString()) ?? 0.0)
          : 0.0,
      hauteur: json['hauteur'] != null
          ? (json['hauteur'] is num
              ? (json['hauteur'] as num).toDouble()
              : double.tryParse(json['hauteur'].toString()) ?? 0.0)
          : 0.0,
      typeVitrage: json['type_vitrage'] ?? 'monolithique',
      regionVentId: json['region_vent'] is String
          ? json['region_vent']
          : (json['region_vent']?['id'] ?? null),
      regionVentDetail: json['region_vent_detail'] != null
          ? RegionVentNeige.fromJson(json['region_vent_detail'])
          : null,
      regionNeigeId: json['region_neige'] is String
          ? json['region_neige']
          : (json['region_neige']?['id'] ?? null),
      regionNeigeDetail: json['region_neige_detail'] != null
          ? RegionVentNeige.fromJson(json['region_neige_detail'])
          : null,
      categorieTerrainId: json['categorie_terrain'] is String
          ? json['categorie_terrain']
          : (json['categorie_terrain']?['id'] ?? null),
      categorieTerrainDetail: json['categorie_terrain_detail'] != null
          ? CategorieTerrain.fromJson(json['categorie_terrain_detail'])
          : null,
      altitude: json['altitude'] != null
          ? (json['altitude'] is num
              ? (json['altitude'] as num).toDouble()
              : double.tryParse(json['altitude'].toString()) ?? 0.0)
          : 0.0,
      pressionVent: json['pression_vent'] != null
          ? (json['pression_vent'] is num
              ? (json['pression_vent'] as num).toDouble()
              : double.tryParse(json['pression_vent'].toString()))
          : null,
      chargeNeige: json['charge_neige'] != null
          ? (json['charge_neige'] is num
              ? (json['charge_neige'] as num).toDouble()
              : double.tryParse(json['charge_neige'].toString()))
          : null,
      coefficientSecurite: json['coefficient_securite'] != null
          ? (json['coefficient_securite'] is num
              ? (json['coefficient_securite'] as num).toDouble()
              : double.tryParse(json['coefficient_securite'].toString()) ?? 2.5)
          : 2.5,
      epaisseurCalculee: json['epaisseur_calculee'] != null
          ? (json['epaisseur_calculee'] is num
              ? (json['epaisseur_calculee'] as num).toDouble()
              : double.tryParse(json['epaisseur_calculee'].toString()))
          : null,
      epaisseurRecommandee: json['epaisseur_recommandee'] != null
          ? (json['epaisseur_recommandee'] is num
              ? (json['epaisseur_recommandee'] as num).toDouble()
              : double.tryParse(json['epaisseur_recommandee'].toString()))
          : null,
      resultatCalcul: json['resultat_calcul'] is Map
          ? Map<String, dynamic>.from(json['resultat_calcul'])
          : null,
      normeUtilisee: json['norme_utilisee'] ?? 'NF DTU 39 P4',
      cahierCstb: json['cahier_cstb'],
      pdfPath: json['pdf_path'],
      entetePersonnalisee: json['entete_personnalisee'],
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
      'projet': projetId,
      'largeur': largeur,
      'hauteur': hauteur,
      'type_vitrage': typeVitrage,
      if (regionVentId != null) 'region_vent': regionVentId,
      if (regionNeigeId != null) 'region_neige': regionNeigeId,
      if (categorieTerrainId != null) 'categorie_terrain': categorieTerrainId,
      'altitude': altitude,
      if (pressionVent != null) 'pression_vent': pressionVent,
      if (chargeNeige != null) 'charge_neige': chargeNeige,
      'coefficient_securite': coefficientSecurite,
      'norme_utilisee': normeUtilisee,
      if (cahierCstb != null) 'cahier_cstb': cahierCstb,
      if (entetePersonnalisee != null) 'entete_personnalisee': entetePersonnalisee,
    };
  }

  static List<String> get typeOptions => [
    'monolithique',
    'feuilleté',
    'isolation',
    'aquarium',
    'bassin',
    'etagere',
    'dalle_sol',
    'vea',
    'vec',
    'autre',
  ];

  String get typeLabel {
    switch (typeVitrage) {
      case 'monolithique':
        return 'Monolithique';
      case 'feuilleté':
        return 'Feuilleté';
      case 'isolation':
        return 'Isolation';
      case 'aquarium':
        return 'Aquarium';
      case 'bassin':
        return 'Bassin';
      case 'etagere':
        return 'Étagère';
      case 'dalle_sol':
        return 'Dalle de sol';
      case 'vea':
        return 'VEA - Verre Extérieur Agrafé';
      case 'vec':
        return 'VEC - Verre Extérieur Collé';
      case 'autre':
        return 'Autre';
      default:
        return typeVitrage;
    }
  }
}




