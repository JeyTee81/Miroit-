import 'package:flutter/material.dart';

class Facture {
  final String? id;
  final String numeroFacture;
  final String? devisId;
  final String clientId;
  final String? clientNom;
  final DateTime dateFacture;
  final DateTime dateEcheance;
  final double montantHt;
  final double montantTtc;
  final double montantPaye;
  final double? montantRestant;
  final String statut;
  final String? commercialId;
  final String? chantierId;
  final String? compteComptableId;
  final String? pdfPath;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Facture({
    this.id,
    required this.numeroFacture,
    this.devisId,
    required this.clientId,
    this.clientNom,
    required this.dateFacture,
    required this.dateEcheance,
    required this.montantHt,
    required this.montantTtc,
    this.montantPaye = 0.0,
    this.montantRestant,
    this.statut = 'brouillon',
    this.commercialId,
    this.chantierId,
    this.compteComptableId,
    this.pdfPath,
    this.createdAt,
    this.updatedAt,
  });

  factory Facture.fromJson(Map<String, dynamic> json) {
    // Fonction helper pour convertir une valeur en double, qu'elle soit String ou num
    double _toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }
    
    String? clientIdValue;
    if (json['client'] is String) {
      clientIdValue = json['client'];
    } else if (json['client'] is Map) {
      clientIdValue = json['client']?['id']?.toString();
    } else {
      clientIdValue = json['client']?.toString();
    }
    
    return Facture(
      id: json['id']?.toString(),
      numeroFacture: json['numero_facture']?.toString() ?? '',
      devisId: json['devis']?.toString(),
      clientId: clientIdValue ?? '',
      clientNom: json['client_nom']?.toString(),
      dateFacture: json['date_facture'] != null 
          ? DateTime.tryParse(json['date_facture'].toString()) ?? DateTime.now()
          : DateTime.now(),
      dateEcheance: json['date_echeance'] != null 
          ? DateTime.tryParse(json['date_echeance'].toString()) ?? DateTime.now()
          : DateTime.now(),
      montantHt: _toDouble(json['montant_ht']),
      montantTtc: _toDouble(json['montant_ttc']),
      montantPaye: _toDouble(json['montant_paye']),
      montantRestant: json['montant_restant'] != null 
          ? _toDouble(json['montant_restant'])
          : null,
      statut: json['statut']?.toString() ?? 'brouillon',
      commercialId: json['commercial']?.toString(),
      chantierId: json['chantier']?.toString(),
      compteComptableId: json['compte_comptable']?.toString(),
      pdfPath: json['pdf_path']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (numeroFacture.isNotEmpty) 'numero_facture': numeroFacture,
      if (devisId != null) 'devis': devisId,
      'client': clientId,
      'date_facture': dateFacture.toIso8601String().split('T')[0],
      'date_echeance': dateEcheance.toIso8601String().split('T')[0],
      'montant_ht': montantHt,
      'montant_ttc': montantTtc,
      'montant_paye': montantPaye,
      'statut': statut,
      if (commercialId != null) 'commercial': commercialId,
      if (chantierId != null) 'chantier': chantierId,
      if (compteComptableId != null) 'compte_comptable': compteComptableId,
    };
  }

  static List<String> get statutOptions => [
    'brouillon',
    'emise',
    'payee',
    'partielle',
    'impayee',
  ];

  String get statutLabel {
    switch (statut) {
      case 'brouillon':
        return 'Brouillon';
      case 'emise':
        return 'Emise';
      case 'payee':
        return 'Payée';
      case 'partielle':
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
      case 'partielle':
        return Colors.orange;
      case 'impayee':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

