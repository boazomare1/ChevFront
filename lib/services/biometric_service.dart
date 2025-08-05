import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _userCredentialsKey = 'user_credentials';

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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, true);

    // Store credentials securely (in production, use proper encryption)
    final credentials = {
      'email': email,
      'password': password,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await prefs.setString(_userCredentialsKey, jsonEncode(credentials));
  }

  // Disable biometric authentication
  static Future<void> disableBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, false);
    await prefs.remove(_userCredentialsKey);
  }

  // Check if biometric is enabled
  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  // Get stored credentials
  static Future<Map<String, String>?> getStoredCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final credentialsJson = prefs.getString(_userCredentialsKey);

    if (credentialsJson != null) {
      try {
        final credentials = jsonDecode(credentialsJson) as Map<String, dynamic>;
        return {
          'email': credentials['email'] as String,
          'password': credentials['password'] as String,
        };
      } catch (e) {
        print('Failed to parse stored credentials: $e');
        return null;
      }
    }
    return null;
  }

  // Check if stored credentials are still valid (not too old)
  static Future<bool> areCredentialsValid() async {
    final prefs = await SharedPreferences.getInstance();
    final credentialsJson = prefs.getString(_userCredentialsKey);

    if (credentialsJson != null) {
      try {
        final credentials = jsonDecode(credentialsJson) as Map<String, dynamic>;
        final timestamp = credentials['timestamp'] as int;
        final storedDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final now = DateTime.now();

        // Consider credentials valid for 30 days
        return now.difference(storedDate).inDays < 30;
      } catch (e) {
        print('Failed to check credentials validity: $e');
        return false;
      }
    }
    return false;
  }

  // Clear stored credentials
  static Future<void> clearStoredCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userCredentialsKey);
  }
}
