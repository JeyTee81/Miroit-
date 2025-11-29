import 'package:flutter/material.dart';
import 'livraison_chariot_model.dart';

class Livraison {
  final String? id;
  final String tourneeId;
  final String? factureId;
  final String? factureNumero;
  final String chantierId;
  final String? chantierNom;
  final int ordreLivraison;
  final String adresseLivraison;
  final double? latitude;
  final double? longitude;
  final String statut; // 'planifiee', 'en_transit', 'livree', 'echec'
  final DateTime dateLivraisonPrevue;
  final DateTime? dateLivraisonReelle;
  final String? signaturePath;
  final String? notes;
  final List<LivraisonChariot>? chariots;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Livraison({
    this.id,
    required this.tourneeId,
    this.factureId,
    this.factureNumero,
    required this.chantierId,
    this.chantierNom,
    required this.ordreLivraison,
    required this.adresseLivraison,
    this.latitude,
    this.longitude,
    this.statut = 'planifiee',
    required this.dateLivraisonPrevue,
    this.dateLivraisonReelle,
    this.signaturePath,
    this.notes,
    this.chariots,
    this.createdAt,
    this.updatedAt,
  });

  factory Livraison.fromJson(Map<String, dynamic> json) {
    return Livraison(
      id: json['id'],
      tourneeId: json['tournee'] is String
          ? json['tournee']
          : (json['tournee']?['id'] ?? ''),
      factureId: json['facture'] is String
          ? json['facture']
          : (json['facture']?['id'] ?? null),
      factureNumero: json['facture_numero'],
      chantierId: json['chantier'] is String
          ? json['chantier']
          : (json['chantier']?['id'] ?? ''),
      chantierNom: json['chantier_nom'],
      ordreLivraison: json['ordre_livraison'] ?? 0,
      adresseLivraison: json['adresse_livraison'] ?? '',
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      statut: json['statut'] ?? 'planifiee',
      dateLivraisonPrevue: json['date_livraison_prevue'] != null
          ? DateTime.parse(json['date_livraison_prevue'])
          : DateTime.now(),
      dateLivraisonReelle: json['date_livraison_reelle'] != null
          ? DateTime.tryParse(json['date_livraison_reelle'])
          : null,
      signaturePath: json['signature_path'],
      notes: json['notes'],
      chariots: json['chariots'] != null
          ? (json['chariots'] as List).map((c) => LivraisonChariot.fromJson(c)).toList()
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
      'tournee': tourneeId,
      if (factureId != null) 'facture': factureId,
      'chantier': chantierId,
      'ordre_livraison': ordreLivraison,
      'adresse_livraison': adresseLivraison,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'statut': statut,
      'date_livraison_prevue': dateLivraisonPrevue.toIso8601String(),
      if (dateLivraisonReelle != null)
        'date_livraison_reelle': dateLivraisonReelle!.toIso8601String(),
      if (notes != null) 'notes': notes,
    };
  }

  static List<String> get statutOptions => [
    'planifiee',
    'en_transit',
    'livree',
    'echec',
  ];

  String get statutLabel {
    switch (statut) {
      case 'planifiee':
        return 'Planifiée';
      case 'en_transit':
        return 'En transit';
      case 'livree':
        return 'Livrée';
      case 'echec':
        return 'Échec';
      default:
        return statut;
    }
  }

  Color get statutColor {
    switch (statut) {
      case 'planifiee':
        return Colors.blue;
      case 'en_transit':
        return Colors.orange;
      case 'livree':
        return Colors.green;
      case 'echec':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}




