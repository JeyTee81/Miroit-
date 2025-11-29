class Vehicule {
  final String? id;
  final String immatriculation;
  final String marque;
  final String modele;
  final String type; // 'utilitaire', 'camion', 'fourgon'
  final double? capaciteCharge;
  final bool actif;
  final DateTime? createdAt;

  Vehicule({
    this.id,
    required this.immatriculation,
    required this.marque,
    required this.modele,
    required this.type,
    this.capaciteCharge,
    this.actif = true,
    this.createdAt,
  });

  factory Vehicule.fromJson(Map<String, dynamic> json) {
    return Vehicule(
      id: json['id'],
      immatriculation: json['immatriculation'] ?? '',
      marque: json['marque'] ?? '',
      modele: json['modele'] ?? '',
      type: json['type'] ?? 'utilitaire',
      capaciteCharge: json['capacite_charge'] != null
          ? (json['capacite_charge'] is num
              ? (json['capacite_charge'] as num).toDouble()
              : double.tryParse(json['capacite_charge'].toString()))
          : null,
      actif: json['actif'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'immatriculation': immatriculation,
      'marque': marque,
      'modele': modele,
      'type': type,
      if (capaciteCharge != null) 'capacite_charge': capaciteCharge,
      'actif': actif,
    };
  }

  static List<String> get typeOptions => [
    'utilitaire',
    'camion',
    'fourgon',
  ];

  String get typeLabel {
    switch (type) {
      case 'utilitaire':
        return 'Utilitaire';
      case 'camion':
        return 'Camion';
      case 'fourgon':
        return 'Fourgon';
      default:
        return type;
    }
  }
}

