import 'package:chevenergies/models/item.dart';
import 'package:chevenergies/screens/add_shop.dart';
import 'package:chevenergies/screens/dashboard.dart';
import 'package:chevenergies/screens/invoice.dart';
import 'package:chevenergies/screens/items.dart';
import 'package:chevenergies/screens/login.dart';
import 'package:chevenergies/screens/payment.dart';
import 'package:chevenergies/screens/customers.dart';
import 'package:chevenergies/services/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chev Energies',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => Consumer<AppState>(
              builder: (context, appState, _) {
                return appState.user == null ? const LoginScreen() : const DashboardScreen();
              },
            ),
        '/stops': (context) => CustomersScreen(day: ModalRoute.of(context)!.settings.arguments as String),
        '/items': (context) => ItemsScreen(routeId: ModalRoute.of(context)!.settings.arguments as String),
        '/invoice': (context) => InvoiceScreen(
              routeId: ModalRoute.of(context)!.settings.arguments as String,
              item: ModalRoute.of(context)!.settings.arguments as Item,
            ),
        '/payment': (context) => PaymentScreen(invoiceId: ModalRoute.of(context)!.settings.arguments as String, totalAmount: 0,),
      },
    );
  }
}