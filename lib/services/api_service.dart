import 'dart:convert';
import 'dart:io';

import 'package:chevenergies/models/invoice.dart';
import 'package:chevenergies/models/item.dart' show Item;
import 'package:chevenergies/models/routedata.dart';
import 'package:chevenergies/models/user.dart';
import 'package:chevenergies/models/discount_sale.dart';
import 'package:chevenergies/shared%20utils/extension.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

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
    print("From Login {${response.body}}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access_token'];
      final userJson = data['user'];

      return User.fromJson(userJson, token);
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<List<Invoice>> listInvoices({
    required String routeId,
    required String startDate,
    required String endDate,
    String? paymentMethod,
    String? paymentStatus,
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
        'payment_method': paymentMethod,
        'payment_status': paymentStatus,
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
    print("From Get Routes {${response.body}}");
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
                  (item) => {
                    'item_code': item.itemCode,
                    'qty': item.quantity,
                    'discount_amount': item.discountAmount ?? 0.0,
                  },
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
    final requestBody = {
      'invoice_id': invoiceId,
      'payment_amount': amount.toString(),
      'payment_mode': mode,
    };

    print('=== PAYMENT API REQUEST ===');
    print('URL: $baseUrl/route_plan.apis.sales.create_payment_entry');
    print('Request Body: ${jsonEncode(requestBody)}');

    final response = await http.post(
      Uri.parse('$baseUrl/route_plan.apis.sales.create_payment_entry'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );

    print('=== PAYMENT API RESPONSE ===');
    print('Status Code: ${response.statusCode}');
    print('Response Headers: ${response.headers}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final data = jsonDecode(response.body);
        print('Parsed Response Data: $data');

        // Check if the response indicates success or failure
        if (data['status'] != null && data['status'] != 200) {
          print('API returned error status: ${data['status']}');
          print('Error message: ${data['message']}');
          throw Exception('Payment failed: ${data['message']}');
        }

        print('Payment processed successfully');
      } catch (e) {
        print('Error parsing response: $e');
        // Don't throw here, as the payment might still be successful
        print('Continuing with payment success...');
      }
    } else {
      print('HTTP Error: ${response.statusCode}');
      print('Error Response: ${response.body}');

      // Try to extract user-friendly error message from response
      String errorMessage = 'Payment failed. Please try again.';

      try {
        final errorData = jsonDecode(response.body);

        // Check for server messages in the response
        if (errorData['_server_messages'] != null) {
          final serverMessages = errorData['_server_messages'] as String;
          // Parse the server messages JSON string
          final messages = jsonDecode(serverMessages) as List;
          if (messages.isNotEmpty) {
            final firstMessage =
                jsonDecode(messages.first) as Map<String, dynamic>;
            if (firstMessage['message'] != null) {
              errorMessage = firstMessage['message'] as String;
            }
          }
        } else if (errorData['message'] != null) {
          errorMessage = errorData['message'] as String;
        }
      } catch (parseError) {
        print('Error parsing error response: $parseError');
        // Fall back to generic message
      }

      throw Exception(errorMessage);
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
    required String phoneNumber,
    required List<String> paymentMethods,
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
        'phone': phoneNumber,
        'payment_methods': paymentMethods,
      }),
    );
    print("From Create Customer {${response.body}}");
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

  Future<Map<String, dynamic>> raiseExpenseRequest({
    required double amount,
    required String description,
    required String date,
    String? receiptImage,
    required String routeId,
  }) async {
    final DateTime parsedDate = DateTime.parse(date);
    final String day = DateFormat('EEEE').format(parsedDate);

    final Map<String, dynamic> requestBody = {
      "route_id": routeId,
      "day": day,
      "date": date,
      "name": "Expense Request",
      "requestedAmount": amount.toString(),
      "approvedAmount": "0",
      "comments": description,
      "status": "Pending",
      "receipt": receiptImage != null ? "data:image/" : null,
      "receipt_image":
          receiptImage != null
              ? base64Encode(File(receiptImage).readAsBytesSync())
              : null,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/route_plan.apis.manage.raise_expense_request'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );

    print("From Raise Expense Request {${response.body}}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to raise expense request: ${response.body}');
    }
  }

  // New endpoint: list_expense_requests
  Future<List<Map<String, dynamic>>> listExpenseRequests({
    required String routeId,
    required String startDate,
    required String endDate,
    int start = 0,
    int pageLength = 20,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/route_plan.apis.manage.list_expenditure_requests'),
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

    print("From List Expense Requests {${response.body}}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        final expenses = data['data'] as List<dynamic>? ?? [];
        return expenses.cast<Map<String, dynamic>>();
      } else {
        throw Exception('API error: ${data['message']}');
      }
    } else {
      throw Exception(
        'Failed to fetch expense requests: HTTP ${response.statusCode}',
      );
    }
  }

  // New endpoint: ListAllSales
  Future<List<Invoice>> listAllSales({
    required String routeId,
    required String startDate,
    required String endDate,
    int start = 0,
    int pageLength = 20,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/route_plan.apis.sales.list_all_sales'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'start_date': startDate,
        'end_date': endDate,
        'start': start,
        'route_id': routeId,
        'page_length': pageLength,
      }),
    );

    print("From List All Sales {${response.body}}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        final sales = data['data'] as List<dynamic>? ?? [];
        return sales.map((json) => Invoice.fromJson(json)).toList();
      } else {
        throw Exception('API error: ${data['message']}');
      }
    } else {
      throw Exception('Failed to fetch sales: HTTP ${response.statusCode}');
    }
  }

  // New endpoint: ListDiscountSales
  Future<List<DiscountSale>> listDiscountSales({
    String? status,
    String? routeId,
    int start = 0,
    int pageLength = 20,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/route_plan.apis.sales.list_discount_sales'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'status': status,
        'route_id': routeId,
        'start': start,
        'page_length': pageLength,
      }),
    );

    print("From List Discount Sales {${response.body}}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        final discountSales = data['data'] as List<dynamic>? ?? [];
        return discountSales
            .map((json) => DiscountSale.fromJson(json))
            .toList();
      } else {
        throw Exception('API error: ${data['message']}');
      }
    } else {
      throw Exception(
        'Failed to fetch discount sales: HTTP ${response.statusCode}',
      );
    }
  }
}
