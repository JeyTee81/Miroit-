import 'package:flutter/material.dart';

class Visite {
  final String? id;
  final String clientId;
  final String? clientNom;
  final String? commercialId;
  final String? commercialNom;
  final DateTime dateVisite;
  final String typeVisite; // 'prise_contact', 'devis', 'suivi', 'relance'
  final String notes;
  final String? resultat;
  final DateTime? createdAt;

  Visite({
    this.id,
    required this.clientId,
    this.clientNom,
    this.commercialId,
    this.commercialNom,
    required this.dateVisite,
    required this.typeVisite,
    required this.notes,
    this.resultat,
    this.createdAt,
  });

  factory Visite.fromJson(Map<String, dynamic> json) {
    return Visite(
      id: json['id'],
      clientId: json['client'] is String
          ? json['client']
          : (json['client']?['id'] ?? ''),
      clientNom: json['client_nom'],
      commercialId: json['commercial'] is String
          ? json['commercial']
          : (json['commercial']?['id'] ?? null),
      commercialNom: json['commercial_nom'],
      dateVisite: json['date_visite'] != null
          ? DateTime.parse(json['date_visite'])
          : DateTime.now(),
      typeVisite: json['type_visite'] ?? 'prise_contact',
      notes: json['notes'] ?? '',
      resultat: json['resultat'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'client': clientId,
      if (commercialId != null) 'commercial': commercialId,
      'date_visite': dateVisite.toIso8601String().split('T')[0],
      'type_visite': typeVisite,
      'notes': notes,
      if (resultat != null) 'resultat': resultat,
    };
  }

  static List<String> get typeOptions => [
    'prise_contact',
    'devis',
    'suivi',
    'relance',
  ];

  String get typeLabel {
    switch (typeVisite) {
      case 'prise_contact':
        return 'Prise de contact';
      case 'devis':
        return 'Devis';
      case 'suivi':
        return 'Suivi';
      case 'relance':
        return 'Relance';
      default:
        return typeVisite;
    }
  }

  Color get typeColor {
    switch (typeVisite) {
      case 'prise_contact':
        return Colors.blue;
      case 'devis':
        return Colors.orange;
      case 'suivi':
        return Colors.green;
      case 'relance':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}




