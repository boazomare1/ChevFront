import 'package:chevenergies/models/item.dart';
import 'package:chevenergies/screens/dashboard.dart';
import 'package:chevenergies/screens/invoice.dart';
import 'package:chevenergies/screens/items.dart';
import 'package:chevenergies/screens/login.dart';
import 'package:chevenergies/screens/payment.dart';
import 'package:chevenergies/screens/customers.dart';
import 'package:chevenergies/screens/discount_sales.dart';
import 'package:chevenergies/screens/cheque_sales.dart';
import 'package:chevenergies/screens/invoice_details.dart';
import 'package:chevenergies/screens/stock_keeper_dashboard.dart';
import 'package:chevenergies/screens/biometric_settings.dart';
import 'package:chevenergies/screens/change_password.dart';
import 'package:chevenergies/screens/update_profile_image.dart';

import 'package:chevenergies/services/app_state.dart';
import 'package:chevenergies/services/theme_provider.dart';
import 'package:chevenergies/shared utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // Update AppTheme with current theme mode
        AppTheme.setDarkMode(themeProvider.isDarkMode);

        return MaterialApp(
          title: 'Chev Energies',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/':
                (context) => Consumer<AppState>(
                  builder: (context, appState, _) {
                    if (appState.user == null) {
                      return const LoginScreen();
                    }

                    // Role-based dashboard routing
                    final userRoles = appState.user!.role;

                    // Check for stock keeper role
                    if (userRoles.contains('stock_keeper') ||
                        userRoles.contains('store_keeper') ||
                        userRoles.contains('warehouse_manager')) {
                      return const StockKeeperDashboard();
                    }

                    // Default to main dashboard for sales_person and other roles
                    return const DashboardScreen();
                  },
                ),
            '/stops':
                (context) => CustomersScreen(
                  day: ModalRoute.of(context)!.settings.arguments as String,
                ),
            '/items':
                (context) => ItemsScreen(
                  routeId: ModalRoute.of(context)!.settings.arguments as String,
                ),
            '/invoice':
                (context) => InvoiceScreen(
                  routeId: ModalRoute.of(context)!.settings.arguments as String,
                  item: ModalRoute.of(context)!.settings.arguments as Item,
                ),
            '/payment':
                (context) => PaymentScreen(
                  invoiceId:
                      ModalRoute.of(context)!.settings.arguments as String,
                  totalAmount: 0,
                ),
            '/discount-sales': (context) => const DiscountSalesScreen(),
            '/cheque-sales': (context) => const ChequeSalesScreen(),
            '/invoice-details':
                (context) => const InvoiceDetailsScreen(invoiceId: ''),

            '/stock-keeper': (context) => const StockKeeperDashboard(),
            '/biometric-settings': (context) => const BiometricSettingsScreen(),
            '/change-password': (context) => const ChangePasswordScreen(),
            '/update-profile-image':
                (context) => const UpdateProfileImageScreen(),

            '/login': (context) => const LoginScreen(),
          },
        );
      },
    );
  }
}
