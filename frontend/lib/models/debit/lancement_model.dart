import 'matiere_model.dart';
import 'parametres_debit_model.dart';
import 'debit_model.dart';

class Lancement {
  final String? id;
  final String affaireId;
  final String? affaireNumero;
  final String numeroLancement;
  final DateTime dateLancement;
  final String matiereId;
  final Matiere? matiereDetail;
  final String? parametresId;
  final ParametresDebit? parametresDetail;
  final String? description;
  final String statut; // 'brouillon', 'optimise', 'valide', 'envoye_cnc'
  final List<Debit>? debits;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Lancement({
    this.id,
    required this.affaireId,
    this.affaireNumero,
    required this.numeroLancement,
    required this.dateLancement,
    required this.matiereId,
    this.matiereDetail,
    this.parametresId,
    this.parametresDetail,
    this.description,
    this.statut = 'brouillon',
    this.debits,
    this.createdAt,
    this.updatedAt,
  });

  factory Lancement.fromJson(Map<String, dynamic> json) {
    return Lancement(
      id: json['id'],
      affaireId: json['affaire'] is String
          ? json['affaire']
          : (json['affaire']?['id'] ?? ''),
      affaireNumero: json['affaire_numero'],
      numeroLancement: json['numero_lancement'] ?? '',
      dateLancement: json['date_lancement'] != null
          ? DateTime.parse(json['date_lancement'])
          : DateTime.now(),
      matiereId: json['matiere'] is String
          ? json['matiere']
          : (json['matiere']?['id'] ?? ''),
      matiereDetail: json['matiere_detail'] != null
          ? Matiere.fromJson(json['matiere_detail'])
          : null,
      parametresId: json['parametres'] is String
          ? json['parametres']
          : (json['parametres']?['id'] ?? null),
      parametresDetail: json['parametres_detail'] != null
          ? ParametresDebit.fromJson(json['parametres_detail'])
          : null,
      description: json['description'],
      statut: json['statut'] ?? 'brouillon',
      debits: json['debits'] != null
          ? (json['debits'] as List)
              .map((d) => Debit.fromJson(d))
              .toList()
          : null,
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
      'affaire': affaireId,
      'numero_lancement': numeroLancement,
      'matiere': matiereId,
      if (parametresId != null) 'parametres': parametresId,
      if (description != null) 'description': description,
      'statut': statut,
    };
  }

  String get statutLabel {
    switch (statut) {
      case 'brouillon':
        return 'Brouillon';
      case 'optimise':
        return 'Optimisé';
      case 'valide':
        return 'Validé';
      case 'envoye_cnc':
        return 'Envoyé CNC';
      default:
        return statut;
    }
  }
}




