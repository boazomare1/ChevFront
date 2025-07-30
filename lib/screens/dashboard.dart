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
  String? _error;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppState>(context).user!;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // Green top stripe
              Container(
                height: 60,
                color: const Color(0xFF228B22),
              ),

              const SizedBox(height: 10),

              // Title card
              Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 15, horizontal: 20),
                  child: Column(
                    children: const [
                      Text(
                        'POWER GAS HOME',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 6),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Divider(
                        color: Colors.black,
                        indent: 30,
                        endIndent: 30,
                        thickness: 1,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Grid of feature cards
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
            MaterialPageRoute(builder: (_) => StockScreen(
              routeId: user.routes.first.routeId,
            )),
          );
        },
      ),
      _Feature(
        label: 'Discount Sales',
        iconPath: 'assets/offer.png',
        onTap: () {
          // TODO: push Discount Sales
        },
      ),
      _Feature(
        label: 'Invoice Sales',
        iconPath: 'assets/bill.png',
        onTap: () {
          // TODO: push Invoice Sales
        },
      ),
      _Feature(
        label: 'Cheque Sales',
        iconPath: 'assets/cheque.png',
        onTap: () {
          // TODO: push Cheque Sales
        },
      ),
      _Feature(
        label: 'Expenditure',
        iconPath: 'assets/financial.png',
        onTap: () {
          // TODO: push Expenditure
        },
      ),
      _Feature(
        label: 'Account',
        iconPath: 'assets/user.png',
        onTap: () {
          // TODO: push Account
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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
                  errorBuilder: (ctx, e, st) =>
                      const Icon(Icons.image_not_supported),
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
