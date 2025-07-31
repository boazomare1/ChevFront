class Stop {
  final int idx;
  final String name;
  final String shop;
  final int active;
  final String customer;
  final double latitude;
  final double longitude;
  final String countyName;
  final String townName;
  final String phone;
  final String email;
  final String logo;

  Stop({
    required this.idx,
    required this.name,
    required this.shop,
    required this.active,
    required this.customer,
    required this.latitude,
    required this.longitude,
    required this.countyName,
    required this.townName,
    required this.phone,
    required this.email,
    required this.logo,
  });

  factory Stop.fromJson(Map<String, dynamic> json) {
  return Stop(
    idx: json['idx'] as int,
    name: json['name'] as String? ?? '',
    shop: json['shop'] as String? ?? '',
    active: json['active'] as int,
    customer: json['customer'] as String? ?? '',
    latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
    longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    countyName: json['county_name'] as String? ?? '',
    townName: json['town_name'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    email: json['email'] as String? ?? '',
    logo: json['logo'] as String? ?? '', // allow null
  );
}

}
