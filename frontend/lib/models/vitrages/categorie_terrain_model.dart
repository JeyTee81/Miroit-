class CategorieTerrain {
  final String? id;
  final String code; // 'I', 'II', 'III', 'IV'
  final String nom;
  final String description;
  final double coefficientExposition;
  final String? photoPath;
  final bool actif;

  CategorieTerrain({
    this.id,
    required this.code,
    required this.nom,
    required this.description,
    required this.coefficientExposition,
    this.photoPath,
    this.actif = true,
  });

  factory CategorieTerrain.fromJson(Map<String, dynamic> json) {
    return CategorieTerrain(
      id: json['id'],
      code: json['code'] ?? '',
      nom: json['nom'] ?? '',
      description: json['description'] ?? '',
      coefficientExposition: json['coefficient_exposition'] != null
          ? (json['coefficient_exposition'] is num
              ? (json['coefficient_exposition'] as num).toDouble()
              : double.tryParse(json['coefficient_exposition'].toString()) ?? 1.0)
          : 1.0,
      photoPath: json['photo_path'],
      actif: json['actif'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'code': code,
      'nom': nom,
      'description': description,
      'coefficient_exposition': coefficientExposition,
      if (photoPath != null) 'photo_path': photoPath,
      'actif': actif,
    };
  }
}




