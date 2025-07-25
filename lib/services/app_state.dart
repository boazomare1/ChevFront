import 'package:flutter/material.dart';
import 'package:chevenergies/models/item.dart';
import 'package:chevenergies/models/routedata.dart';
import 'package:chevenergies/models/user.dart';
import 'package:chevenergies/models/invoice.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';

class AppState with ChangeNotifier {
  User? user;
  final ApiService apiService = ApiService();

  List<Invoice> _invoices = [];
  bool _isLoadingInvoices = false;

  List<Invoice> get invoices => _invoices;
  bool get isLoadingInvoices => _isLoadingInvoices;

  Future<void> login(String email, String password) async {
    user = await apiService.login(email, password);
    apiService.token = user!.token;
    notifyListeners();
  }

  Future<List<RouteData>> getRoutes(String day) => apiService.getRoutes(day);
  Future<List<Item>> listItems(String routeId) => apiService.listItems(routeId);

  Future<Map<String, dynamic>> raiseInvoice(String routeId, String stopId, String day, List<Item> items) async {
    final data = await apiService.raiseInvoice(routeId, stopId, day, items);
    return data;
  }

  Future<Map<String, dynamic>> raiseTicket(
    String routeId,
    String stopId,
    String day,
    String notes,
  ) {
    return apiService.raiseTicket(routeId, stopId, day, notes);
  }

  Future<void> createPayment(String invoiceId, double amount, String mode) =>
      apiService.createPayment(invoiceId, amount, mode);

  Future<void> fetchInvoices({
    required DateTime startDate,
    required DateTime endDate,
    int start = 0,
    int pageLength = 20,
  }) async {
    if (user == null || user!.routes.isEmpty) {
      // no route – bail out
      _invoices = [];
      notifyListeners();
      return;
    }

    _isLoadingInvoices = true;
    notifyListeners();

    // grab the first routeId from the logged‑in user
    final routeId = user!.routes.first.routeId;

    final fmt = DateFormat('yyyy-MM-dd');
    final startStr = fmt.format(startDate);
    final endStr = fmt.format(endDate);

    try {
      _invoices = await apiService.listInvoices(
        routeId: routeId,
        startDate: startStr,
        endDate: endStr,
        start: start,
        pageLength: pageLength,
      );
    } catch (e) {
      print('Error fetching invoices: $e');
      _invoices = [];
    }

    _isLoadingInvoices = false;
    notifyListeners();
  }


  Future<Invoice> getInvoiceById(String invoiceId) {
  return apiService.getInvoiceById(invoiceId);
}

  
}
