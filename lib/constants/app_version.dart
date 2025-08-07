class AppVersion {
  // Current app version - update this for each release
  static const String currentVersion = '2.08.2025+208';
  
  // Version display name (without build number)
  static const String displayVersion = '2.08.2025';
  
  // Build number
  static const int buildNumber = 208;
  
  // Release date
  static const String releaseDate = 'August 7, 2025';
  
  // Release notes for this version
  static const List<String> releaseNotes = [
    '🎫 Added Ticket Sales screen with backend API integration',
    '📊 Added status count cards (Pending, Approved, Rejected)',
    '📅 Added date filtering for tickets (defaults to today)',
    '🛒 Added resale functionality for rejected tickets',
    '📸 Added camera capture for shop images',
    '👥 Fixed customers screen to show today\'s customers',
    '🔄 Added changelog system for version updates',
    '🏢 Added Techsavanna branding with dynamic year',
    '🔧 Improved app performance and stability',
  ];
  
  // Get version info for display
  static Map<String, dynamic> getVersionInfo() {
    return {
      'version': currentVersion,
      'displayVersion': displayVersion,
      'buildNumber': buildNumber,
      'releaseDate': releaseDate,
      'releaseNotes': releaseNotes,
    };
  }
} 