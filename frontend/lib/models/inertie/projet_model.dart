class ProjetInertie {
  final String? id;
  final String numeroProjet;
  final String? chantierId;
  final String? chantierNom;
  final String nom;
  final DateTime? dateCreation;
  final String? createdById;
  final String? createdByNom;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProjetInertie({
    this.id,
    required this.numeroProjet,
    this.chantierId,
    this.chantierNom,
    required this.nom,
    this.dateCreation,
    this.createdById,
    this.createdByNom,
    this.createdAt,
    this.updatedAt,
  });

  factory ProjetInertie.fromJson(Map<String, dynamic> json) {
    return ProjetInertie(
      id: json['id'],
      numeroProjet: json['numero_projet'] ?? '',
      chantierId: json['chantier'],
      chantierNom: json['chantier_nom'],
      nom: json['nom'] ?? '',
      dateCreation: json['date_creation'] != null ? DateTime.tryParse(json['date_creation']) : null,
      createdById: json['created_by'],
      createdByNom: json['created_by_nom'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'numero_projet': numeroProjet,
      if (chantierId != null) 'chantier': chantierId,
      'nom': nom,
    };
  }
}

