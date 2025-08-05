import 'package:flutter/material.dart';
import '../services/biometric_service.dart';
import '../shared utils/app_theme.dart';

class BiometricTestScreen extends StatefulWidget {
  const BiometricTestScreen({super.key});

  @override
  State<BiometricTestScreen> createState() => _BiometricTestScreenState();
}

class _BiometricTestScreenState extends State<BiometricTestScreen> {
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  bool _isFingerprintAvailable = false;
  List<String> _availableBiometrics = [];
  String _testResult = '';

  @override
  void initState() {
    super.initState();
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    setState(() {
      _testResult = 'Checking biometric status...';
    });

    try {
      final isAvailable = await BiometricService.isBiometricAvailable();
      final isEnabled = await BiometricService.isBiometricEnabled();
      final isFingerprint = await BiometricService.isFingerprintAvailable();
      final biometrics = await BiometricService.getAvailableBiometrics();

      setState(() {
        _isBiometricAvailable = isAvailable;
        _isBiometricEnabled = isEnabled;
        _isFingerprintAvailable = isFingerprint;
        _availableBiometrics = biometrics.map((b) => b.toString()).toList();
        _testResult = 'Status check completed';
      });
    } catch (e) {
      setState(() {
        _testResult = 'Error: $e';
      });
    }
  }

  Future<void> _testBiometricAuth() async {
    setState(() {
      _testResult = 'Testing biometric authentication...';
    });

    try {
      final result = await BiometricService.authenticateWithBiometrics();
      setState(() {
        _testResult =
            result
                ? 'Authentication successful!'
                : 'Authentication failed or cancelled';
      });
    } catch (e) {
      setState(() {
        _testResult = 'Error during authentication: $e';
      });
    }
  }

  Future<void> _testEnableBiometric() async {
    setState(() {
      _testResult = 'Testing biometric enable...';
    });

    try {
      await BiometricService.enableBiometric(
        'test@example.com',
        'testpassword',
      );
      await _checkBiometricStatus();
      setState(() {
        _testResult = 'Biometric enabled successfully!';
      });
    } catch (e) {
      setState(() {
        _testResult = 'Error enabling biometric: $e';
      });
    }
  }

  Future<void> _testDisableBiometric() async {
    setState(() {
      _testResult = 'Testing biometric disable...';
    });

    try {
      await BiometricService.disableBiometric();
      await _checkBiometricStatus();
      setState(() {
        _testResult = 'Biometric disabled successfully!';
      });
    } catch (e) {
      setState(() {
        _testResult = 'Error disabling biometric: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Biometric Test'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
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
                  Text(
                    'Biometric Status',
                    style: AppTheme.headingMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatusRow('Biometric Available', _isBiometricAvailable),
                  _buildStatusRow(
                    'Fingerprint Available',
                    _isFingerprintAvailable,
                  ),
                  _buildStatusRow('Biometric Enabled', _isBiometricEnabled),
                  const SizedBox(height: 16),
                  Text(
                    'Available Biometrics:',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_availableBiometrics.isEmpty)
                    Text(
                      'None detected',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    )
                  else
                    ..._availableBiometrics.map(
                      (bio) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('• $bio', style: AppTheme.bodySmall),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Test Results Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Test Results',
                    style: AppTheme.headingMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.textLight),
                    ),
                    child: Text(_testResult, style: AppTheme.bodyMedium),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Test Buttons
            if (_isBiometricAvailable) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _testBiometricAuth,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Test Biometric Auth'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _testEnableBiometric,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Enable Biometric'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _testDisableBiometric,
                  icon: const Icon(Icons.cancel),
                  label: const Text('Disable Biometric'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.warningColor),
                ),
                child: Column(
                  children: [
                    Icon(Icons.warning, color: AppTheme.warningColor, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'Biometric Not Available',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.warningColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'This device does not support biometric authentication or biometrics are not set up.',
                      style: AppTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Refresh Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _checkBiometricStatus,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Status'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: BorderSide(color: AppTheme.primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, bool status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            status ? Icons.check_circle : Icons.cancel,
            color: status ? AppTheme.successColor : AppTheme.errorColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(label, style: AppTheme.bodyMedium),
          const Spacer(),
          Text(
            status ? 'Yes' : 'No',
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: status ? AppTheme.successColor : AppTheme.errorColor,
            ),
          ),
        ],
      ),
    );
  }
}
