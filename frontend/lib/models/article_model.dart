class Article {
  final String? id;
  final String reference;
  final String designation;
  final String? categorieId;
  final String? categorieNom;
  final String uniteMesure;
  final double prixAchatHt;
  final double prixVenteHt;
  final double tauxTva;
  final double stockMinimum;
  final double stockActuel;
  final bool actif;

  Article({
    this.id,
    required this.reference,
    required this.designation,
    this.categorieId,
    this.categorieNom,
    required this.uniteMesure,
    required this.prixAchatHt,
    required this.prixVenteHt,
    this.tauxTva = 20.0,
    this.stockMinimum = 0.0,
    this.stockActuel = 0.0,
    this.actif = true,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      reference: json['reference'],
      designation: json['designation'],
      categorieId: json['categorie'],
      categorieNom: json['categorie_nom'],
      uniteMesure: json['unite_mesure'] ?? 'unite',
      prixAchatHt: (json['prix_achat_ht'] as num).toDouble(),
      prixVenteHt: (json['prix_vente_ht'] as num).toDouble(),
      tauxTva: (json['taux_tva'] as num?)?.toDouble() ?? 20.0,
      stockMinimum: (json['stock_minimum'] as num?)?.toDouble() ?? 0.0,
      stockActuel: (json['stock_actuel'] as num?)?.toDouble() ?? 0.0,
      actif: json['actif'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'reference': reference,
      'designation': designation,
      if (categorieId != null) 'categorie': categorieId,
      'unite_mesure': uniteMesure,
      'prix_achat_ht': prixAchatHt,
      'prix_vente_ht': prixVenteHt,
      'taux_tva': tauxTva,
      'stock_minimum': stockMinimum,
      'stock_actuel': stockActuel,
      'actif': actif,
    };
  }

  bool get isStockFaible => stockActuel <= stockMinimum && stockMinimum > 0;
}






