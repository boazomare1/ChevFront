import 'package:flutter/material.dart';
import '../services/biometric_service.dart';
import '../shared utils/app_theme.dart';

class BiometricSimpleTestScreen extends StatefulWidget {
  const BiometricSimpleTestScreen({super.key});

  @override
  State<BiometricSimpleTestScreen> createState() =>
      _BiometricSimpleTestScreenState();
}

class _BiometricSimpleTestScreenState extends State<BiometricSimpleTestScreen> {
  String _status = 'Initializing...';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() {
      _status = 'Checking biometric availability...';
      _isLoading = true;
    });

    try {
      final isAvailable = await BiometricService.isBiometricAvailable();
      final isFingerprint = await BiometricService.isFingerprintAvailable();
      final biometrics = await BiometricService.getAvailableBiometrics();

      setState(() {
        _status = '''
Biometric Available: $isAvailable
Fingerprint Available: $isFingerprint
Available Biometrics: ${biometrics.map((b) => b.toString()).join(', ')}
''';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testAuth() async {
    setState(() {
      _status = 'Testing biometric authentication...';
      _isLoading = true;
    });

    try {
      final result = await BiometricService.authenticateWithBiometrics();
      setState(() {
        _status =
            result
                ? 'Authentication SUCCESS!'
                : 'Authentication failed or cancelled';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Authentication Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Simple Biometric Test'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: AppTheme.headingMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.textLight),
                    ),
                    child: Text(_status, style: AppTheme.bodyMedium),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Test Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testAuth,
              icon: const Icon(Icons.fingerprint),
              label: const Text('Test Biometric Auth'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            const SizedBox(height: 12),

            // Refresh Button
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _checkStatus,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Status'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: BorderSide(color: AppTheme.primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            if (_isLoading) ...[
              const SizedBox(height: 20),
              const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
