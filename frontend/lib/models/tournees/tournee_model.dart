import 'package:flutter/material.dart';
import 'vehicule_model.dart';
import 'chauffeur_model.dart';
import 'livraison_model.dart';

class Tournee {
  final String? id;
  final String numeroTournee;
  final DateTime dateTournee;
  final String vehiculeId;
  final Vehicule? vehiculeDetail;
  final String chauffeurId;
  final Chauffeur? chauffeurDetail;
  final String statut; // 'planifiee', 'en_cours', 'terminee', 'annulee'
  final Map<String, dynamic>? itineraireOptimise;
  final double? distanceTotale;
  final int? dureeEstimee; // en minutes
  final List<Livraison>? livraisons;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Tournee({
    this.id,
    required this.numeroTournee,
    required this.dateTournee,
    required this.vehiculeId,
    this.vehiculeDetail,
    required this.chauffeurId,
    this.chauffeurDetail,
    this.statut = 'planifiee',
    this.itineraireOptimise,
    this.distanceTotale,
    this.dureeEstimee,
    this.livraisons,
    this.createdAt,
    this.updatedAt,
  });

  factory Tournee.fromJson(Map<String, dynamic> json) {
    return Tournee(
      id: json['id'],
      numeroTournee: json['numero_tournee'] ?? '',
      dateTournee: json['date_tournee'] != null
          ? DateTime.parse(json['date_tournee'])
          : DateTime.now(),
      vehiculeId: json['vehicule'] is String
          ? json['vehicule']
          : (json['vehicule']?['id'] ?? ''),
      vehiculeDetail: json['vehicule_detail'] != null
          ? Vehicule.fromJson(json['vehicule_detail'])
          : null,
      chauffeurId: json['chauffeur'] is String
          ? json['chauffeur']
          : (json['chauffeur']?['id'] ?? ''),
      chauffeurDetail: json['chauffeur_detail'] != null
          ? Chauffeur.fromJson(json['chauffeur_detail'])
          : null,
      statut: json['statut'] ?? 'planifiee',
      itineraireOptimise: json['itineraire_optimise'] is Map
          ? Map<String, dynamic>.from(json['itineraire_optimise'])
          : null,
      distanceTotale: json['distance_totale'] != null
          ? (json['distance_totale'] as num).toDouble()
          : null,
      dureeEstimee: json['duree_estimee'],
      livraisons: json['livraisons'] != null
          ? (json['livraisons'] as List).map((l) => Livraison.fromJson(l)).toList()
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
      if (numeroTournee.isNotEmpty) 'numero_tournee': numeroTournee,
      'date_tournee': dateTournee.toIso8601String().split('T')[0],
      'vehicule': vehiculeId,
      'chauffeur': chauffeurId,
      'statut': statut,
    };
  }

  static List<String> get statutOptions => [
    'planifiee',
    'en_cours',
    'terminee',
    'annulee',
  ];

  String get statutLabel {
    switch (statut) {
      case 'planifiee':
        return 'Planifiée';
      case 'en_cours':
        return 'En cours';
      case 'terminee':
        return 'Terminée';
      case 'annulee':
        return 'Annulée';
      default:
        return statut;
    }
  }

  Color get statutColor {
    switch (statut) {
      case 'planifiee':
        return Colors.blue;
      case 'en_cours':
        return Colors.orange;
      case 'terminee':
        return Colors.green;
      case 'annulee':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}




