/// Fonction utilitaire pour convertir une valeur JSON en double
/// Gère les cas où la valeur peut être un num ou une String
double parseDouble(dynamic value, {double defaultValue = 0.0}) {
  if (value == null) return defaultValue;
  if (value is num) return value.toDouble();
  if (value is String) {
    return double.tryParse(value) ?? defaultValue;
  }
  return defaultValue;
}

/// Fonction utilitaire pour convertir une valeur JSON en double nullable
double? parseDoubleNullable(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) {
    return double.tryParse(value);
  }
  return null;
}





