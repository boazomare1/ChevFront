import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:chevenergies/constants/app_version.dart';

class ChangelogService {
  static const String _lastSeenVersionKey = 'last_seen_changelog_version';

  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Check if changelog should be shown for current version
  static Future<bool> shouldShowChangelog() async {
    try {
      final lastSeenVersion = await _storage.read(key: _lastSeenVersionKey);

      // Show changelog if:
      // 1. User has never seen any changelog (lastSeenVersion is null)
      // 2. User hasn't seen the current version yet
      return lastSeenVersion == null || lastSeenVersion != AppVersion.currentVersion;
    } catch (e) {
      // If there's an error reading storage, show changelog to be safe
      return true;
    }
  }

  /// Mark current version as seen
  static Future<void> markVersionAsSeen() async {
    try {
      await _storage.write(key: _lastSeenVersionKey, value: AppVersion.currentVersion);
    } catch (e) {
      // Silently handle storage errors
      print('Error marking version as seen: $e');
    }
  }

  /// Get current app version
  static String getCurrentVersion() {
    return AppVersion.currentVersion;
  }

  /// Force show changelog (for testing or manual access)
  static Future<void> resetChangelogSeen() async {
    try {
      await _storage.delete(key: _lastSeenVersionKey);
    } catch (e) {
      print('Error resetting changelog seen status: $e');
    }
  }
}
