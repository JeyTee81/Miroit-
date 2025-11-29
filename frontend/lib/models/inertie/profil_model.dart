import 'utils.dart';

class Profil {
  final String? id;
  final String familleMateriauId;
  final String? familleMateriauNom;
  final String codeProfil;
  final String designation;
  final double inertieIxx;
  final double inertieIyy;
  final bool actif;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Profil({
    this.id,
    required this.familleMateriauId,
    this.familleMateriauNom,
    required this.codeProfil,
    required this.designation,
    required this.inertieIxx,
    required this.inertieIyy,
    this.actif = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Profil.fromJson(Map<String, dynamic> json) {
    // Gérer le cas où famille_materiau peut être un objet ou une string
    String familleId;
    if (json['famille_materiau'] is String) {
      familleId = json['famille_materiau'];
    } else if (json['famille_materiau'] is Map) {
      familleId = json['famille_materiau']['id'] ?? '';
    } else {
      familleId = '';
    }
    
    return Profil(
      id: json['id'],
      familleMateriauId: familleId,
      familleMateriauNom: json['famille_materiau_nom'],
      codeProfil: json['code_profil'] ?? '',
      designation: json['designation'] ?? '',
      inertieIxx: parseDouble(json['inertie_ixx']),
      inertieIyy: parseDouble(json['inertie_iyy']),
      actif: json['actif'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'famille_materiau': familleMateriauId,
      'code_profil': codeProfil,
      'designation': designation,
      'inertie_ixx': inertieIxx,
      'inertie_iyy': inertieIyy,
      'actif': actif,
    };
  }
}

