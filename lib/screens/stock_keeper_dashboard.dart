import 'package:chevenergies/models/user.dart';
import 'package:chevenergies/screens/salespeople.dart';
import 'package:chevenergies/screens/current_stock.dart';
import 'package:chevenergies/shared utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class StockKeeperDashboard extends StatefulWidget {
  const StockKeeperDashboard({super.key});

  @override
  _StockKeeperDashboardState createState() => _StockKeeperDashboardState();
}

class _StockKeeperDashboardState extends State<StockKeeperDashboard> {
  Widget _buildDrawer(User user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primaryColor),
            accountName: Text(
              'STOCK KEEPER',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            accountEmail: Text(
              user.email,
              style: const TextStyle(color: Colors.white70),
            ),
            currentAccountPicture: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.inventory,
                  size: 40,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.dashboard, color: AppTheme.textPrimary),
            title: const Text('Dashboard', style: AppTheme.bodyMedium),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: const Icon(
              Icons.local_shipping,
              color: AppTheme.textPrimary,
            ),
            title: const Text('Salespeople', style: AppTheme.bodyMedium),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SalespeopleScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.inventory_2, color: AppTheme.textPrimary),
            title: const Text('Stock Management', style: AppTheme.bodyMedium),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Stock Management coming soon...'),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.analytics, color: AppTheme.textPrimary),
            title: const Text('Stock Reports', style: AppTheme.bodyMedium),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Stock Reports coming soon...'),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.settings, color: AppTheme.textPrimary),
            title: const Text('Settings', style: AppTheme.bodyMedium),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings coming soon...'),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.errorColor),
            title: const Text(
              'LOGOUT',
              style: TextStyle(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Provider.of<AppState>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user =
        appState.user ??
        User(
          name: 'Stock Keeper',
          email: 'stockkeeper@chevenergies.com',
          token: 'mock-token',
          role: ['stock_keeper'],
          routes: [],
        );

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/logo_round.png',
              height: 32,
              width: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            const Text(
              'STOCK KEEPER DASHBOARD',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: _buildDrawer(user),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.successColor,
                    AppTheme.successColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.inventory,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'STOCK MANAGEMENT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Welcome, ${user.name}!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        AppTheme.statItem(
                          'Salespeople',
                          '10',
                          Icons.local_shipping,
                        ),
                        AppTheme.statItem('Items', '7', Icons.inventory_2),
                        AppTheme.statItem('Regions', '5', Icons.location_on),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Quick Actions Grid
                  _buildQuickActionsGrid(),
                  const SizedBox(height: 20),

                  // Recent Activity
                  _buildRecentActivitySection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    final actions = [
      {
        'icon': Icons.local_shipping,
        'title': 'Salespeople',
        'subtitle': 'Manage salespeople',
        'route': '/salespeople',
        'color': AppTheme.primaryColor,
      },
      {
        'icon': Icons.inventory_2,
        'title': 'Stock Count',
        'subtitle': 'Count current stock',
        'route': '/stock-count',
        'color': AppTheme.successColor,
      },
      {
        'icon': Icons.analytics,
        'title': 'Stock Reports',
        'subtitle': 'View stock reports',
        'route': '/stock-reports',
        'color': AppTheme.infoColor,
      },
      {
        'icon': Icons.add_box,
        'title': 'Add Items',
        'subtitle': 'Add new items',
        'route': '/add-items',
        'color': AppTheme.warningColor,
      },
      {
        'icon': Icons.transfer_within_a_station,
        'title': 'Stock Transfer',
        'subtitle': 'Transfer stock',
        'route': '/stock-transfer',
        'color': AppTheme.secondaryColor,
      },
      {
        'icon': Icons.settings,
        'title': 'Settings',
        'subtitle': 'App settings',
        'route': '/settings',
        'color': AppTheme.textSecondary,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _buildActionCard(
          icon: action['icon'] as IconData,
          title: action['title'] as String,
          subtitle: action['subtitle'] as String,
          color: action['color'] as Color,
          onTap: () => _navigateToRoute(action['route'] as String),
        );
      },
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTheme.bodySmall.copyWith(fontSize: 11),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.history,
                  color: AppTheme.successColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text('RECENT ACTIVITY', style: AppTheme.headingSmall),
            ],
          ),
          const SizedBox(height: 16),

          _buildActivityItem(
            icon: Icons.local_shipping,
            title: 'Stock count updated for Vincent Atema',
            subtitle: '2 hours ago',
            color: AppTheme.successColor,
          ),
          _buildActivityItem(
            icon: Icons.inventory_2,
            title: 'New items added to inventory',
            subtitle: '4 hours ago',
            color: AppTheme.infoColor,
          ),
          _buildActivityItem(
            icon: Icons.analytics,
            title: 'Monthly stock report generated',
            subtitle: '1 day ago',
            color: AppTheme.warningColor,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.bodyMedium),
                Text(subtitle, style: AppTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToRoute(String route) {
    switch (route) {
      case '/salespeople':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SalespeopleScreen()),
        );
        break;
      case '/stock-count':
        // For testing, navigate to a sample stock count screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => const CurrentStockScreen(
                  salespersonName: 'Sample Salesperson',
                  salespersonCode: 'SAMPLE 001',
                ),
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$route coming soon...'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
    }
  }
}
