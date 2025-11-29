import 'package:flutter/material.dart';

class Projet {
  final String? id;
  final String? numeroProjet;
  final String? devisId;
  final String? devisNumero;
  final String? chantierId;
  final String? chantierNom;
  final String nom;
  final DateTime? dateCreation;
  final String statut;
  final String? createdById;
  final String? createdByUsername;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Projet({
    this.id,
    this.numeroProjet,
    this.devisId,
    this.devisNumero,
    this.chantierId,
    this.chantierNom,
    required this.nom,
    this.dateCreation,
    this.statut = 'brouillon',
    this.createdById,
    this.createdByUsername,
    this.createdAt,
    this.updatedAt,
  });

  factory Projet.fromJson(Map<String, dynamic> json) {
    return Projet(
      id: json['id'],
      numeroProjet: json['numero_projet'],
      devisId: json['devis'] is String ? json['devis'] : (json['devis']?['id'] ?? null),
      devisNumero: json['devis_numero'],
      chantierId: json['chantier'] is String ? json['chantier'] : (json['chantier']?['id'] ?? null),
      chantierNom: json['chantier_nom'],
      nom: json['nom'] ?? '',
      dateCreation: json['date_creation'] != null 
          ? DateTime.tryParse(json['date_creation']) 
          : null,
      statut: json['statut'] ?? 'brouillon',
      createdById: json['created_by'] is String ? json['created_by'] : (json['created_by']?['id'] ?? null),
      createdByUsername: json['created_by_username'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (numeroProjet != null) 'numero_projet': numeroProjet,
      if (devisId != null) 'devis': devisId,
      if (chantierId != null) 'chantier': chantierId,
      'nom': nom,
      'statut': statut,
      if (createdById != null) 'created_by': createdById,
    };
  }

  static List<String> get statutOptions => [
    'brouillon',
    'en_cours',
    'termine',
  ];

  String get statutLabel {
    switch (statut) {
      case 'brouillon':
        return 'Brouillon';
      case 'en_cours':
        return 'En cours';
      case 'termine':
        return 'Terminé';
      default:
        return statut;
    }
  }

  Color get statutColor {
    switch (statut) {
      case 'brouillon':
        return Colors.grey;
      case 'en_cours':
        return Colors.orange;
      case 'termine':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}





