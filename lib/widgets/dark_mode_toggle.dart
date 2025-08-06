import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chevenergies/services/theme_provider.dart';
import 'package:chevenergies/shared utils/app_theme.dart';

class DarkModeToggle extends StatelessWidget {
  const DarkModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return SwitchListTile(
          title: const Text('Dark Mode'),
          subtitle: const Text('Switch between light and dark themes'),
          value: themeProvider.isDarkMode,
          onChanged: (value) {
            themeProvider.toggleTheme();
          },
          secondary: Icon(
            themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: AppTheme.primaryColor,
          ),
        );
      },
    );
  }
}
