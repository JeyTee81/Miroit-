class SuiviCA {
  final String? id;
  final DateTime periodeDebut;
  final DateTime periodeFin;
  final String familleArticle;
  final double caHt;
  final double caTtc;
  final int nombreDevis;
  final int nombreFactures;
  final int nombreClients;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SuiviCA({
    this.id,
    required this.periodeDebut,
    required this.periodeFin,
    required this.familleArticle,
    required this.caHt,
    required this.caTtc,
    this.nombreDevis = 0,
    this.nombreFactures = 0,
    this.nombreClients = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory SuiviCA.fromJson(Map<String, dynamic> json) {
    return SuiviCA(
      id: json['id'],
      periodeDebut: json['periode_debut'] != null
          ? DateTime.parse(json['periode_debut'])
          : DateTime.now(),
      periodeFin: json['periode_fin'] != null
          ? DateTime.parse(json['periode_fin'])
          : DateTime.now(),
      familleArticle: json['famille_article'] ?? '',
      caHt: json['ca_ht'] != null
          ? (json['ca_ht'] is num
              ? (json['ca_ht'] as num).toDouble()
              : double.tryParse(json['ca_ht'].toString()) ?? 0.0)
          : 0.0,
      caTtc: json['ca_ttc'] != null
          ? (json['ca_ttc'] is num
              ? (json['ca_ttc'] as num).toDouble()
              : double.tryParse(json['ca_ttc'].toString()) ?? 0.0)
          : 0.0,
      nombreDevis: json['nombre_devis'] ?? 0,
      nombreFactures: json['nombre_factures'] ?? 0,
      nombreClients: json['nombre_clients'] ?? 0,
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
      'periode_debut': periodeDebut.toIso8601String().split('T')[0],
      'periode_fin': periodeFin.toIso8601String().split('T')[0],
      'famille_article': familleArticle,
      'ca_ht': caHt,
      'ca_ttc': caTtc,
      'nombre_devis': nombreDevis,
      'nombre_factures': nombreFactures,
      'nombre_clients': nombreClients,
    };
  }
}




