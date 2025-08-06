import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme Colors
  static const Color lightPrimaryColor = Colors.pinkAccent;
  static const Color lightSecondaryColor = Colors.orange;
  static const Color lightSuccessColor = Colors.green;
  static const Color lightErrorColor = Colors.red;
  static const Color lightWarningColor = Colors.orange;
  static const Color lightInfoColor = Colors.blue;
  static const Color lightBackgroundColor = Color(0xFFF5F5F5);
  static const Color lightCardColor = Colors.white;
  static const Color lightTextPrimary = Color(0xFF2C3E50);
  static const Color lightTextSecondary = Color(0xFF7F8C8D);
  static const Color lightTextLight = Color(0xFFBDC3C7);
  static const Color lightSurfaceColor = Colors.white;
  static const Color lightDividerColor = Color(0xFFE0E0E0);

  // Dark Theme Colors
  static const Color darkPrimaryColor = Colors.pinkAccent;
  static const Color darkSecondaryColor = Colors.orange;
  static const Color darkSuccessColor = Colors.green;
  static const Color darkErrorColor = Colors.red;
  static const Color darkWarningColor = Colors.orange;
  static const Color darkInfoColor = Colors.blue;
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkCardColor = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextLight = Color(0xFF808080);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color darkDividerColor = Color(0xFF404040);

  // Static colors for backward compatibility (use these in screens)
  static const Color primaryColor = lightPrimaryColor;
  static const Color secondaryColor = lightSecondaryColor;
  static const Color successColor = lightSuccessColor;
  static const Color errorColor = lightErrorColor;
  static const Color warningColor = lightWarningColor;
  static const Color infoColor = lightInfoColor;
  static const Color backgroundColor = lightBackgroundColor;
  static const Color cardColor = lightCardColor;
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color textLight = lightTextLight;
  static const Color surfaceColor = lightSurfaceColor;
  static const Color dividerColor = lightDividerColor;

  // Helper method to get colors from BuildContext (preferred method)
  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  static Color getCardColor(BuildContext context) {
    return Theme.of(context).cardColor;
  }

  static Color getTextPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color getTextSecondaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withOpacity(0.7);
  }

  // Theme mode flag (will be set by theme provider)
  static bool _isDarkMode = false;

  static void setDarkMode(bool isDark) {
    _isDarkMode = isDark;
  }

  // Theme Data
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: lightPrimaryColor,
    scaffoldBackgroundColor: lightBackgroundColor,
    cardColor: lightCardColor,
    dividerColor: lightDividerColor,
    colorScheme: const ColorScheme.light(
      primary: lightPrimaryColor,
      secondary: lightSecondaryColor,
      surface: lightSurfaceColor,
      background: lightBackgroundColor,
      error: lightErrorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: lightTextPrimary,
      onBackground: lightTextPrimary,
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightPrimaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      color: lightCardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightDividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightDividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightPrimaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightPrimaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: darkPrimaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    cardColor: darkCardColor,
    dividerColor: darkDividerColor,
    colorScheme: const ColorScheme.dark(
      primary: darkPrimaryColor,
      secondary: darkSecondaryColor,
      surface: darkSurfaceColor,
      background: darkBackgroundColor,
      error: darkErrorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: darkTextPrimary,
      onBackground: darkTextPrimary,
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkPrimaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      color: darkCardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkDividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkDividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkPrimaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    ),
  );

  // Text Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: textSecondary,
    letterSpacing: 0.5,
  );

  // App Bar Style
  static AppBar appBarStyle({
    required String title,
    List<Widget>? actions,
    bool centerTitle = true,
    bool showBackButton = true,
  }) {
    return AppBar(
      backgroundColor: primaryColor,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          letterSpacing: 0.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevation: 0,
      centerTitle: centerTitle,
      actions: actions,
      automaticallyImplyLeading: showBackButton,
    );
  }

  // Card Style
  static const BoxDecoration cardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.all(Radius.circular(16)),
    boxShadow: [
      BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
    ],
  );

  // Status Chip Style
  static Widget statusChip(String status) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'approved':
        color = successColor;
        icon = Icons.check_circle;
        break;
      case 'pending':
        color = warningColor;
        icon = Icons.schedule;
        break;
      case 'rejected':
        color = errorColor;
        icon = Icons.cancel;
        break;
      case 'processing':
        color = infoColor;
        icon = Icons.sync;
        break;
      default:
        color = textLight;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // Header Section Style
  static Widget headerSection({
    required String title,
    required String subtitle,
    Widget? statusChip,
    List<Widget>? stats,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (statusChip != null) ...[statusChip, const SizedBox(height: 16)],
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (stats != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: stats,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Stat Item Style
  static Widget statItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // FAB Style
  static Widget modernFAB({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  // Empty State Style
  static Widget emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(icon, size: 60, color: Colors.grey[400]),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: textLight),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Input Field Style
  static InputDecoration inputDecoration({
    required String label,
    IconData? prefixIcon,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    );
  }

  // Button Styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
  );

  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFE0E0E0),
    foregroundColor: textPrimary,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 0,
  );
}
