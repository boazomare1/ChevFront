import 'package:flutter/material.dart';
import 'package:chevenergies/services/biometric_service.dart';
import 'package:chevenergies/shared utils/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricSettingsScreen extends StatefulWidget {
  const BiometricSettingsScreen({super.key});

  @override
  State<BiometricSettingsScreen> createState() =>
      _BiometricSettingsScreenState();
}

class _BiometricSettingsScreenState extends State<BiometricSettingsScreen> {
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  bool _isLoading = true;
  List<String> _availableBiometrics = [];

  @override
  void initState() {
    super.initState();
    _loadBiometricStatus();
  }

  Future<void> _loadBiometricStatus() async {
    try {
      final isAvailable = await BiometricService.isBiometricAvailable();
      final isEnabled = await BiometricService.isBiometricEnabled();
      final biometrics = await BiometricService.getAvailableBiometrics();

      if (mounted) {
        setState(() {
          _isBiometricAvailable = isAvailable;
          _isBiometricEnabled = isEnabled;
          _availableBiometrics =
              biometrics.map((b) => b.toString().split('.').last).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading biometric status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleBiometric(bool enable) async {
    setState(() => _isLoading = true);

    try {
      if (enable) {
        // Test biometric authentication first
        final success = await BiometricService.authenticateWithBiometrics();
        if (!success) {
          setState(() => _isLoading = false);
          return;
        }

        // Get stored credentials from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final savedEmail = prefs.getString('saved_email');
        final savedPassword = prefs.getString('saved_password');

        if (savedEmail == null || savedPassword == null) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please login with "Remember Me" enabled first to store credentials.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        await BiometricService.enableBiometric(savedEmail, savedPassword);
      } else {
        await BiometricService.disableBiometric();
      }

      if (mounted) {
        setState(() {
          _isBiometricEnabled = enable;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              enable
                  ? 'Fingerprint authentication enabled!'
                  : 'Fingerprint authentication disabled.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _testBiometric() async {
    setState(() => _isLoading = true);

    try {
      final success = await BiometricService.authenticateWithBiometrics();

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Biometric test successful!'
                  : 'Biometric test failed or cancelled.',
            ),
            backgroundColor: success ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Fingerprint Settings'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: AppTheme.cardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _isBiometricAvailable
                                    ? Icons.check_circle
                                    : Icons.error,
                                color:
                                    _isBiometricAvailable
                                        ? Colors.green
                                        : Colors.red,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Biometric Status',
                                style: AppTheme.headingMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isBiometricAvailable
                                ? 'Fingerprint authentication is available on this device.'
                                : 'Fingerprint authentication is not available on this device.',
                            style: AppTheme.bodyMedium,
                          ),
                          if (_availableBiometrics.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Available: ${_availableBiometrics.join(', ')}',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Enable/Disable Switch
                    if (_isBiometricAvailable) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: AppTheme.cardDecoration,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fingerprint Authentication',
                              style: AppTheme.headingMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Use your fingerprint to quickly login to the app.',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _isBiometricEnabled
                                            ? 'Enabled'
                                            : 'Disabled',
                                        style: AppTheme.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color:
                                              _isBiometricEnabled
                                                  ? Colors.green
                                                  : Colors.red,
                                        ),
                                      ),
                                      Text(
                                        _isBiometricEnabled
                                            ? 'You can login with your fingerprint'
                                            : 'Login with email and password only',
                                        style: AppTheme.bodySmall.copyWith(
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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

                      // Test Button
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: AppTheme.cardDecoration,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Test Fingerprint',
                              style: AppTheme.headingMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Test your fingerprint authentication to ensure it works properly.',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _testBiometric,
                                icon: const Icon(Icons.fingerprint),
                                label: const Text('Test Fingerprint'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Information Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: AppTheme.cardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppTheme.primaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'How it works',
                                style: AppTheme.headingMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildInfoItem(
                            '1. Enable "Remember Me" when logging in',
                            'This stores your credentials securely on your device.',
                          ),
                          _buildInfoItem(
                            '2. Enable fingerprint authentication',
                            'Use the toggle above to enable fingerprint login.',
                          ),
                          _buildInfoItem(
                            '3. Login with fingerprint',
                            'On the login screen, tap "Login with Fingerprint".',
                          ),
                          _buildInfoItem(
                            'Security',
                            'Your credentials are stored locally and encrypted on your device.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildInfoItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            description,
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
