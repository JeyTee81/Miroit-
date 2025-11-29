import 'package:flutter/material.dart';

class Mouvement {
  final String? id;
  final String articleId;
  final String? articleReference;
  final String typeMouvement; // 'entree', 'sortie', 'inventaire', 'ajustement'
  final double quantite;
  final double? prixUnitaireHt;
  final DateTime dateMouvement;
  final String? referenceDocument;
  final String? chantierId;
  final String? commandeFournisseurId;
  final String? createdById;
  final String? notes;
  final DateTime? createdAt;

  Mouvement({
    this.id,
    required this.articleId,
    this.articleReference,
    required this.typeMouvement,
    required this.quantite,
    this.prixUnitaireHt,
    required this.dateMouvement,
    this.referenceDocument,
    this.chantierId,
    this.commandeFournisseurId,
    this.createdById,
    this.notes,
    this.createdAt,
  });

  factory Mouvement.fromJson(Map<String, dynamic> json) {
    return Mouvement(
      id: json['id'],
      articleId: json['article'] is String ? json['article'] : (json['article']?['id'] ?? ''),
      articleReference: json['article_reference'],
      typeMouvement: json['type_mouvement'] ?? 'entree',
      quantite: (json['quantite'] as num?)?.toDouble() ?? 0.0,
      prixUnitaireHt: json['prix_unitaire_ht'] != null 
          ? (json['prix_unitaire_ht'] as num).toDouble() 
          : null,
      dateMouvement: json['date_mouvement'] != null 
          ? DateTime.parse(json['date_mouvement']) 
          : DateTime.now(),
      referenceDocument: json['reference_document'],
      chantierId: json['chantier'] is String ? json['chantier'] : (json['chantier']?['id']),
      commandeFournisseurId: json['commande_fournisseur'] is String 
          ? json['commande_fournisseur'] 
          : (json['commande_fournisseur']?['id']),
      createdById: json['created_by'] is String ? json['created_by'] : (json['created_by']?['id']),
      notes: json['notes'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'article': articleId,
      'type_mouvement': typeMouvement,
      'quantite': quantite,
      if (prixUnitaireHt != null) 'prix_unitaire_ht': prixUnitaireHt,
      'date_mouvement': dateMouvement.toIso8601String().split('T')[0],
      if (referenceDocument != null) 'reference_document': referenceDocument,
      if (chantierId != null) 'chantier': chantierId,
      if (commandeFournisseurId != null) 'commande_fournisseur': commandeFournisseurId,
      if (notes != null) 'notes': notes,
    };
  }

  static List<String> get typeMouvementOptions => [
    'entree',
    'sortie',
    'inventaire',
    'ajustement',
  ];

  String get typeMouvementLabel {
    switch (typeMouvement) {
      case 'entree':
        return 'Entrée';
      case 'sortie':
        return 'Sortie';
      case 'inventaire':
        return 'Inventaire';
      case 'ajustement':
        return 'Ajustement';
      default:
        return typeMouvement;
    }
  }

  Color get typeMouvementColor {
    switch (typeMouvement) {
      case 'entree':
        return Colors.green;
      case 'sortie':
        return Colors.red;
      case 'inventaire':
        return Colors.blue;
      case 'ajustement':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

