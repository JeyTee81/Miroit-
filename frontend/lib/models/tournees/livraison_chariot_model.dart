import 'chariot_model.dart';

class LivraisonChariot {
  final String? id;
  final String livraisonId;
  final String chariotId;
  final Chariot? chariotDetail;
  final int quantite;

  LivraisonChariot({
    this.id,
    required this.livraisonId,
    required this.chariotId,
    this.chariotDetail,
    this.quantite = 1,
  });

  factory LivraisonChariot.fromJson(Map<String, dynamic> json) {
    return LivraisonChariot(
      id: json['id'],
      livraisonId: json['livraison'] is String
          ? json['livraison']
          : (json['livraison']?['id'] ?? ''),
      chariotId: json['chariot'] is String
          ? json['chariot']
          : (json['chariot']?['id'] ?? ''),
      chariotDetail: json['chariot_detail'] != null
          ? Chariot.fromJson(json['chariot_detail'])
          : null,
      quantite: json['quantite'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'livraison': livraisonId,
      'chariot': chariotId,
      'quantite': quantite,
    };
  }
}




