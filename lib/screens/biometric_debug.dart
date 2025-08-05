import 'package:flutter/material.dart';
import '../services/biometric_service.dart';
import '../shared utils/app_theme.dart';

class BiometricDebugScreen extends StatefulWidget {
  const BiometricDebugScreen({super.key});

  @override
  State<BiometricDebugScreen> createState() => _BiometricDebugScreenState();
}

class _BiometricDebugScreenState extends State<BiometricDebugScreen> {
  Map<String, dynamic> _diagnostics = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isLoading = true;
      _diagnostics = {};
    });

    try {
      // Test 1: Basic availability
      final isAvailable = await BiometricService.isBiometricAvailable();
      _diagnostics['Basic Availability'] = isAvailable;

      // Test 2: Device support
      final biometrics = await BiometricService.getAvailableBiometrics();
      _diagnostics['Available Biometrics'] = biometrics
          .map((b) => b.toString())
          .join(', ');

      // Test 3: Fingerprint specific
      final isFingerprint = await BiometricService.isFingerprintAvailable();
      _diagnostics['Fingerprint Available'] = isFingerprint;

      // Test 4: Biometric enabled
      final isEnabled = await BiometricService.isBiometricEnabled();
      _diagnostics['Biometric Enabled'] = isEnabled;

      // Test 5: Credentials valid
      final areValid = await BiometricService.areCredentialsValid();
      _diagnostics['Credentials Valid'] = areValid;

      // Test 6: Stored credentials
      final credentials = await BiometricService.getStoredCredentials();
      _diagnostics['Stored Credentials'] = credentials != null ? 'Yes' : 'No';

      // Test 7: Try authentication (this might fail)
      try {
        final authResult = await BiometricService.authenticateWithBiometrics();
        _diagnostics['Authentication Test'] =
            authResult ? 'Success' : 'Failed/Cancelled';
      } catch (e) {
        _diagnostics['Authentication Test'] = 'Error: ${e.toString()}';
      }
    } catch (e) {
      _diagnostics['Diagnostic Error'] = e.toString();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testAuthentication() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await BiometricService.authenticateWithBiometrics();

      if (mounted) {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Authentication Result'),
                content: Text(result ? 'SUCCESS!' : 'Failed or Cancelled'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Authentication Error'),
                content: Text('Error: ${e.toString()}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _clearCredentials() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await BiometricService.disableBiometric();

      if (mounted) {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Credentials Cleared'),
                content: const Text(
                  'Stored credentials have been cleared successfully.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );

        // Refresh diagnostics to show updated state
        await _runDiagnostics();
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Error'),
                content: Text('Failed to clear credentials: ${e.toString()}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Biometric Debug'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _runDiagnostics,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Diagnostic Results
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Diagnostic Results',
                    style: AppTheme.headingMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    )
                  else
                    ..._diagnostics.entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                entry.key,
                                style: AppTheme.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(entry.value),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  entry.value.toString(),
                                  style: AppTheme.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Test Authentication Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testAuthentication,
              icon: const Icon(Icons.fingerprint),
              label: const Text('Test Authentication'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            const SizedBox(height: 12),

            // Refresh Button
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _runDiagnostics,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Diagnostics'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: BorderSide(color: AppTheme.primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            const SizedBox(height: 12),

            // Clear Credentials Button
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _clearCredentials,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Stored Credentials'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(dynamic value) {
    if (value == true || value == 'Success' || value == 'Yes') {
      return Colors.green;
    } else if (value == false || value == 'No' || value == 'Failed/Cancelled') {
      return Colors.orange;
    } else if (value.toString().contains('Error')) {
      return Colors.red;
    } else {
      return Colors.blue;
    }
  }
}
