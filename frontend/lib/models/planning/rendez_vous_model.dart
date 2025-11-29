import 'package:flutter/material.dart';

class RendezVous {
  final String? id;
  final String titre;
  final String? description;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String type; // 'commercial', 'travaux', 'livraison'
  final String utilisateurId;
  final String? utilisateurNom;
  final String? clientId;
  final String? clientNom;
  final String? chantierId;
  final String? chantierNom;
  final String? lieu;
  final String statut; // 'planifie', 'confirme', 'annule', 'termine'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RendezVous({
    this.id,
    required this.titre,
    this.description,
    required this.dateDebut,
    required this.dateFin,
    required this.type,
    required this.utilisateurId,
    this.utilisateurNom,
    this.clientId,
    this.clientNom,
    this.chantierId,
    this.chantierNom,
    this.lieu,
    this.statut = 'planifie',
    this.createdAt,
    this.updatedAt,
  });

  factory RendezVous.fromJson(Map<String, dynamic> json) {
    return RendezVous(
      id: json['id'],
      titre: json['titre'] ?? '',
      description: json['description'],
      dateDebut: json['date_debut'] != null
          ? DateTime.parse(json['date_debut'])
          : DateTime.now(),
      dateFin: json['date_fin'] != null
          ? DateTime.parse(json['date_fin'])
          : DateTime.now(),
      type: json['type'] ?? 'commercial',
      utilisateurId: json['utilisateur'] is String
          ? json['utilisateur']
          : (json['utilisateur']?['id'] ?? ''),
      utilisateurNom: json['utilisateur_nom'],
      clientId: json['client'] is String
          ? json['client']
          : (json['client']?['id'] ?? null),
      clientNom: json['client_nom'],
      chantierId: json['chantier'] is String
          ? json['chantier']
          : (json['chantier']?['id'] ?? null),
      chantierNom: json['chantier_nom'],
      lieu: json['lieu'],
      statut: json['statut'] ?? 'planifie',
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
      'titre': titre,
      if (description != null) 'description': description,
      'date_debut': dateDebut.toIso8601String(),
      'date_fin': dateFin.toIso8601String(),
      'type': type,
      'utilisateur': utilisateurId,
      if (clientId != null) 'client': clientId,
      if (chantierId != null) 'chantier': chantierId,
      if (lieu != null) 'lieu': lieu,
      'statut': statut,
    };
  }

  static List<String> get typeOptions => [
    'commercial',
    'travaux',
    'livraison',
  ];

  String get typeLabel {
    switch (type) {
      case 'commercial':
        return 'Commercial';
      case 'travaux':
        return 'Travaux';
      case 'livraison':
        return 'Livraison';
      default:
        return type;
    }
  }

  Color get typeColor {
    switch (type) {
      case 'commercial':
        return Colors.blue;
      case 'travaux':
        return Colors.orange;
      case 'livraison':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  static List<String> get statutOptions => [
    'planifie',
    'confirme',
    'annule',
    'termine',
  ];

  String get statutLabel {
    switch (statut) {
      case 'planifie':
        return 'Planifié';
      case 'confirme':
        return 'Confirmé';
      case 'annule':
        return 'Annulé';
      case 'termine':
        return 'Terminé';
      default:
        return statut;
    }
  }

  Color get statutColor {
    switch (statut) {
      case 'planifie':
        return Colors.blue;
      case 'confirme':
        return Colors.green;
      case 'annule':
        return Colors.red;
      case 'termine':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  bool get isCommercial => type == 'commercial';
  bool get isTravaux => type == 'travaux';
  bool get isLivraison => type == 'livraison';
}




