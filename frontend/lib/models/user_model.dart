class User {
  final String? id;
  final String username;
  final String? email;
  final String? nom;
  final String? prenom;
  final String? role;
  final String? groupeId;
  final String? groupeNom;
  final bool? actif;
  final bool? isSuperuser;
  final List<String>? modulesAccessibles;
  final DateTime? lastLogin;

  User({
    this.id,
    required this.username,
    this.email,
    this.nom,
    this.prenom,
    this.role,
    this.groupeId,
    this.groupeNom,
    this.actif,
    this.isSuperuser,
    this.modulesAccessibles,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'],
      nom: json['nom'],
      prenom: json['prenom'],
      role: json['role'],
      groupeId: json['groupe_id'],
      groupeNom: json['groupe_nom'],
      actif: json['actif'],
      isSuperuser: json['is_superuser'] ?? false,
      modulesAccessibles: (json['modules_accessibles'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      lastLogin: json['last_login'] != null
          ? DateTime.tryParse(json['last_login'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'username': username,
      if (email != null) 'email': email,
      if (nom != null) 'nom': nom,
      if (prenom != null) 'prenom': prenom,
      if (role != null) 'role': role,
      if (groupeId != null) 'groupe': groupeId,
      if (actif != null) 'actif': actif,
    };
  }

  String get displayName {
    if (prenom != null && nom != null) {
      return '$prenom $nom';
    }
    return username;
  }
}



