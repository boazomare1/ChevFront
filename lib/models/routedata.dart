import 'stop.dart';

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

  factory RouteData.fromJson(Map<String, dynamic> json) {
    // 1) grab the raw stops array
    final stopsJson = json['stops'] as List<dynamic>;
    // 2) convert each element to Stop
    final stops = stopsJson
        .map((e) => Stop.fromJson(e as Map<String, dynamic>))
        .toList();

    return RouteData(
      routeId: json['route_id'] as String,
      vehicle: json['vehicle'] as String,
      warehouse: json['warehouse'] as String,
      warehouseName: json['warehouse_name'] as String,
      stops: stops,
    );
  }
}
