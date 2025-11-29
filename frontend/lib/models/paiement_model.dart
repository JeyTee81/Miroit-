import 'package:flutter/material.dart';

class Paiement {
  final String? id;
  final String factureId;
  final double montant;
  final DateTime datePaiement;
  final String modePaiement;
  final String? numeroPiece;
  final String? banqueId;
  final DateTime? createdAt;

  Paiement({
    this.id,
    required this.factureId,
    required this.montant,
    required this.datePaiement,
    required this.modePaiement,
    this.numeroPiece,
    this.banqueId,
    this.createdAt,
  });

  factory Paiement.fromJson(Map<String, dynamic> json) {
    // Fonction helper pour convertir une valeur en double, qu'elle soit String ou num
    double _toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }
    
    String? factureIdValue;
    if (json['facture'] is String) {
      factureIdValue = json['facture'];
    } else if (json['facture'] is Map) {
      factureIdValue = json['facture']?['id']?.toString();
    } else {
      factureIdValue = json['facture']?.toString();
    }
    
    return Paiement(
      id: json['id']?.toString(),
      factureId: factureIdValue ?? '',
      montant: _toDouble(json['montant']),
      datePaiement: json['date_paiement'] != null 
          ? DateTime.tryParse(json['date_paiement'].toString()) ?? DateTime.now()
          : DateTime.now(),
      modePaiement: json['mode_paiement']?.toString() ?? 'virement',
      numeroPiece: json['numero_piece']?.toString(),
      banqueId: json['banque']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'facture': factureId,
      'montant': montant,
      'date_paiement': datePaiement.toIso8601String().split('T')[0],
      'mode_paiement': modePaiement,
      if (numeroPiece != null) 'numero_piece': numeroPiece,
      if (banqueId != null) 'banque': banqueId,
    };
  }

  static List<String> get modePaiementOptions => [
    'especes',
    'cheque',
    'virement',
    'carte',
    'traite',
  ];

  String get modePaiementLabel {
    switch (modePaiement) {
      case 'especes':
        return 'Espèces';
      case 'cheque':
        return 'Chèque';
      case 'virement':
        return 'Virement';
      case 'carte':
        return 'Carte bancaire';
      case 'traite':
        return 'Traite';
      default:
        return modePaiement;
    }
  }

  IconData get modePaiementIcon {
    switch (modePaiement) {
      case 'especes':
        return Icons.money;
      case 'cheque':
        return Icons.description;
      case 'virement':
        return Icons.account_balance;
      case 'carte':
        return Icons.credit_card;
      case 'traite':
        return Icons.receipt;
      default:
        return Icons.payment;
    }
  }
}




