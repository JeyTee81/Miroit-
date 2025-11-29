import 'utils.dart';

class CalculTraverse {
  final String? id;
  final String projetId;
  final String? projetNom;
  final double portee;
  final double trameVerticale;
  final double poidsRemplissage;
  final double poidsTraverse;
  final double distanceBlocage;
  final String familleMateriauId;
  final String? familleMateriauNom;
  final double moduleElasticite;
  final String typeFleche;
  final double flecheAdmissible;
  final double? inertieRequise;
  final String? profilSelectionneId;
  final String? profilSelectionneCode;
  final bool choixAutomatiqueProfil;
  final String normeUtilisee;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CalculTraverse({
    this.id,
    required this.projetId,
    this.projetNom,
    required this.portee,
    required this.trameVerticale,
    required this.poidsRemplissage,
    required this.poidsTraverse,
    this.distanceBlocage = 40.0,
    required this.familleMateriauId,
    this.familleMateriauNom,
    required this.moduleElasticite,
    this.typeFleche = 'portee_200',
    required this.flecheAdmissible,
    this.inertieRequise,
    this.profilSelectionneId,
    this.profilSelectionneCode,
    this.choixAutomatiqueProfil = false,
    this.normeUtilisee = 'NF DTU 39 P1-1',
    this.createdAt,
    this.updatedAt,
  });

  factory CalculTraverse.fromJson(Map<String, dynamic> json) {
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
    
    return CalculTraverse(
      id: json['id'],
      projetId: projetId,
      projetNom: json['projet_nom'],
      portee: parseDouble(json['portee']),
      trameVerticale: parseDouble(json['trame_verticale']),
      poidsRemplissage: parseDouble(json['poids_remplissage']),
      poidsTraverse: parseDouble(json['poids_traverse']),
      distanceBlocage: parseDouble(json['distance_blocage'], defaultValue: 40.0),
      familleMateriauId: familleId,
      familleMateriauNom: json['famille_materiau_nom'],
      moduleElasticite: parseDouble(json['module_elasticite']),
      typeFleche: json['type_fleche'] ?? 'portee_200',
      flecheAdmissible: parseDouble(json['fleche_admissible']),
      inertieRequise: parseDoubleNullable(json['inertie_requise']),
      profilSelectionneId: json['profil_selectionne'] is String 
          ? json['profil_selectionne'] 
          : (json['profil_selectionne']?['id']),
      profilSelectionneCode: json['profil_selectionne_code'],
      choixAutomatiqueProfil: json['choix_automatique_profil'] ?? false,
      normeUtilisee: json['norme_utilisee'] ?? 'NF DTU 39 P1-1',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'projet': projetId,
      'portee': portee,
      'trame_verticale': trameVerticale,
      'poids_remplissage': poidsRemplissage,
      'poids_traverse': poidsTraverse,
      'distance_blocage': distanceBlocage,
      'famille_materiau': familleMateriauId,
      'module_elasticite': moduleElasticite,
      'type_fleche': typeFleche,
      'fleche_admissible': flecheAdmissible,
      'choix_automatique_profil': choixAutomatiqueProfil,
      'norme_utilisee': normeUtilisee,
    };
  }

  static List<String> get typeFlecheOptions => [
    'portee_200',
    'portee_300',
    'personnalise',
  ];

  String get typeFlecheLabel {
    switch (typeFleche) {
      case 'portee_200':
        return 'Portée / 200';
      case 'portee_300':
        return 'Portée / 300';
      case 'personnalise':
        return 'Personnalisée';
      default:
        return typeFleche;
    }
  }
}

