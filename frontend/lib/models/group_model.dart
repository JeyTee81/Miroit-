class Group {
  final String id;
  final String nom;
  final String? description;
  final bool accesCommerciale;
  final bool accesMenuiserie;
  final bool accesVitrages;
  final bool accesOptimisation;
  final bool accesStock;
  final bool accesTravaux;
  final bool accesPlanning;
  final bool accesTournees;
  final bool accesCrm;
  final bool accesInertie;
  final bool accesParametres;
  final bool accesLogs;
  final bool actif;
  final List<String> modulesAccessibles;
  final int nombreUtilisateurs;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Group({
    required this.id,
    required this.nom,
    this.description,
    required this.accesCommerciale,
    required this.accesMenuiserie,
    required this.accesVitrages,
    required this.accesOptimisation,
    required this.accesStock,
    required this.accesTravaux,
    required this.accesPlanning,
    required this.accesTournees,
    required this.accesCrm,
    required this.accesInertie,
    required this.accesParametres,
    required this.accesLogs,
    required this.actif,
    required this.modulesAccessibles,
    required this.nombreUtilisateurs,
    this.createdAt,
    this.updatedAt,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id']?.toString() ?? '',
      nom: json['nom']?.toString() ?? '',
      description: json['description']?.toString(),
      accesCommerciale: json['acces_commerciale'] ?? false,
      accesMenuiserie: json['acces_menuiserie'] ?? false,
      accesVitrages: json['acces_vitrages'] ?? false,
      accesOptimisation: json['acces_optimisation'] ?? false,
      accesStock: json['acces_stock'] ?? false,
      accesTravaux: json['acces_travaux'] ?? false,
      accesPlanning: json['acces_planning'] ?? false,
      accesTournees: json['acces_tournees'] ?? false,
      accesCrm: json['acces_crm'] ?? false,
      accesInertie: json['acces_inertie'] ?? false,
      accesParametres: json['acces_parametres'] ?? false,
      accesLogs: json['acces_logs'] ?? false,
      actif: json['actif'] ?? true,
      modulesAccessibles: (json['modules_accessibles'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      nombreUtilisateurs: json['nombre_utilisateurs'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'nom': nom,
      if (description != null) 'description': description,
      'acces_commerciale': accesCommerciale,
      'acces_menuiserie': accesMenuiserie,
      'acces_vitrages': accesVitrages,
      'acces_optimisation': accesOptimisation,
      'acces_stock': accesStock,
      'acces_travaux': accesTravaux,
      'acces_planning': accesPlanning,
      'acces_tournees': accesTournees,
      'acces_crm': accesCrm,
      'acces_inertie': accesInertie,
      'acces_parametres': accesParametres,
      'acces_logs': accesLogs,
      'actif': actif,
    };
  }
}

