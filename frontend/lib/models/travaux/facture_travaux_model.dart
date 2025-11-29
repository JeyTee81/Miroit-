import 'package:flutter/material.dart';
import 'ligne_facture_travaux_model.dart';

class FactureTravaux {
  final String? id;
  final String numeroFacture;
  final String? commandeId;
  final String? commandeNumero;
  final String? devisId;
  final String? devisNumero;
  final String clientId;
  final String? clientNom;
  final String? chantierId;
  final String? chantierNom;
  final DateTime dateFacture;
  final DateTime? dateEcheance;
  final String typeTravaux;
  final String? description;
  final double montantHt;
  final double tauxTva;
  final double montantTtc;
  final double montantPaye;
  final double montantRestant;
  final String statut;
  final String? createdById;
  final String? createdByUsername;
  final List<LigneFactureTravaux>? lignes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FactureTravaux({
    this.id,
    required this.numeroFacture,
    this.commandeId,
    this.commandeNumero,
    this.devisId,
    this.devisNumero,
    required this.clientId,
    this.clientNom,
    this.chantierId,
    this.chantierNom,
    required this.dateFacture,
    this.dateEcheance,
    required this.typeTravaux,
    this.description,
    this.montantHt = 0,
    this.tauxTva = 20,
    this.montantTtc = 0,
    this.montantPaye = 0,
    this.montantRestant = 0,
    this.statut = 'brouillon',
    this.createdById,
    this.createdByUsername,
    this.lignes,
    this.createdAt,
    this.updatedAt,
  });

  factory FactureTravaux.fromJson(Map<String, dynamic> json) {
    return FactureTravaux(
      id: json['id'],
      numeroFacture: json['numero_facture'] ?? '',
      commandeId: json['commande'] is String ? json['commande'] : (json['commande']?['id']),
      commandeNumero: json['commande_numero'],
      devisId: json['devis'] is String ? json['devis'] : (json['devis']?['id']),
      devisNumero: json['devis_numero'],
      clientId: json['client'] is String ? json['client'] : (json['client']?['id'] ?? ''),
      clientNom: json['client_nom'],
      chantierId: json['chantier'] is String ? json['chantier'] : (json['chantier']?['id']),
      chantierNom: json['chantier_nom'],
      dateFacture: json['date_facture'] != null ? DateTime.parse(json['date_facture']) : DateTime.now(),
      dateEcheance: json['date_echeance'] != null ? DateTime.tryParse(json['date_echeance']) : null,
      typeTravaux: json['type_travaux'] ?? '',
      description: json['description'],
      montantHt: (json['montant_ht'] as num?)?.toDouble() ?? 0.0,
      tauxTva: (json['taux_tva'] as num?)?.toDouble() ?? 20.0,
      montantTtc: (json['montant_ttc'] as num?)?.toDouble() ?? 0.0,
      montantPaye: (json['montant_paye'] as num?)?.toDouble() ?? 0.0,
      montantRestant: (json['montant_restant'] as num?)?.toDouble() ?? 0.0,
      statut: json['statut'] ?? 'brouillon',
      createdById: json['created_by'] is String ? json['created_by'] : (json['created_by']?['id']),
      createdByUsername: json['created_by_username'],
      lignes: json['lignes'] != null
          ? (json['lignes'] as List).map((l) => LigneFactureTravaux.fromJson(l)).toList()
          : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (commandeId != null) 'commande': commandeId,
      if (devisId != null) 'devis': devisId,
      'client': clientId,
      if (chantierId != null) 'chantier': chantierId,
      'date_facture': dateFacture.toIso8601String().split('T')[0],
      if (dateEcheance != null) 'date_echeance': dateEcheance!.toIso8601String().split('T')[0],
      'type_travaux': typeTravaux,
      if (description != null) 'description': description,
      'montant_ht': montantHt,
      'taux_tva': tauxTva,
      'montant_paye': montantPaye,
      'statut': statut,
    };
  }

  String get statutLabel {
    switch (statut) {
      case 'brouillon':
        return 'Brouillon';
      case 'emise':
        return 'Émise';
      case 'payee':
        return 'Payée';
      case 'partiellement_payee':
        return 'Partiellement payée';
      case 'impayee':
        return 'Impayée';
      default:
        return statut;
    }
  }

  Color get statutColor {
    switch (statut) {
      case 'brouillon':
        return Colors.grey;
      case 'emise':
        return Colors.blue;
      case 'payee':
        return Colors.green;
      case 'partiellement_payee':
        return Colors.orange;
      case 'impayee':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

