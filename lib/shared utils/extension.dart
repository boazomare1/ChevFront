import 'dart:math' show atan2, cos, pi, sin, sqrt;
// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

/// Returns the great‑circle distance between two points (in kilometers).
double haversineDistanceKm({
  required double lat1,
  required double lng1,
  required double lat2,
  required double lng2,
}) {
  const earthRadiusKm = 6371.0;

  final dLat = _toRadians(lat2 - lat1);
  final dLng = _toRadians(lng2 - lng1);

  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
          sin(dLng / 2) * sin(dLng / 2);

  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadiusKm * c;
}

double _toRadians(double degrees) => degrees * pi / 180;
double calculateDiscountedPrice(double price, double discount) {
  return (discount <= price) ? (price - discount) : price;
}

double calculateItemAmount(double price, double discount, double qty) {
  return calculateDiscountedPrice(price, discount) * qty;
}
