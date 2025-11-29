class RegionVentNeige {
  final String? id;
  final String codeRegion;
  final String nom;
  final double pressionVentReference; // en Pa
  final double chargeNeigeReference; // en Pa
  final double? latitudeMin;
  final double? latitudeMax;
  final double? longitudeMin;
  final double? longitudeMax;
  final String? description;
  final bool actif;

  RegionVentNeige({
    this.id,
    required this.codeRegion,
    required this.nom,
    required this.pressionVentReference,
    required this.chargeNeigeReference,
    this.latitudeMin,
    this.latitudeMax,
    this.longitudeMin,
    this.longitudeMax,
    this.description,
    this.actif = true,
  });

  factory RegionVentNeige.fromJson(Map<String, dynamic> json) {
    return RegionVentNeige(
      id: json['id'],
      codeRegion: json['code_region'] ?? '',
      nom: json['nom'] ?? '',
      pressionVentReference: json['pression_vent_reference'] != null
          ? (json['pression_vent_reference'] is num
              ? (json['pression_vent_reference'] as num).toDouble()
              : double.tryParse(json['pression_vent_reference'].toString()) ?? 0.0)
          : 0.0,
      chargeNeigeReference: json['charge_neige_reference'] != null
          ? (json['charge_neige_reference'] is num
              ? (json['charge_neige_reference'] as num).toDouble()
              : double.tryParse(json['charge_neige_reference'].toString()) ?? 0.0)
          : 0.0,
      latitudeMin: json['latitude_min'] != null
          ? (json['latitude_min'] is num
              ? (json['latitude_min'] as num).toDouble()
              : double.tryParse(json['latitude_min'].toString()))
          : null,
      latitudeMax: json['latitude_max'] != null
          ? (json['latitude_max'] is num
              ? (json['latitude_max'] as num).toDouble()
              : double.tryParse(json['latitude_max'].toString()))
          : null,
      longitudeMin: json['longitude_min'] != null
          ? (json['longitude_min'] is num
              ? (json['longitude_min'] as num).toDouble()
              : double.tryParse(json['longitude_min'].toString()))
          : null,
      longitudeMax: json['longitude_max'] != null
          ? (json['longitude_max'] is num
              ? (json['longitude_max'] as num).toDouble()
              : double.tryParse(json['longitude_max'].toString()))
          : null,
      description: json['description'],
      actif: json['actif'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'code_region': codeRegion,
      'nom': nom,
      'pression_vent_reference': pressionVentReference,
      'charge_neige_reference': chargeNeigeReference,
      if (latitudeMin != null) 'latitude_min': latitudeMin,
      if (latitudeMax != null) 'latitude_max': latitudeMax,
      if (longitudeMin != null) 'longitude_min': longitudeMin,
      if (longitudeMax != null) 'longitude_max': longitudeMax,
      if (description != null) 'description': description,
      'actif': actif,
    };
  }
}




