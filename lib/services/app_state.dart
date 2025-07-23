import 'package:chevenergies/models/item.dart';
import 'package:chevenergies/models/routedata.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';
import '../models/user.dart';

class AppState with ChangeNotifier {
  User? user;
  final ApiService apiService = ApiService();

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
  Future<void> createPayment(String invoiceId, double amount, String mode) =>
      apiService.createPayment(invoiceId, amount, mode);
}