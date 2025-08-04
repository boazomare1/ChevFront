import 'package:chevenergies/models/user.dart';
import 'package:chevenergies/screens/expenditure.dart';
import 'package:chevenergies/screens/generic_invoice_list_screen.dart';
import 'package:chevenergies/screens/profile.dart';
import 'package:chevenergies/screens/make_sale.dart';
import 'package:chevenergies/screens/sales.dart';
import 'package:chevenergies/screens/sales_dash.dart';
import 'package:chevenergies/screens/sales_history.dart';
import 'package:chevenergies/screens/stock_screen.dart';
import 'package:chevenergies/screens/customers.dart';
import 'package:chevenergies/shared utils/app_theme.dart';
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
            decoration: const BoxDecoration(color: AppTheme.primaryColor),
            accountName: Text(
              user.name.toUpperCase(),
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
                  Icons.person,
                  size: 40,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),

          ListTile(
            leading: const Icon(
              Icons.account_circle,
              color: AppTheme.textPrimary,
            ),
            title: const Text('Profile', style: AppTheme.bodyMedium),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.lock_reset, color: AppTheme.textPrimary),
            title: const Text('Change Password', style: AppTheme.bodyMedium),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Coming soon...'),
                  duration: Duration(seconds: 2),
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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppTheme.appBarStyle(title: 'POWER GAS HOME', centerTitle: true),
      drawer: _buildDrawer(user),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section
            AppTheme.headerSection(
              title: 'Welcome Back!',
              subtitle: user.name,
              stats: [
                AppTheme.statItem(
                  'Routes',
                  user.routes.length.toString(),
                  Icons.route,
                ),
                AppTheme.statItem('Today', '0', Icons.today),
                AppTheme.statItem('Total', '0', Icons.analytics),
              ],
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
      {'icon': Icons.shopping_cart, 'title': 'Make Sale', 'route': '/sales'},
      {'icon': Icons.inventory, 'title': 'Stock', 'route': '/stock'},
      {
        'icon': Icons.receipt_long,
        'title': 'Expenditures',
        'route': '/expenditure',
      },
      {'icon': Icons.people, 'title': 'Customers', 'route': '/customers'},
      {
        'icon': Icons.analytics,
        'title': 'Sales History',
        'route': '/sales-history',
      },
      {
        'icon': Icons.dashboard,
        'title': 'Sales Dashboard',
        'route': '/sales-dash',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1, // Reduced from 1.2 to give more height
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _buildActionCard(
          icon: action['icon'] as IconData,
          title: action['title'] as String,
          onTap: () => _navigateToRoute(action['route'] as String),
        );
      },
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
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
            padding: const EdgeInsets.all(16), // Reduced from 20 to 16
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12), // Reduced from 16 to 12
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Reduced from 16 to 12
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ), // Reduced from 32 to 28
                ),
                const SizedBox(height: 8), // Reduced from 12 to 8
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14, // Reduced from 16 to 14
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2, // Allow text to wrap to 2 lines
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
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.history,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text('RECENT ACTIVITY', style: AppTheme.headingSmall),
            ],
          ),
          const SizedBox(height: 16),

          // Placeholder for recent activity
          _buildActivityItem(
            icon: Icons.shopping_cart,
            title: 'New sale completed',
            subtitle: '2 hours ago',
            color: AppTheme.successColor,
          ),
          _buildActivityItem(
            icon: Icons.receipt_long,
            title: 'Expense claim submitted',
            subtitle: '4 hours ago',
            color: AppTheme.warningColor,
          ),
          _buildActivityItem(
            icon: Icons.inventory,
            title: 'Stock updated',
            subtitle: '1 day ago',
            color: AppTheme.infoColor,
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
    final user = Provider.of<AppState>(context, listen: false).user!;
    switch (route) {
      case '/sales':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NewSaleScreen()),
        );
        break;
      case '/stock':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StockScreen(routeId: user.routes.first.routeId),
          ),
        );
        break;
      case '/expenditure':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ExpenditureScreen()),
        );
        break;
      case '/customers':
        final today =
            DateTime.now().weekday == DateTime.monday ? 'monday' : 'tuesday';
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CustomersScreen(day: today)),
        );
        break;
      case '/sales-history':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const InvoiceListScreen()),
        );
        break;
      case '/sales-dash':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SalesSummaryDashScreen()),
        );
        break;
    }
  }
}
