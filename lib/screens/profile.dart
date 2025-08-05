import 'package:chevenergies/screens/login.dart';
import 'package:chevenergies/shared utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/biometric_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isBiometricEnabled = false;
  bool _isBiometricAvailable = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    final isAvailable = await BiometricService.isBiometricAvailable();
    final isEnabled = await BiometricService.isBiometricEnabled();

    setState(() {
      _isBiometricAvailable = isAvailable;
      _isBiometricEnabled = isEnabled;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    setState(() => _isLoading = true);

    try {
      if (value) {
        // Enable biometric
        final isAuthenticated =
            await BiometricService.authenticateWithBiometrics();
        if (isAuthenticated) {
          // Get current user credentials from AppState and enable biometric
          final appState = Provider.of<AppState>(context, listen: false);
          if (appState.user?.email != null) {
            // Note: In a real app, you'd need to store the password securely
            // For now, we'll just enable biometric without storing credentials
            await BiometricService.enableBiometric(
              appState.user!.email!,
              'stored_password', // This should be the actual stored password
            );
            setState(() => _isBiometricEnabled = true);
          }
        }
      } else {
        // Disable biometric
        await BiometricService.disableBiometric();
        setState(() => _isBiometricEnabled = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to ${value ? 'enable' : 'disable'} biometric login',
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

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
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/logo_round.png',
              height: 28,
              width: 28,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            const Text(
              'My Profile',
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
                  color: AppTheme.successColor.withValues(alpha: 0.1),
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
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.1,
                                ),
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
                                  color: AppTheme.infoColor.withValues(
                                    alpha: 0.1,
                                  ),
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

                  // Security settings card
                  if (_isBiometricAvailable) ...[
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
                                  color: AppTheme.warningColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.security,
                                  color: AppTheme.warningColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'SECURITY SETTINGS',
                                style: AppTheme.headingSmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.fingerprint,
                                  color: AppTheme.primaryColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Fingerprint Login',
                                      style: AppTheme.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Use fingerprint for faster login',
                                      style: AppTheme.bodySmall.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_isLoading)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.primaryColor,
                                  ),
                                )
                              else
                                Switch(
                                  value: _isBiometricEnabled,
                                  onChanged: _toggleBiometric,
                                  activeColor: AppTheme.primaryColor,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

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
