import 'package:chevenergies/shared utils/widgets.dart';
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
          color: Colors.white, // overall background
          child: Column(
            children: [
              // matching the LoginScreen’s green top stripe
              Container(
                height: 60,
                color: const Color(0xFF228B22),
              ),

              // give some space before content
              const SizedBox(height: 10),
              Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
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
                      Divider(color: Colors.black, indent: 30, endIndent: 30, thickness: 1),
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
    final features = [
     {'label': 'New Sale', 'icon': 'assets/hot-sale.png'},
      {'label': 'Sale History', 'icon': 'assets/financial.png'},
      {'label': 'Sales Summary', 'icon': 'assets/bill.png'},
      {'label': 'Stock', 'icon': 'assets/money.png'},
      {'label': 'Discount Sales', 'icon': 'assets/sales.png'},
      {'label': 'Invoice Sales', 'icon': 'assets/offer.png'},
      {'label': 'Cheque Sales', 'icon': 'assets/cheque.png'},
      {'label': 'Expenditure', 'icon': 'assets/sale-badge.png'},
      {'label': 'Account', 'icon': 'assets/user.png'},
    ];

    // Add one blank to keep an even count
    features.add({'label': '', 'icon': ''});

    return features.map((item) {
      final isBlank = item['label']!.isEmpty;
      return SizedBox(
        width: MediaQuery.of(context).size.width / 2 - 20,
        height: 150,
        child: isBlank
            ? const SizedBox.shrink()
            : Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                child: InkWell(
                  onTap: () {
                    // TODO: handle each feature tap
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(item['icon']!, width: 50, height: 50),
                      const SizedBox(height: 10),
                      Text(
                        item['label']!,
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