import 'client_model.dart';

class LigneDevis {
  final String? id;
  final String? articleId;
  final String designation;
  final double quantite;
  final double prixUnitaireHt;
  final double tauxTva;
  final double remisePourcentage;
  final int ordre;

  LigneDevis({
    this.id,
    this.articleId,
    required this.designation,
    required this.quantite,
    required this.prixUnitaireHt,
    this.tauxTva = 20.0,
    this.remisePourcentage = 0.0,
    this.ordre = 0,
  });

  factory LigneDevis.fromJson(Map<String, dynamic> json) {
    // Fonction helper pour convertir une valeur en double, qu'elle soit String ou num
    double _toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }
    
    return LigneDevis(
      id: json['id']?.toString(),
      articleId: json['article']?.toString(),
      designation: json['designation']?.toString() ?? '',
      quantite: _toDouble(json['quantite']),
      prixUnitaireHt: _toDouble(json['prix_unitaire_ht']),
      tauxTva: _toDouble(json['taux_tva']),
      remisePourcentage: _toDouble(json['remise_pourcentage']),
      ordre: json['ordre'] is int ? json['ordre'] : (json['ordre'] is String ? int.tryParse(json['ordre']) ?? 0 : 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (articleId != null) 'article': articleId,
      'designation': designation,
      'quantite': quantite,
      'prix_unitaire_ht': prixUnitaireHt,
      'taux_tva': tauxTva,
      'remise_pourcentage': remisePourcentage,
      'ordre': ordre,
    };
  }

  double get montantHtAvantRemise => quantite * prixUnitaireHt;
  
  double get montantRemise => montantHtAvantRemise * (remisePourcentage / 100);
  
  double get montantHt => montantHtAvantRemise - montantRemise;
  
  double get montantTva => montantHt * (tauxTva / 100);
  
  double get montantTtc => montantHt + montantTva;
}

class Devis {
  final String? id;
  final String? numeroDevis;
  final String? clientId;
  final Client? client;
  final DateTime? dateCreation;
  final DateTime dateValidite;
  final double montantHt;
  final double montantTtc;
  final String statut;
  final String? commercialId;
  final String? chantierId;
  final double remisePourcentage;
  final String? notes;
  final List<LigneDevis>? lignes;

  Devis({
    this.id,
    this.numeroDevis,
    this.clientId,
    this.client,
    this.dateCreation,
    required this.dateValidite,
    this.montantHt = 0.0,
    this.montantTtc = 0.0,
    this.statut = 'brouillon',
    this.commercialId,
    this.chantierId,
    this.remisePourcentage = 0.0,
    this.notes,
    this.lignes,
  });

  factory Devis.fromJson(Map<String, dynamic> json) {
    // Fonction helper pour convertir une valeur en double, qu'elle soit String ou num
    double _toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }
    
    return Devis(
      id: json['id']?.toString(),
      numeroDevis: json['numero_devis']?.toString(),
      clientId: json['client']?.toString(),
      client: json['client_nom'] != null
          ? Client.fromJson({'nom': json['client_nom']})
          : null,
      dateCreation: json['date_creation'] != null
          ? DateTime.tryParse(json['date_creation'].toString())
          : null,
      dateValidite: json['date_validite'] != null
          ? DateTime.tryParse(json['date_validite'].toString()) ?? DateTime.now()
          : DateTime.now(),
      montantHt: _toDouble(json['montant_ht']),
      montantTtc: _toDouble(json['montant_ttc']),
      statut: json['statut']?.toString() ?? 'brouillon',
      commercialId: json['commercial']?.toString(),
      chantierId: json['chantier']?.toString(),
      remisePourcentage: _toDouble(json['remise_pourcentage']),
      notes: json['notes']?.toString(),
      lignes: json['lignes'] != null
          ? (json['lignes'] as List)
              .map((l) => LigneDevis.fromJson(l))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (numeroDevis != null) 'numero_devis': numeroDevis,
      if (clientId != null) 'client': clientId,
      'date_validite': dateValidite.toIso8601String().split('T')[0],
      'montant_ht': montantHt,
      'montant_ttc': montantTtc,
      'statut': statut,
      if (commercialId != null) 'commercial': commercialId,
      if (chantierId != null) 'chantier': chantierId,
      'remise_pourcentage': remisePourcentage,
      if (notes != null) 'notes': notes,
      if (lignes != null) 'lignes': lignes!.map((l) => l.toJson()).toList(),
    };
  }

  String get statutLibelle {
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
}





