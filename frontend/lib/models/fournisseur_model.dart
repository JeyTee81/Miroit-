class Fournisseur {
  final String? id;
  final String raisonSociale;
  final String? siret;
  final String adresse;
  final String codePostal;
  final String ville;
  final String pays;
  final String? telephone;
  final String? email;
  final String? contact;
  final bool actif;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Fournisseur({
    this.id,
    required this.raisonSociale,
    this.siret,
    required this.adresse,
    required this.codePostal,
    required this.ville,
    this.pays = 'France',
    this.telephone,
    this.email,
    this.contact,
    this.actif = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Fournisseur.fromJson(Map<String, dynamic> json) {
    return Fournisseur(
      id: json['id'],
      raisonSociale: json['raison_sociale'] ?? '',
      siret: json['siret'],
      adresse: json['adresse'] ?? '',
      codePostal: json['code_postal'] ?? '',
      ville: json['ville'] ?? '',
      pays: json['pays'] ?? 'France',
      telephone: json['telephone'],
      email: json['email'],
      contact: json['contact'],
      actif: json['actif'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'raison_sociale': raisonSociale,
      if (siret != null) 'siret': siret,
      'adresse': adresse,
      'code_postal': codePostal,
      'ville': ville,
      'pays': pays,
      if (telephone != null) 'telephone': telephone,
      if (email != null) 'email': email,
      if (contact != null) 'contact': contact,
      'actif': actif,
    };
  }

  String get adresseComplete => '$adresse, $codePostal $ville, $pays';
}




