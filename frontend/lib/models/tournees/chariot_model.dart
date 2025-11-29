class Chariot {
  final String? id;
  final String numero;
  final String type;
  final double? capacite;
  final bool actif;
  final DateTime? createdAt;

  Chariot({
    this.id,
    required this.numero,
    required this.type,
    this.capacite,
    this.actif = true,
    this.createdAt,
  });

  factory Chariot.fromJson(Map<String, dynamic> json) {
    return Chariot(
      id: json['id'],
      numero: json['numero'] ?? '',
      type: json['type'] ?? '',
      capacite: json['capacite'] != null
          ? (json['capacite'] is num
              ? (json['capacite'] as num).toDouble()
              : double.tryParse(json['capacite'].toString()))
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
      'numero': numero,
      'type': type,
      if (capacite != null) 'capacite': capacite,
      'actif': actif,
    };
  }
}

