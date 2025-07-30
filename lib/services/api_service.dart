import 'dart:convert';

import 'package:chevenergies/models/invoice.dart';
import 'package:chevenergies/models/item.dart' show Item;
import 'package:chevenergies/models/routedata.dart';
import 'package:chevenergies/models/user.dart';
import 'package:chevenergies/shared%20utils/extension.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class ApiService {
  final String baseUrl =
      'https://chevenergies.techsavanna.technology/api/method';
  String? token;

  Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/route_plan.apis.accounts.login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access_token'];
      final userData = data['user'];
      final routes =
          (userData['route'] as List)
              .map(
                (r) => RouteData(
                  routeId: r['route_id'],
                  vehicle: r['vehicle'],
                  warehouse: r['warehouse'],
                  warehouseName: r['warehouse_name'],
                  stops: [],
                ),
              )
              .toList();
      return User(
        token: token,
        email: email,
        name: userData['name'],
        routes: routes,
      );
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<List<Invoice>> listInvoices({
    required String routeId,
    required String startDate,
    required String endDate,
    int start = 0,
    int pageLength = 20,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/route_plan.apis.sales.list_invoices'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'route_id': routeId,
        'start_date': startDate,
        'end_date': endDate,
        'start': start,
        'page_length': pageLength,
      }),
    );

    print("From Invoice List {${response.body}}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        final invoices = data['data'] as List<dynamic>? ?? [];
        return invoices.map((json) => Invoice.fromJson(json)).toList();
      } else {
        throw Exception('API error: ${data['message']}');
      }
    } else {
      throw Exception('Failed to fetch invoices: HTTP ${response.statusCode}');
    }
  }

  Future<Invoice> getInvoiceById(String invoiceId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/route_plan.apis.sales.get_invoice_by_id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'invoice_id': invoiceId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return Invoice.fromJson(data);
    } else {
      throw Exception('Failed to get invoice: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> raiseTicket(
    String routeId,
    String stopId,
    String day,
    String notes,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/route_plan.apis.sales.raise_ticket'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'route_id': routeId,
        'stop_id': stopId,
        'day': day,
        'notes': notes,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to raise ticket: ${response.body}');
    }
  }

  Future<List<RouteData>> getRoutes(String day, String routeId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/route_plan.apis.route.get_salesman_routes_for_day'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'day': day, 'route_id': routeId}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch routes: ${response.body}');
    }

    // 1) Decode the JSON payload
    final Map<String, dynamic> body = jsonDecode(response.body);

    // 2) Extract the "routes" array (note: your server returns it under "routes")
    final List<dynamic> routesJson = body['routes'] as List<dynamic>;

    // 3) Map each element through your factory
    return routesJson
        .map((e) => RouteData.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Item>> listItems(String routeId) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/route_plan.apis.sales.list_warehouse_items?route_id=$routeId',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print("From List Items {${response.body}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List)
          .map(
            (item) => Item(
              itemCode: item['item_code'] ?? '',
              itemName: item['item_name'] ?? '',
              description: item['description'] ?? '',
              quantity: item['quantity']?.toDouble() ?? 0.0,
              warehouse: item['warehouse'] ?? '',
              sellingPrice: item['selling_price']?.toDouble() ?? 0.0,
              amount: item['amount']?.toDouble() ?? 0.0,
            ),
          )
          .toList();
    } else {
      throw Exception('Failed to fetch items: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> raiseInvoice(
    String routeId,
    String stopId,
    String day,
    List<Item> items,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/route_plan.apis.sales.raise_invoice'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'route_id': routeId,
        'stop_id': stopId,
        'day': day,
        'items':
            items
                .map(
                  (item) => {'item_code': item.itemCode, 'qty': item.quantity},
                )
                .toList(),
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to raise invoice: ${response.body}');
    }
  }

  Future<void> createPayment(
    String invoiceId,
    double amount,
    String mode,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/route_plan.apis.sales.create_payment_entry'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'invoice_id': invoiceId,
        'payment_amount': amount.toString(),
        'payment_mode': mode,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      // final data = jsonDecode(response.body);
      // No need to throw an exception for success cases
    } else {
      throw Exception('Failed to process payment: ${response.body}');
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied. We cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  }

  Future<double> distanceToTarget() async {
    // 1. Get current user position
    final pos = await _determinePosition();

    // 2. Define your target coordinates
    const targetLat = 0.592252;
    const targetLng = 34.771343;

    // 3. Compute distance
    final distanceKm = haversineDistanceKm(
      lat1: pos.latitude,
      lng1: pos.longitude,
      lat2: targetLat,
      lng2: targetLng,
    );

    return distanceKm;
  }

  Future<List<String>> listTerritories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/route_plan.apis.manage.list_territories'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(
        data['territories'].map((t) => t['territory_name']),
      );
    } else {
      throw Exception('Failed to fetch territories: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> createCustomer({
    required String customerName,
    required String customerType,
    required String territory,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/route_plan.apis.manage.create_customer'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'customer_name': customerName,
        'customer_type': customerType,
        'territory': territory,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('Failed to create customer: ${response.body}');
    }
  }

  Future<void> createShop({
    required String shopName,
    required String customerId,
    required String phone,
    required String email,
    required String countyName,
    required String townName,
    required double latitude,
    required double longitude,
    required String logoBase64,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/route_plan.apis.manage.create_shop'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'shop_name': shopName,
        'customer': customerId,
        'phone': phone,
        'email': email,
        'county_name': countyName,
        'town_name': townName,
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'logo': logoBase64,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create shop: ${response.body}');
    }
  }
}
