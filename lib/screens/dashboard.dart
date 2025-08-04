import 'package:chevenergies/models/user.dart';
import 'package:chevenergies/screens/expenditure.dart';
import 'package:chevenergies/screens/generic_invoice_list_screen.dart';
import 'package:chevenergies/screens/profile.dart';
import 'package:chevenergies/screens/sales.dart';
import 'package:chevenergies/screens/sales_dash.dart';
import 'package:chevenergies/screens/sales_history.dart';
import 'package:chevenergies/screens/stock_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Widget _buildDrawer(User user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF228B22)),
            accountName: Text(
              user.name.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(user.email),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.green),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.lock_reset),
            title: const Text('Change Password'),
            onTap: () {
              Navigator.pop(context);
              SnackBar snackBar = const SnackBar(
                content: Text('Coming soon...'),
                duration: Duration(seconds: 2),
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('LOGOUT', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              Provider.of<AppState>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppState>(context).user!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'POWER GAS HOME',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      drawer: _buildDrawer(user),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _buildFeatureTiles(context),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFeatureTiles(BuildContext context) {
    final user = Provider.of<AppState>(context).user!;
    // Typed data class eliminates Object->String errors
    final features = <_Feature>[
      _Feature(
        label: 'New Sale',
        iconPath: 'assets/hot-sale.png',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewSaleScreen()),
          );
        },
      ),
      _Feature(
        label: 'Sale History',
        iconPath: 'assets/sale-badge.png',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const InvoiceListScreen()),
          );
        },
      ),
      _Feature(
        label: 'Sales Summary',
        iconPath: 'assets/sales.png',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SalesSummaryDashScreen()),
          );
        },
      ),
      _Feature(
        label: 'Stock',
        iconPath: 'assets/money.png',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StockScreen(routeId: user.routes.first.routeId),
            ),
          );
        },
      ),
      _Feature(
        label: 'Discount Sales',
        iconPath: 'assets/offer.png',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => GenericInvoiceListScreen(
                    title: 'Discount Sales',
                    filterFn:
                        (inv) => inv.items.any((item) => item.discount > 0),
                  ),
            ),
          );
        },
      ),
      _Feature(
        label: 'Invoice Sales',
        iconPath: 'assets/bill.png',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GenericInvoiceListScreen(title: 'All Sales'),
            ),
          );
        },
      ),
      _Feature(
        label: 'Cheque Sales',
        iconPath: 'assets/cheque.png',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => GenericInvoiceListScreen(
                    title: 'Cheque Sales',
                    filterFn:
                        (inv) =>
                            inv.selectedPaymentMethod?.toLowerCase() ==
                            'cheque',
                  ),
            ),
          );
        },
      ),

      _Feature(
        label: 'Expenditure',
        iconPath: 'assets/financial.png',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExpenditureScreen()),
          );
        },
      ),
      // Blank placeholder -> keeps wrap even
      const _Feature(label: '', iconPath: '', onTap: null),
    ];

    return features.map((feature) {
      if (feature.label.isEmpty) {
        return SizedBox(
          width: MediaQuery.of(context).size.width / 2 - 20,
          height: 150,
        );
      }
      return SizedBox(
        width: MediaQuery.of(context).size.width / 2 - 20,
        height: 150,
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: feature.onTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  feature.iconPath,
                  width: 50,
                  height: 50,
                  errorBuilder:
                      (ctx, e, st) => const Icon(Icons.image_not_supported),
                ),
                const SizedBox(height: 10),
                Text(
                  feature.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    letterSpacing: 0.1,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 6),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}

// Strongly typed feature class
class _Feature {
  final String label;
  final String iconPath;
  final VoidCallback? onTap;

  const _Feature({
    required this.label,
    required this.iconPath,
    required this.onTap,
  });
}
