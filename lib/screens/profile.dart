import 'package:chevenergies/screens/login.dart';
import 'package:chevenergies/shared utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppState>(context).user;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppTheme.appBarStyle(title: 'Profile'),
        body: AppTheme.emptyState(
          icon: Icons.person_off,
          title: 'No User Data',
          subtitle: 'Please log in to view your profile',
        ),
      );
    }

    final route = user.routes.isNotEmpty ? user.routes.first : null;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppTheme.appBarStyle(title: 'My Profile'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section
            AppTheme.headerSection(
              title: user.name.toUpperCase(),
              subtitle: user.email ?? '',
              statusChip: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.successColor, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppTheme.successColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Profile details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Personal info card
                  Container(
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
                                Icons.person,
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'PERSONAL INFO',
                              style: AppTheme.headingSmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        _buildInfoRow(
                          'Employee ID',
                          user.employee ?? 'N/A',
                          Icons.badge,
                        ),
                        _buildInfoRow(
                          'Salesperson',
                          user.salesPerson ?? 'N/A',
                          Icons.work,
                        ),
                        _buildInfoRow(
                          'Role',
                          user.role.join(', '),
                          Icons.security,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Route info card (if available)
                  if (route != null)
                    Container(
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
                                  color: AppTheme.infoColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.route,
                                  color: AppTheme.infoColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'ROUTE INFO',
                                style: AppTheme.headingSmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          _buildInfoRow(
                            'Vehicle',
                            route.vehicle,
                            Icons.directions_car,
                          ),
                          _buildInfoRow(
                            'Warehouse',
                            route.warehouseName,
                            Icons.warehouse,
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final appState = Provider.of<AppState>(
                          context,
                          listen: false,
                        );
                        await appState.logout();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      label: const Text(
                        'LOGOUT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.grey[600], size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.toUpperCase(), style: AppTheme.caption),
                const SizedBox(height: 4),
                Text(value, style: AppTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
