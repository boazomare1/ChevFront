import 'package:chevenergies/models/stop.dart';

class RouteData {
  final String routeId;
  final String vehicle;
  final String warehouse;
  final String warehouseName;
  final List<Stop> stops;

  RouteData({
    required this.routeId,
    required this.vehicle,
    required this.warehouse,
    required this.warehouseName,
    required this.stops,
  });
}