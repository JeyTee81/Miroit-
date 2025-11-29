class Chauffeur {
  final String? id;
  final String userId;
  final String? userNom;
  final String? userPrenom;
  final String? userUsername;
  final String numeroPermis;
  final DateTime dateExpirationPermis;
  final bool actif;

  Chauffeur({
    this.id,
    required this.userId,
    this.userNom,
    this.userPrenom,
    this.userUsername,
    required this.numeroPermis,
    required this.dateExpirationPermis,
    this.actif = true,
  });

  factory Chauffeur.fromJson(Map<String, dynamic> json) {
    return Chauffeur(
      id: json['id'],
      userId: json['user'] is String
          ? json['user']
          : (json['user']?['id'] ?? ''),
      userNom: json['user_nom'],
      userPrenom: json['user_prenom'],
      userUsername: json['user_username'],
      numeroPermis: json['numero_permis'] ?? '',
      dateExpirationPermis: json['date_expiration_permis'] != null
          ? DateTime.parse(json['date_expiration_permis'])
          : DateTime.now(),
      actif: json['actif'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user': userId,
      'numero_permis': numeroPermis,
      'date_expiration_permis': dateExpirationPermis.toIso8601String().split('T')[0],
      'actif': actif,
    };
  }

  String get displayName {
    if (userNom != null && userPrenom != null) {
      return '$userPrenom $userNom';
    }
    return userUsername ?? 'Chauffeur inconnu';
  }
}




