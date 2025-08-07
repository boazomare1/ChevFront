import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Keys for secure storage
  static const String _savedEmailKey = 'saved_email';
  static const String _savedPasswordKey = 'saved_password';
  static const String _savedFirstNameKey = 'saved_first_name';
  static const String _savedLastNameKey = 'saved_last_name';
  static const String _rememberMeKey = 'remember_me';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _userCredentialsKey = 'user_credentials';

  // Save credentials for "Remember Me" feature
  static Future<void> saveCredentials(
    String email,
    String password,
    String? firstName,
    String? lastName,
  ) async {
    try {
      await _secureStorage.write(key: _savedEmailKey, value: email);
      await _secureStorage.write(key: _savedPasswordKey, value: password);
      await _secureStorage.write(
        key: _savedFirstNameKey,
        value: firstName ?? '',
      );
      await _secureStorage.write(key: _savedLastNameKey, value: lastName ?? '');
      await _secureStorage.write(key: _rememberMeKey, value: 'true');
    } catch (e) {
      print('Failed to save credentials securely: $e');
      rethrow;
    }
  }

  // Load saved credentials
  static Future<Map<String, dynamic>> loadCredentials() async {
    try {
      final email = await _secureStorage.read(key: _savedEmailKey);
      final password = await _secureStorage.read(key: _savedPasswordKey);
      final firstName = await _secureStorage.read(key: _savedFirstNameKey);
      final lastName = await _secureStorage.read(key: _savedLastNameKey);
      final rememberMe = await _secureStorage.read(key: _rememberMeKey);

      return {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'rememberMe': rememberMe == 'true',
      };
    } catch (e) {
      print('Failed to load credentials: $e');
      return {
        'email': null,
        'password': null,
        'firstName': null,
        'lastName': null,
        'rememberMe': false,
      };
    }
  }

  // Clear saved credentials
  static Future<void> clearCredentials() async {
    try {
      await _secureStorage.delete(key: _savedEmailKey);
      await _secureStorage.delete(key: _savedPasswordKey);
      await _secureStorage.delete(key: _savedFirstNameKey);
      await _secureStorage.delete(key: _savedLastNameKey);
      await _secureStorage.delete(key: _rememberMeKey);
    } catch (e) {
      print('Failed to clear credentials: $e');
    }
  }

  // Check if "Remember Me" is enabled
  static Future<bool> isRememberMeEnabled() async {
    try {
      final rememberMe = await _secureStorage.read(key: _rememberMeKey);
      return rememberMe == 'true';
    } catch (e) {
      print('Failed to check remember me status: $e');
      return false;
    }
  }

  // Save credentials for biometric authentication
  static Future<void> saveBiometricCredentials(
    String email,
    String password,
  ) async {
    try {
      final credentials = {
        'email': email,
        'password': password,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      await _secureStorage.write(
        key: _userCredentialsKey,
        value: jsonEncode(credentials),
      );
      await _secureStorage.write(key: _biometricEnabledKey, value: 'true');
    } catch (e) {
      print('Failed to save biometric credentials: $e');
      rethrow;
    }
  }

  // Get stored biometric credentials
  static Future<Map<String, String>?> getBiometricCredentials() async {
    try {
      final credentialsJson = await _secureStorage.read(
        key: _userCredentialsKey,
      );

      if (credentialsJson != null) {
        final credentials = jsonDecode(credentialsJson) as Map<String, dynamic>;
        return {
          'email': credentials['email'] as String,
          'password': credentials['password'] as String,
        };
      }
      return null;
    } catch (e) {
      print('Failed to get biometric credentials: $e');
      return null;
    }
  }

  // Check if biometric is enabled
  static Future<bool> isBiometricEnabled() async {
    try {
      final enabled = await _secureStorage.read(key: _biometricEnabledKey);
      return enabled == 'true';
    } catch (e) {
      print('Failed to check biometric status: $e');
      return false;
    }
  }

  // Disable biometric authentication
  static Future<void> disableBiometric() async {
    try {
      await _secureStorage.delete(key: _biometricEnabledKey);
      await _secureStorage.delete(key: _userCredentialsKey);
    } catch (e) {
      print('Failed to disable biometric: $e');
    }
  }

  // Check if stored credentials are still valid (not too old)
  static Future<bool> areBiometricCredentialsValid() async {
    try {
      final credentialsJson = await _secureStorage.read(
        key: _userCredentialsKey,
      );

      if (credentialsJson != null) {
        final credentials = jsonDecode(credentialsJson) as Map<String, dynamic>;
        final timestamp = credentials['timestamp'] as int;
        final storedDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final now = DateTime.now();

        // Consider credentials valid for 30 days
        return now.difference(storedDate).inDays < 30;
      }
      return false;
    } catch (e) {
      print('Failed to check credentials validity: $e');
      return false;
    }
  }

  // Clear all stored data
  static Future<void> clearAllData() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      print('Failed to clear all data: $e');
    }
  }
}
