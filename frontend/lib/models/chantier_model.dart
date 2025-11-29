import 'package:flutter/material.dart';

class Chantier {
  final String? id;
  final String nom;
  final String clientId;
  final String? clientNom;
  final String adresseLivraison;
  final DateTime dateDebut;
  final DateTime dateFinPrevue;
  final DateTime? dateFinReelle;
  final String statut;
  final String? chefChantierId;
  final String? commercialId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Chantier({
    this.id,
    required this.nom,
    required this.clientId,
    this.clientNom,
    required this.adresseLivraison,
    required this.dateDebut,
    required this.dateFinPrevue,
    this.dateFinReelle,
    this.statut = 'planifie',
    this.chefChantierId,
    this.commercialId,
    this.createdAt,
    this.updatedAt,
  });

  factory Chantier.fromJson(Map<String, dynamic> json) {
    String? clientIdValue;
    if (json['client'] is String) {
      clientIdValue = json['client'];
    } else if (json['client'] is Map) {
      clientIdValue = json['client']?['id']?.toString();
    } else {
      clientIdValue = json['client']?.toString();
    }
    
    return Chantier(
      id: json['id']?.toString(),
      nom: json['nom']?.toString() ?? '',
      clientId: clientIdValue ?? '',
      clientNom: json['client_nom']?.toString(),
      adresseLivraison: json['adresse_livraison']?.toString() ?? '',
      dateDebut: json['date_debut'] != null 
          ? DateTime.tryParse(json['date_debut'].toString()) ?? DateTime.now()
          : DateTime.now(),
      dateFinPrevue: json['date_fin_prevue'] != null 
          ? DateTime.tryParse(json['date_fin_prevue'].toString()) ?? DateTime.now()
          : DateTime.now(),
      dateFinReelle: json['date_fin_reelle'] != null 
          ? DateTime.tryParse(json['date_fin_reelle'].toString())
          : null,
      statut: json['statut']?.toString() ?? 'planifie',
      chefChantierId: json['chef_chantier']?.toString(),
      commercialId: json['commercial']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nom': nom,
      'client': clientId,
      'adresse_livraison': adresseLivraison,
      'date_debut': dateDebut.toIso8601String().split('T')[0],
      'date_fin_prevue': dateFinPrevue.toIso8601String().split('T')[0],
      if (dateFinReelle != null) 'date_fin_reelle': dateFinReelle!.toIso8601String().split('T')[0],
      'statut': statut,
      if (chefChantierId != null) 'chef_chantier': chefChantierId,
      if (commercialId != null) 'commercial': commercialId,
    };
  }

  static List<String> get statutOptions => [
    'planifie',
    'en_cours',
    'termine',
    'annule',
  ];

  String get statutLabel {
    switch (statut) {
      case 'planifie':
        return 'Planifié';
      case 'en_cours':
        return 'En cours';
      case 'termine':
        return 'Terminé';
      case 'annule':
        return 'Annulé';
      default:
        return statut;
    }
  }

  Color get statutColor {
    switch (statut) {
      case 'planifie':
        return Colors.blue;
      case 'en_cours':
        return Colors.orange;
      case 'termine':
        return Colors.green;
      case 'annule':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

