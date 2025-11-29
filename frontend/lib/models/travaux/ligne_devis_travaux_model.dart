class LigneDevisTravaux {
  final String? id;
  final String devisId;
  final String designation;
  final String? description;
  final double quantite;
  final String unite;
  final double prixUnitaireHt;
  final double montantHt;
  final double tauxTva;
  final double montantTtc;
  final Map<String, dynamic>? detailCalcul;
  final int ordre;
  final DateTime? createdAt;

  LigneDevisTravaux({
    this.id,
    required this.devisId,
    required this.designation,
    this.description,
    this.quantite = 1,
    this.unite = 'unite',
    required this.prixUnitaireHt,
    this.montantHt = 0,
    this.tauxTva = 20,
    this.montantTtc = 0,
    this.detailCalcul,
    this.ordre = 0,
    this.createdAt,
  });

  factory LigneDevisTravaux.fromJson(Map<String, dynamic> json) {
    return LigneDevisTravaux(
      id: json['id'],
      devisId: json['devis'] is String ? json['devis'] : (json['devis']?['id'] ?? ''),
      designation: json['designation'] ?? '',
      description: json['description'],
      quantite: (json['quantite'] as num?)?.toDouble() ?? 1.0,
      unite: json['unite'] ?? 'unite',
      prixUnitaireHt: (json['prix_unitaire_ht'] as num?)?.toDouble() ?? 0.0,
      montantHt: (json['montant_ht'] as num?)?.toDouble() ?? 0.0,
      tauxTva: (json['taux_tva'] as num?)?.toDouble() ?? 20.0,
      montantTtc: (json['montant_ttc'] as num?)?.toDouble() ?? 0.0,
      detailCalcul: json['detail_calcul'] is Map
          ? Map<String, dynamic>.from(json['detail_calcul'])
          : null,
      ordre: json['ordre'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'devis': devisId,
      'designation': designation,
      if (description != null) 'description': description,
      'quantite': quantite,
      'unite': unite,
      'prix_unitaire_ht': prixUnitaireHt,
      'taux_tva': tauxTva,
      if (detailCalcul != null) 'detail_calcul': detailCalcul,
      'ordre': ordre,
    };
  }

  static List<String> get uniteOptions => [
    'unite',
    'heure',
    'jour',
    'm2',
    'ml',
    'forfait',
  ];

  String get uniteLabel {
    switch (unite) {
      case 'unite':
        return 'Unité';
      case 'heure':
        return 'Heure';
      case 'jour':
        return 'Jour';
      case 'm2':
        return 'm²';
      case 'ml':
        return 'mètre linéaire';
      case 'forfait':
        return 'Forfait';
      default:
        return unite;
    }
  }
}




