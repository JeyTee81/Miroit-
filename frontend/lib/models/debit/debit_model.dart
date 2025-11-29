class Debit {
  final String? id;
  final String lancementId;
  final String? lancementNumero;
  final String numeroDebit;
  final double largeurSource; // en mm
  final double longueurSource; // en mm
  final double? epaisseur; // en mm
  final List<Map<String, dynamic>> pieces; // Liste de pièces à découper
  final Map<String, dynamic>? resultatOptimisation;
  final List<Map<String, dynamic>> planCoupe; // Plan de coupe détaillé
  final double tauxUtilisation; // en %
  final int nombrePlaquesNecessaires;
  final String sensCoupe; // 'transversal', 'longitudinal'
  final List<Map<String, dynamic>> chutesReutilisables;
  final String? pdfPath;
  final String? fichierCncPath;
  final String? fichierAsciiPath;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Debit({
    this.id,
    required this.lancementId,
    this.lancementNumero,
    required this.numeroDebit,
    required this.largeurSource,
    required this.longueurSource,
    this.epaisseur,
    this.pieces = const [],
    this.resultatOptimisation,
    this.planCoupe = const [],
    this.tauxUtilisation = 0,
    this.nombrePlaquesNecessaires = 1,
    this.sensCoupe = 'transversal',
    this.chutesReutilisables = const [],
    this.pdfPath,
    this.fichierCncPath,
    this.fichierAsciiPath,
    this.createdAt,
    this.updatedAt,
  });

  factory Debit.fromJson(Map<String, dynamic> json) {
    return Debit(
      id: json['id'],
      lancementId: json['lancement'] is String
          ? json['lancement']
          : (json['lancement']?['id'] ?? ''),
      lancementNumero: json['lancement_numero'],
      numeroDebit: json['numero_debit'] ?? '',
      largeurSource: json['largeur_source'] != null
          ? (json['largeur_source'] is num
              ? (json['largeur_source'] as num).toDouble()
              : double.tryParse(json['largeur_source'].toString()) ?? 0.0)
          : 0.0,
      longueurSource: json['longueur_source'] != null
          ? (json['longueur_source'] is num
              ? (json['longueur_source'] as num).toDouble()
              : double.tryParse(json['longueur_source'].toString()) ?? 0.0)
          : 0.0,
      epaisseur: json['epaisseur'] != null
          ? (json['epaisseur'] is num
              ? (json['epaisseur'] as num).toDouble()
              : double.tryParse(json['epaisseur'].toString()))
          : null,
      pieces: json['pieces'] != null
          ? List<Map<String, dynamic>>.from(json['pieces'])
          : [],
      resultatOptimisation: json['resultat_optimisation'] != null
          ? Map<String, dynamic>.from(json['resultat_optimisation'])
          : null,
      planCoupe: json['plan_coupe'] != null
          ? List<Map<String, dynamic>>.from(json['plan_coupe'])
          : [],
      tauxUtilisation: json['taux_utilisation'] != null
          ? (json['taux_utilisation'] is num
              ? (json['taux_utilisation'] as num).toDouble()
              : double.tryParse(json['taux_utilisation'].toString()) ?? 0.0)
          : 0.0,
      nombrePlaquesNecessaires: json['nombre_plaques_necessaires'] ?? 1,
      sensCoupe: json['sens_coupe'] ?? 'transversal',
      chutesReutilisables: json['chutes_reutilisables'] != null
          ? List<Map<String, dynamic>>.from(json['chutes_reutilisables'])
          : [],
      pdfPath: json['pdf_path'],
      fichierCncPath: json['fichier_cnc_path'],
      fichierAsciiPath: json['fichier_ascii_path'],
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
      'lancement': lancementId,
      'numero_debit': numeroDebit,
      'largeur_source': largeurSource,
      'longueur_source': longueurSource,
      if (epaisseur != null) 'epaisseur': epaisseur,
      'pieces': pieces,
      'sens_coupe': sensCoupe,
    };
  }

  String get sensCoupeLabel {
    switch (sensCoupe) {
      case 'transversal':
        return 'Transversal';
      case 'longitudinal':
        return 'Longitudinal';
      default:
        return sensCoupe;
    }
  }
}




