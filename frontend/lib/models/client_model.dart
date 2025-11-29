class Client {
  final String? id;
  final String type;
  final String? raisonSociale;
  final String nom;
  final String? prenom;
  final String? siret;
  final String adresse;
  final String codePostal;
  final String ville;
  final String pays;
  final String? telephone;
  final String? email;
  final String? zoneGeographique;
  final String? familleClient;
  final bool actif;
  final String? notes;

  Client({
    this.id,
    required this.type,
    this.raisonSociale,
    required this.nom,
    this.prenom,
    this.siret,
    required this.adresse,
    required this.codePostal,
    required this.ville,
    this.pays = 'France',
    this.telephone,
    this.email,
    this.zoneGeographique,
    this.familleClient,
    this.actif = true,
    this.notes,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id']?.toString(),
      type: json['type'] ?? '',
      raisonSociale: json['raison_sociale']?.toString(),
      nom: json['nom'] ?? '',
      prenom: json['prenom']?.toString(),
      siret: json['siret']?.toString(),
      adresse: json['adresse'] ?? '',
      codePostal: json['code_postal'] ?? '',
      ville: json['ville'] ?? '',
      pays: json['pays']?.toString() ?? 'France',
      telephone: json['telephone']?.toString(),
      email: json['email']?.toString(),
      zoneGeographique: json['zone_geographique']?.toString(),
      familleClient: json['famille_client']?.toString(),
      actif: json['actif'] ?? true,
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'type': type,
      if (raisonSociale != null) 'raison_sociale': raisonSociale,
      'nom': nom,
      if (prenom != null) 'prenom': prenom,
      if (siret != null) 'siret': siret,
      'adresse': adresse,
      'code_postal': codePostal,
      'ville': ville,
      'pays': pays,
      if (telephone != null) 'telephone': telephone,
      if (email != null) 'email': email,
      if (zoneGeographique != null) 'zone_geographique': zoneGeographique,
      if (familleClient != null) 'famille_client': familleClient,
      'actif': actif,
      if (notes != null) 'notes': notes,
    };
  }

  String get displayName {
    if (raisonSociale != null && raisonSociale!.isNotEmpty) {
      return raisonSociale!;
    }
    return '${prenom ?? ''} $nom'.trim();
  }
}





