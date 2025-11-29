import 'utils.dart';

class FamilleMateriau {
  final String? id;
  final String nom;
  final double moduleElasticite;
  final bool actif;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FamilleMateriau({
    this.id,
    required this.nom,
    required this.moduleElasticite,
    this.actif = true,
    this.createdAt,
    this.updatedAt,
  });

  factory FamilleMateriau.fromJson(Map<String, dynamic> json) {
    return FamilleMateriau(
      id: json['id'],
      nom: json['nom'] ?? '',
      moduleElasticite: parseDouble(json['module_elasticite']),
      actif: json['actif'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nom': nom,
      'module_elasticite': moduleElasticite,
      'actif': actif,
    };
  }
}

