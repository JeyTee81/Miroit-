class ProjetVitrage {
  final String? id;
  final String numeroProjet;
  final String? chantierId;
  final String? chantierNom;
  final String nom;
  final DateTime dateCreation;
  final String? createdById;
  final String? createdByNom;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProjetVitrage({
    this.id,
    required this.numeroProjet,
    this.chantierId,
    this.chantierNom,
    required this.nom,
    required this.dateCreation,
    this.createdById,
    this.createdByNom,
    this.createdAt,
    this.updatedAt,
  });

  factory ProjetVitrage.fromJson(Map<String, dynamic> json) {
    return ProjetVitrage(
      id: json['id'],
      numeroProjet: json['numero_projet'] ?? '',
      chantierId: json['chantier'] is String
          ? json['chantier']
          : (json['chantier']?['id'] ?? null),
      chantierNom: json['chantier_nom'],
      nom: json['nom'] ?? '',
      dateCreation: json['date_creation'] != null
          ? DateTime.parse(json['date_creation'])
          : DateTime.now(),
      createdById: json['created_by'] is String
          ? json['created_by']
          : (json['created_by']?['id'] ?? null),
      createdByNom: json['created_by_nom'],
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
      if (numeroProjet.isNotEmpty) 'numero_projet': numeroProjet,
      if (chantierId != null) 'chantier': chantierId,
      'nom': nom,
    };
  }
}




