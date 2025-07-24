import 'package:chevenergies/screens/stops_screen.dart';
import 'package:flutter/material.dart';

class NewSaleScreen extends StatelessWidget {
  const NewSaleScreen({super.key});

  void _onTakeOrder(BuildContext context) {
    // TODO: push your take-order flow
  }

  void _onNewCustomer(BuildContext context) {
    // TODO: push your new-customer flow
  }

  @override
  Widget build(BuildContext context) {
    // Use a small data class for type safety
    final items = <_ActionItem>[
      _ActionItem(
        label: 'Make Sale',
        iconPath: 'assets/acquisition.png',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CustomersScreen(day: 'monday')),
          );
        },
      ),
      _ActionItem(
        label: 'Take Order',
        iconPath: 'assets/gas-cylinder.png',
        onTap: () => _onTakeOrder(context),
      ),
      _ActionItem(
        label: 'New Customer',
        iconPath: 'assets/add-user.png',
        onTap: () => _onNewCustomer(context),
      ),
      // Blank placeholder to keep grid even
      const _ActionItem(label: '', iconPath: '', onTap: null),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF228B22), // Green header
        elevation: 0,
        leading: IconButton(
          padding: const EdgeInsets.all(10),
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'NEW SALE',
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
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(20),
          child: Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: SizedBox(
              width: 70,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        child: Center(
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: items.map((item) {
              // If label empty, render a blank box
              if (item.label.isEmpty) {
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: item.onTap,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          item.iconPath,
                          width: 50,
                          height: 50,
                          errorBuilder: (ctx, e, st) =>
                              const Icon(Icons.image_not_supported, size: 50),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item.label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
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
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// Simple data class for action tiles
class _ActionItem {
  final String label;
  final String iconPath;
  final VoidCallback? onTap;

  const _ActionItem({
    required this.label,
    required this.iconPath,
    required this.onTap,
  });
}
