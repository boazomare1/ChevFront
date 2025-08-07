import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'secure_storage_service.dart';

class BiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  // Check if biometric authentication is available
  static Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } on PlatformException catch (e) {
      print('Biometric availability check failed: $e');
      return false;
    }
  }

  // Get available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print('Failed to get available biometrics: $e');
      return [];
    }
  }

  // Check if fingerprint is available
  static Future<bool> isFingerprintAvailable() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.fingerprint);
  }

  // Authenticate using biometrics
  static Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your account',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } on PlatformException catch (e) {
      print('Biometric authentication failed: $e');
      return false;
    }
  }

  // Enable biometric authentication
  static Future<void> enableBiometric(String email, String password) async {
    await SecureStorageService.saveBiometricCredentials(email, password);
  }

  // Disable biometric authentication
  static Future<void> disableBiometric() async {
    await SecureStorageService.disableBiometric();
  }

  // Check if biometric is enabled
  static Future<bool> isBiometricEnabled() async {
    return await SecureStorageService.isBiometricEnabled();
  }

  // Get stored credentials
  static Future<Map<String, String>?> getStoredCredentials() async {
    return await SecureStorageService.getBiometricCredentials();
  }

  // Check if stored credentials are still valid (not too old)
  static Future<bool> areCredentialsValid() async {
    return await SecureStorageService.areBiometricCredentialsValid();
  }

  // Clear stored credentials
  static Future<void> clearStoredCredentials() async {
    await SecureStorageService.disableBiometric();
  }
}
