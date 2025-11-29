import 'matiere_model.dart';

class StockMatiere {
  final String? id;
  final String matiereId;
  final Matiere? matiereDetail;
  final double largeur; // en mm
  final double longueur; // en mm
  final double? epaisseur; // en mm
  final int quantite;
  final int quantiteReservee;
  final int quantiteDisponible;
  final double? prixUnitaire;
  final String? emplacement;
  final DateTime? dateReception;
  final DateTime? datePeremption;
  final String statut; // 'disponible', 'reserve', 'epuise'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StockMatiere({
    this.id,
    required this.matiereId,
    this.matiereDetail,
    required this.largeur,
    required this.longueur,
    this.epaisseur,
    this.quantite = 1,
    this.quantiteReservee = 0,
    this.quantiteDisponible = 0,
    this.prixUnitaire,
    this.emplacement,
    this.dateReception,
    this.datePeremption,
    this.statut = 'disponible',
    this.createdAt,
    this.updatedAt,
  });

  factory StockMatiere.fromJson(Map<String, dynamic> json) {
    return StockMatiere(
      id: json['id'],
      matiereId: json['matiere'] is String
          ? json['matiere']
          : (json['matiere']?['id'] ?? ''),
      matiereDetail: json['matiere_detail'] != null
          ? Matiere.fromJson(json['matiere_detail'])
          : null,
      largeur: json['largeur'] != null
          ? (json['largeur'] is num
              ? (json['largeur'] as num).toDouble()
              : double.tryParse(json['largeur'].toString()) ?? 0.0)
          : 0.0,
      longueur: json['longueur'] != null
          ? (json['longueur'] is num
              ? (json['longueur'] as num).toDouble()
              : double.tryParse(json['longueur'].toString()) ?? 0.0)
          : 0.0,
      epaisseur: json['epaisseur'] != null
          ? (json['epaisseur'] is num
              ? (json['epaisseur'] as num).toDouble()
              : double.tryParse(json['epaisseur'].toString()))
          : null,
      quantite: json['quantite'] ?? 1,
      quantiteReservee: json['quantite_reservee'] ?? 0,
      quantiteDisponible: json['quantite_disponible'] ?? 0,
      prixUnitaire: json['prix_unitaire'] != null
          ? (json['prix_unitaire'] is num
              ? (json['prix_unitaire'] as num).toDouble()
              : double.tryParse(json['prix_unitaire'].toString()))
          : null,
      emplacement: json['emplacement'],
      dateReception: json['date_reception'] != null
          ? DateTime.tryParse(json['date_reception'])
          : null,
      datePeremption: json['date_peremption'] != null
          ? DateTime.tryParse(json['date_peremption'])
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
      'largeur': largeur,
      'longueur': longueur,
      if (epaisseur != null) 'epaisseur': epaisseur,
      'quantite': quantite,
      'quantite_reservee': quantiteReservee,
      if (prixUnitaire != null) 'prix_unitaire': prixUnitaire,
      if (emplacement != null) 'emplacement': emplacement,
      if (dateReception != null) 'date_reception': dateReception!.toIso8601String().split('T')[0],
      if (datePeremption != null) 'date_peremption': datePeremption!.toIso8601String().split('T')[0],
      'statut': statut,
    };
  }

  String get statutLabel {
    switch (statut) {
      case 'disponible':
        return 'Disponible';
      case 'reserve':
        return 'Réservé';
      case 'epuise':
        return 'Épuisé';
      default:
        return statut;
    }
  }
}




