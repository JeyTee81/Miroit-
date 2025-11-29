import 'lancement_model.dart';

class Affaire {
  final String? id;
  final String numeroAffaire;
  final String nom;
  final String? chantierId;
  final String? chantierNom;
  final String? description;
  final String statut; // 'brouillon', 'en_cours', 'termine', 'archive'
  final String? createdById;
  final String? createdByNom;
  final List<Lancement>? lancements;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Affaire({
    this.id,
    required this.numeroAffaire,
    required this.nom,
    this.chantierId,
    this.chantierNom,
    this.description,
    this.statut = 'brouillon',
    this.createdById,
    this.createdByNom,
    this.lancements,
    this.createdAt,
    this.updatedAt,
  });

  factory Affaire.fromJson(Map<String, dynamic> json) {
    return Affaire(
      id: json['id'],
      numeroAffaire: json['numero_affaire'] ?? '',
      nom: json['nom'] ?? '',
      chantierId: json['chantier'] is String
          ? json['chantier']
          : (json['chantier']?['id'] ?? null),
      chantierNom: json['chantier_nom'],
      description: json['description'],
      statut: json['statut'] ?? 'brouillon',
      createdById: json['created_by'] is String
          ? json['created_by']
          : (json['created_by']?['id'] ?? null),
      createdByNom: json['created_by_nom'],
      lancements: json['lancements'] != null
          ? (json['lancements'] as List)
              .map((l) => Lancement.fromJson(l))
              .toList()
          : null,
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
      if (numeroAffaire.isNotEmpty) 'numero_affaire': numeroAffaire,
      'nom': nom,
      if (chantierId != null) 'chantier': chantierId,
      if (description != null) 'description': description,
      'statut': statut,
    };
  }

  String get statutLabel {
    switch (statut) {
      case 'brouillon':
        return 'Brouillon';
      case 'en_cours':
        return 'En cours';
      case 'termine':
        return 'Terminé';
      case 'archive':
        return 'Archivé';
      default:
        return statut;
    }
  }
}




