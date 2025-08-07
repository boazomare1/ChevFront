import 'package:chevenergies/shared utils/app_theme.dart';
import 'package:chevenergies/services/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = true;
  bool _darkModeEnabled = false;
  bool _autoSyncEnabled = true;
  bool _locationServicesEnabled = true;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'KES';
  String _selectedTheme = 'Default';

  final List<String> _languages = ['English', 'Swahili', 'French', 'Spanish'];

  final List<String> _currencies = ['KES', 'USD', 'EUR', 'GBP'];

  final List<String> _themes = ['Default', 'Dark', 'Light', 'Custom'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: const Text(
          'SETTINGS',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.8),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'App Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Customize your experience',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Settings sections
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildAccountSection(),
                  const SizedBox(height: 20),
                  _buildPreferencesSection(),
                  const SizedBox(height: 20),
                  _buildSecuritySection(),
                  const SizedBox(height: 20),
                  _buildNotificationsSection(),
                  const SizedBox(height: 20),
                  _buildDataSection(),
                  const SizedBox(height: 20),
                  _buildAboutSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          _buildSectionHeader('ACCOUNT', Icons.person),
          _buildSettingTile(
            icon: Icons.person_outline,
            title: 'Profile Information',
            subtitle: 'Update your personal details',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile settings coming soon!'),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.email_outlined,
            title: 'Email Address',
            subtitle: 'stockkeeper@chevenergies.com',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Email settings coming soon!'),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.phone_outlined,
            title: 'Phone Number',
            subtitle: '+254 700 123 456',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Phone settings coming soon!'),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          _buildSectionHeader('PREFERENCES', Icons.tune),
          _buildDropdownTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: _selectedLanguage,
            items: _languages,
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value!;
              });
            },
          ),
          _buildDivider(),
          _buildDropdownTile(
            icon: Icons.attach_money,
            title: 'Currency',
            subtitle: _selectedCurrency,
            items: _currencies,
            onChanged: (value) {
              setState(() {
                _selectedCurrency = value!;
              });
            },
          ),
          _buildDivider(),
          _buildDropdownTile(
            icon: Icons.palette,
            title: 'Theme',
            subtitle: _selectedTheme,
            items: _themes,
            onChanged: (value) {
              setState(() {
                _selectedTheme = value!;
              });
            },
          ),
          _buildDivider(),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return _buildSwitchTile(
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                subtitle: 'Use dark theme',
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          _buildSectionHeader('SECURITY', Icons.security),
          _buildSettingTile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your password',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password change coming soon!'),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.fingerprint,
            title: 'Biometric Login',
            subtitle: 'Use fingerprint or face ID',
            value: _biometricEnabled,
            onChanged: (value) {
              setState(() {
                _biometricEnabled = value;
              });
            },
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.vpn_key_outlined,
            title: 'Two-Factor Authentication',
            subtitle: 'Add extra security',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('2FA settings coming soon!'),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          _buildSectionHeader('NOTIFICATIONS', Icons.notifications),
          _buildSwitchTile(
            icon: Icons.notifications_active,
            title: 'Push Notifications',
            subtitle: 'Receive app notifications',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.notifications_outlined,
            title: 'Notification Settings',
            subtitle: 'Customize notification types',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notification settings coming soon!'),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection() {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          _buildSectionHeader('DATA & SYNC', Icons.sync),
          _buildSwitchTile(
            icon: Icons.sync,
            title: 'Auto Sync',
            subtitle: 'Automatically sync data',
            value: _autoSyncEnabled,
            onChanged: (value) {
              setState(() {
                _autoSyncEnabled = value;
              });
            },
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.location_on_outlined,
            title: 'Location Services',
            subtitle: 'Use location for tracking',
            value: _locationServicesEnabled,
            onChanged: (value) {
              setState(() {
                _locationServicesEnabled = value;
              });
            },
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.backup_outlined,
            title: 'Backup Data',
            subtitle: 'Backup to cloud storage',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Backup feature coming soon!'),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.delete_outline,
            title: 'Clear Cache',
            subtitle: 'Free up storage space',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          _buildSectionHeader('ABOUT', Icons.info),
          _buildSettingTile(
            icon: Icons.info_outline,
            title: 'App Version',
            subtitle: 'v1.0.0 (Build 2024.1.1)',
            onTap: null,
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            subtitle: 'Read our terms and conditions',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Terms of Service coming soon!'),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'How we handle your data',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Privacy Policy coming soon!'),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Help & Support coming soon!'),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
          ),
          _buildDivider(),
          // Version and Copyright Information
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'App Information',
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Version 2.08.2025',
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Chev Energies - LPG Sales Management System',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '© ${DateTime.now().year} Techsavanna Software Technologies',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'All Rights Reserved',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          // Launch website URL
                          final url = 'https://techsavanna.co.ke/';
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url));
                          }
                        },
                        child: Text(
                          'techsavanna.co.ke',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: AppTheme.headingSmall.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
      ),
      trailing:
          onTap != null
              ? const Icon(Icons.chevron_right, color: AppTheme.textSecondary)
              : null,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
      ),
      trailing: DropdownButton<String>(
        value: subtitle,
        underline: Container(),
        items:
            items.map((item) {
              return DropdownMenuItem(value: item, child: Text(item));
            }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 60, endIndent: 16);
  }
}
