class Categorie {
  final String? id;
  final String nom;
  final String? parentId;
  final String? description;

  Categorie({
    this.id,
    required this.nom,
    this.parentId,
    this.description,
  });

  factory Categorie.fromJson(Map<String, dynamic> json) {
    return Categorie(
      id: json['id'],
      nom: json['nom'],
      parentId: json['parent'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nom': nom,
      if (parentId != null) 'parent': parentId,
      if (description != null) 'description': description,
    };
  }
}






