import 'package:chevenergies/models/routedata.dart';

class User {
  final String token;
  final String email;
  final String name;
  final String? employee;
  final String? salesPerson;
  final String? firstName;
  final String? lastName;
  final List<String> role;
  final List<RouteData> routes;

  User({
    required this.token,
    required this.email,
    required this.name,
    this.employee,
    this.salesPerson,
    this.firstName,
    this.lastName,
    required this.role,
    required this.routes,
  });

  factory User.fromJson(Map<String, dynamic> json, String token) {
    return User(
      token: token,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      employee: json['employee'],
      salesPerson: json['sales_person'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      role: List<String>.from(json['role'] ?? []),
      routes: (json['route'] as List<dynamic>)
          .map((r) => RouteData(
                routeId: r['route_id'],
                vehicle: r['vehicle'],
                warehouse: r['warehouse'],
                warehouseName: r['warehouse_name'],
                stops: [],
              ))
          .toList(),
    );
  }
}
