class CommandeTravaux {
  final String? id;
  final String numeroCommande;
  final String? devisId;
  final String? devisNumero;
  final String clientId;
  final String? clientNom;
  final String? chantierId;
  final String? chantierNom;
  final DateTime dateCommande;
  final DateTime? dateDebutPrevue;
  final DateTime? dateFinPrevue;
  final String typeTravaux;
  final String? description;
  final double montantHt;
  final double tauxTva;
  final double montantTtc;
  final String statut;
  final String? createdById;
  final String? createdByUsername;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CommandeTravaux({
    this.id,
    required this.numeroCommande,
    this.devisId,
    this.devisNumero,
    required this.clientId,
    this.clientNom,
    this.chantierId,
    this.chantierNom,
    required this.dateCommande,
    this.dateDebutPrevue,
    this.dateFinPrevue,
    required this.typeTravaux,
    this.description,
    this.montantHt = 0,
    this.tauxTva = 20,
    this.montantTtc = 0,
    this.statut = 'brouillon',
    this.createdById,
    this.createdByUsername,
    this.createdAt,
    this.updatedAt,
  });

  factory CommandeTravaux.fromJson(Map<String, dynamic> json) {
    return CommandeTravaux(
      id: json['id'],
      numeroCommande: json['numero_commande'] ?? '',
      devisId: json['devis'] is String ? json['devis'] : (json['devis']?['id']),
      devisNumero: json['devis_numero'],
      clientId: json['client'] is String ? json['client'] : (json['client']?['id'] ?? ''),
      clientNom: json['client_nom'],
      chantierId: json['chantier'] is String ? json['chantier'] : (json['chantier']?['id']),
      chantierNom: json['chantier_nom'],
      dateCommande: json['date_commande'] != null ? DateTime.parse(json['date_commande']) : DateTime.now(),
      dateDebutPrevue: json['date_debut_prevue'] != null ? DateTime.tryParse(json['date_debut_prevue']) : null,
      dateFinPrevue: json['date_fin_prevue'] != null ? DateTime.tryParse(json['date_fin_prevue']) : null,
      typeTravaux: json['type_travaux'] ?? '',
      description: json['description'],
      montantHt: (json['montant_ht'] as num?)?.toDouble() ?? 0.0,
      tauxTva: (json['taux_tva'] as num?)?.toDouble() ?? 20.0,
      montantTtc: (json['montant_ttc'] as num?)?.toDouble() ?? 0.0,
      statut: json['statut'] ?? 'brouillon',
      createdById: json['created_by'] is String ? json['created_by'] : (json['created_by']?['id']),
      createdByUsername: json['created_by_username'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (devisId != null) 'devis': devisId,
      'client': clientId,
      if (chantierId != null) 'chantier': chantierId,
      'date_commande': dateCommande.toIso8601String().split('T')[0],
      if (dateDebutPrevue != null) 'date_debut_prevue': dateDebutPrevue!.toIso8601String().split('T')[0],
      if (dateFinPrevue != null) 'date_fin_prevue': dateFinPrevue!.toIso8601String().split('T')[0],
      'type_travaux': typeTravaux,
      if (description != null) 'description': description,
      'montant_ht': montantHt,
      'taux_tva': tauxTva,
      'statut': statut,
    };
  }

  String get statutLabel {
    switch (statut) {
      case 'brouillon':
        return 'Brouillon';
      case 'confirmee':
        return 'Confirmée';
      case 'en_cours':
        return 'En cours';
      case 'terminee':
        return 'Terminée';
      case 'annulee':
        return 'Annulée';
      default:
        return statut;
    }
  }
}




