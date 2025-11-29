import 'matiere_model.dart';

class Chute {
  final String? id;
  final String matiereId;
  final Matiere? matiereDetail;
  final String? debitId;
  final String? debitNumero;
  final double? largeur; // en mm
  final double? longueur; // en mm
  final double? epaisseur; // en mm
  final int quantite;
  final double? surface; // en mm²
  final String statut; // 'disponible', 'reservee', 'utilisee', 'jetee'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Chute({
    this.id,
    required this.matiereId,
    this.matiereDetail,
    this.debitId,
    this.debitNumero,
    this.largeur,
    this.longueur,
    this.epaisseur,
    this.quantite = 1,
    this.surface,
    this.statut = 'disponible',
    this.createdAt,
    this.updatedAt,
  });

  factory Chute.fromJson(Map<String, dynamic> json) {
    return Chute(
      id: json['id'],
      matiereId: json['matiere'] is String
          ? json['matiere']
          : (json['matiere']?['id'] ?? ''),
      matiereDetail: json['matiere_detail'] != null
          ? Matiere.fromJson(json['matiere_detail'])
          : null,
      debitId: json['debit'] is String
          ? json['debit']
          : (json['debit']?['id'] ?? null),
      debitNumero: json['debit_numero'],
      largeur: json['largeur'] != null
          ? (json['largeur'] is num
              ? (json['largeur'] as num).toDouble()
              : double.tryParse(json['largeur'].toString()))
          : null,
      longueur: json['longueur'] != null
          ? (json['longueur'] is num
              ? (json['longueur'] as num).toDouble()
              : double.tryParse(json['longueur'].toString()))
          : null,
      epaisseur: json['epaisseur'] != null
          ? (json['epaisseur'] is num
              ? (json['epaisseur'] as num).toDouble()
              : double.tryParse(json['epaisseur'].toString()))
          : null,
      quantite: json['quantite'] ?? 1,
      surface: json['surface'] != null
          ? (json['surface'] is num
              ? (json['surface'] as num).toDouble()
              : double.tryParse(json['surface'].toString()))
          : null,
      statut: json['statut'] ?? 'disponible',
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
      'matiere': matiereId,
      if (debitId != null) 'debit': debitId,
      if (largeur != null) 'largeur': largeur,
      if (longueur != null) 'longueur': longueur,
      if (epaisseur != null) 'epaisseur': epaisseur,
      'quantite': quantite,
      'statut': statut,
    };
  }

  String get statutLabel {
    switch (statut) {
      case 'disponible':
        return 'Disponible';
      case 'reservee':
        return 'Réservée';
      case 'utilisee':
        return 'Utilisée';
      case 'jetee':
        return 'Jetée';
      default:
        return statut;
    }
  }
}




