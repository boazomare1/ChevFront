import 'package:chevenergies/models/routedata.dart';

class User {
  final String token;
  final String email;
  final String name;
  final List<RouteData> routes;

  User({
    required this.token,
    required this.email,
    required this.name,
    required this.routes,
  });
}



