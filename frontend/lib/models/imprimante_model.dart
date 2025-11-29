class Imprimante {
  final String? id;
  final String nom;
  final String typeImprimante;
  final String? nomSysteme;
  final String? adresseIp;
  final int port;
  final String protocole;
  final String? nomReseau;
  final String formatPapier;
  final String orientation;
  final bool actif;
  final bool imprimanteParDefaut;
  final String? description;
  final String? connectionString;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Imprimante({
    this.id,
    required this.nom,
    required this.typeImprimante,
    this.nomSysteme,
    this.adresseIp,
    this.port = 9100,
    this.protocole = 'raw',
    this.nomReseau,
    this.formatPapier = 'A4',
    this.orientation = 'portrait',
    this.actif = true,
    this.imprimanteParDefaut = false,
    this.description,
    this.connectionString,
    this.createdAt,
    this.updatedAt,
  });

  factory Imprimante.fromJson(Map<String, dynamic> json) {
    return Imprimante(
      id: json['id'],
      nom: json['nom'] ?? '',
      typeImprimante: json['type_imprimante'] ?? 'locale',
      nomSysteme: json['nom_systeme'],
      adresseIp: json['adresse_ip'],
      port: json['port'] ?? 9100,
      protocole: json['protocole'] ?? 'raw',
      nomReseau: json['nom_reseau'],
      formatPapier: json['format_papier'] ?? 'A4',
      orientation: json['orientation'] ?? 'portrait',
      actif: json['actif'] ?? true,
      imprimanteParDefaut: json['imprimante_par_defaut'] ?? false,
      description: json['description'],
      connectionString: json['connection_string'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nom': nom,
      'type_imprimante': typeImprimante,
      if (nomSysteme != null) 'nom_systeme': nomSysteme,
      if (adresseIp != null) 'adresse_ip': adresseIp,
      'port': port,
      'protocole': protocole,
      if (nomReseau != null) 'nom_reseau': nomReseau,
      'format_papier': formatPapier,
      'orientation': orientation,
      'actif': actif,
      'imprimante_par_defaut': imprimanteParDefaut,
      if (description != null) 'description': description,
    };
  }

  String get typeImprimanteLabel {
    switch (typeImprimante) {
      case 'locale':
        return 'Locale';
      case 'reseau':
        return 'Réseau';
      default:
        return typeImprimante;
    }
  }

  String get protocoleLabel {
    switch (protocole) {
      case 'raw':
        return 'RAW (Port 9100)';
      case 'lpr':
        return 'LPR/LPD (Port 515)';
      case 'ipp':
        return 'IPP (Port 631)';
      case 'http':
        return 'HTTP';
      default:
        return protocole;
    }
  }

  String get formatPapierLabel {
    return formatPapier;
  }

  String get orientationLabel {
    switch (orientation) {
      case 'portrait':
        return 'Portrait';
      case 'paysage':
        return 'Paysage';
      default:
        return orientation;
    }
  }
}




