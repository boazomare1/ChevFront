import 'package:chevenergies/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppState>(context).user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No user data available.')),
      );
    }

    final route = user.routes.isNotEmpty ? user.routes.first : null;

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Icon(Icons.account_circle, size: 100, color: Colors.grey),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  user.name.toUpperCase(),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Center(child: Text(user.email ?? '', style: const TextStyle(color: Colors.grey))),
              const SizedBox(height: 24),
              _infoTile('Employee ID', user.employee ?? 'N/A'),
              _infoTile('Salesperson', user.salesPerson ?? 'N/A'),
              _infoTile('Role', user.role.join(', ')),
              if (route != null) ...[
                _infoTile('Vehicle', route.vehicle),
                _infoTile('Warehouse', route.warehouseName),
              ],
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final appState = Provider.of<AppState>(context, listen: false);
                  await appState.logout();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                label: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }
}
