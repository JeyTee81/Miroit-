import 'package:flutter/material.dart';
import 'ligne_devis_travaux_model.dart';

class DevisTravaux {
  final String? id;
  final String numeroDevis;
  final String clientId;
  final String? clientNom;
  final String? chantierId;
  final String? chantierNom;
  final DateTime dateDevis;
  final DateTime? dateValidite;
  final String typeTravaux;
  final String? description;
  final double montantHt;
  final double tauxTva;
  final double montantTtc;
  final String statut;
  final DateTime? dateEnvoi;
  final DateTime? dateAcceptation;
  final String? createdById;
  final String? createdByUsername;
  final List<LigneDevisTravaux>? lignes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DevisTravaux({
    this.id,
    required this.numeroDevis,
    required this.clientId,
    this.clientNom,
    this.chantierId,
    this.chantierNom,
    required this.dateDevis,
    this.dateValidite,
    required this.typeTravaux,
    this.description,
    this.montantHt = 0,
    this.tauxTva = 20,
    this.montantTtc = 0,
    this.statut = 'brouillon',
    this.dateEnvoi,
    this.dateAcceptation,
    this.createdById,
    this.createdByUsername,
    this.lignes,
    this.createdAt,
    this.updatedAt,
  });

  factory DevisTravaux.fromJson(Map<String, dynamic> json) {
    return DevisTravaux(
      id: json['id'],
      numeroDevis: json['numero_devis'] ?? '',
      clientId: json['client'] is String ? json['client'] : (json['client']?['id'] ?? ''),
      clientNom: json['client_nom'],
      chantierId: json['chantier'] is String ? json['chantier'] : (json['chantier']?['id']),
      chantierNom: json['chantier_nom'],
      dateDevis: json['date_devis'] != null ? DateTime.parse(json['date_devis']) : DateTime.now(),
      dateValidite: json['date_validite'] != null ? DateTime.tryParse(json['date_validite']) : null,
      typeTravaux: json['type_travaux'] ?? '',
      description: json['description'],
      montantHt: (json['montant_ht'] as num?)?.toDouble() ?? 0.0,
      tauxTva: (json['taux_tva'] as num?)?.toDouble() ?? 20.0,
      montantTtc: (json['montant_ttc'] as num?)?.toDouble() ?? 0.0,
      statut: json['statut'] ?? 'brouillon',
      dateEnvoi: json['date_envoi'] != null ? DateTime.tryParse(json['date_envoi']) : null,
      dateAcceptation: json['date_acceptation'] != null ? DateTime.tryParse(json['date_acceptation']) : null,
      createdById: json['created_by'] is String ? json['created_by'] : (json['created_by']?['id']),
      createdByUsername: json['created_by_username'],
      lignes: json['lignes'] != null
          ? (json['lignes'] as List).map((l) => LigneDevisTravaux.fromJson(l)).toList()
          : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'client': clientId,
      if (chantierId != null) 'chantier': chantierId,
      'date_devis': dateDevis.toIso8601String().split('T')[0],
      if (dateValidite != null) 'date_validite': dateValidite!.toIso8601String().split('T')[0],
      'type_travaux': typeTravaux,
      if (description != null) 'description': description,
      'montant_ht': montantHt,
      'taux_tva': tauxTva,
      'statut': statut,
      if (dateEnvoi != null) 'date_envoi': dateEnvoi!.toIso8601String().split('T')[0],
      if (dateAcceptation != null) 'date_acceptation': dateAcceptation!.toIso8601String().split('T')[0],
    };
  }

  String get statutLabel {
    switch (statut) {
      case 'brouillon':
        return 'Brouillon';
      case 'envoye':
        return 'Envoyé';
      case 'accepte':
        return 'Accepté';
      case 'refuse':
        return 'Refusé';
      default:
        return statut;
    }
  }

  Color get statutColor {
    switch (statut) {
      case 'brouillon':
        return Colors.grey;
      case 'envoye':
        return Colors.blue;
      case 'accepte':
        return Colors.green;
      case 'refuse':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

