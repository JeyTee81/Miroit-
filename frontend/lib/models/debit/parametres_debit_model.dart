class ParametresDebit {
  final String? id;
  final String nom;
  final double reequerrage; // en mm
  final double epaisseurLame; // en mm
  final double dimensionChuteJetee; // en mm
  final double dimensionChuteFacturee; // en mm
  final String sensCoupeParDefaut; // 'transversal', 'longitudinal'
  final bool actif;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ParametresDebit({
    this.id,
    required this.nom,
    this.reequerrage = 0,
    this.epaisseurLame = 3,
    this.dimensionChuteJetee = 50,
    this.dimensionChuteFacturee = 100,
    this.sensCoupeParDefaut = 'transversal',
    this.actif = true,
    this.createdAt,
    this.updatedAt,
  });

  factory ParametresDebit.fromJson(Map<String, dynamic> json) {
    return ParametresDebit(
      id: json['id'],
      nom: json['nom'] ?? '',
      reequerrage: json['reequerrage'] != null
          ? (json['reequerrage'] is num
              ? (json['reequerrage'] as num).toDouble()
              : double.tryParse(json['reequerrage'].toString()) ?? 0.0)
          : 0.0,
      epaisseurLame: json['epaisseur_lame'] != null
          ? (json['epaisseur_lame'] is num
              ? (json['epaisseur_lame'] as num).toDouble()
              : double.tryParse(json['epaisseur_lame'].toString()) ?? 3.0)
          : 3.0,
      dimensionChuteJetee: json['dimension_chute_jetee'] != null
          ? (json['dimension_chute_jetee'] is num
              ? (json['dimension_chute_jetee'] as num).toDouble()
              : double.tryParse(json['dimension_chute_jetee'].toString()) ?? 50.0)
          : 50.0,
      dimensionChuteFacturee: json['dimension_chute_facturee'] != null
          ? (json['dimension_chute_facturee'] is num
              ? (json['dimension_chute_facturee'] as num).toDouble()
              : double.tryParse(json['dimension_chute_facturee'].toString()) ?? 100.0)
          : 100.0,
      sensCoupeParDefaut: json['sens_coupe_par_defaut'] ?? 'transversal',
      actif: json['actif'] ?? true,
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
      'nom': nom,
      'reequerrage': reequerrage,
      'epaisseur_lame': epaisseurLame,
      'dimension_chute_jetee': dimensionChuteJetee,
      'dimension_chute_facturee': dimensionChuteFacturee,
      'sens_coupe_par_defaut': sensCoupeParDefaut,
      'actif': actif,
    };
  }

  String get sensCoupeLabel {
    switch (sensCoupeParDefaut) {
      case 'transversal':
        return 'Transversal';
      case 'longitudinal':
        return 'Longitudinal';
      default:
        return sensCoupeParDefaut;
    }
  }
}




