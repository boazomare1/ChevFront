import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';

class ChangelogViewer extends StatelessWidget {
  final VoidCallback? onSkipToLogin;
  final bool showSkipButton;

  const ChangelogViewer({
    Key? key,
    this.onSkipToLogin,
    this.showSkipButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.isDarkMode ? Colors.grey[900] : Colors.grey[50],
          appBar: AppBar(
            title: const Text('What\'s New', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
            foregroundColor: themeProvider.isDarkMode ? Colors.white : Colors.black,
            elevation: 0,
            actions: [
              if (showSkipButton && onSkipToLogin != null)
                TextButton(
                  onPressed: onSkipToLogin,
                  child: Text('Skip', style: TextStyle(
                    color: themeProvider.isDarkMode ? Colors.blue[300] : Colors.blue[600],
                    fontWeight: FontWeight.w600,
                  )),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, themeProvider),
                const SizedBox(height: 24),
                _buildVersionSection(context, 'v2.08.2025', 'August 7, 2025', [
                  '🚀 Client-Ready Delivery Package with multiple file formats',
                  '📱 New Changelog Viewer feature',
                  '📄 Enhanced documentation in text format',
                  '🔧 Fixed release APK login issues',
                  '🏢 Added Techsavanna Software Technologies branding',
                  '📅 Dynamic year display in copyright notices',
                  '📋 Updated PDF invoices with company information',
                  '⚙️ Enhanced app settings with company details',
                  '👥 Fixed customers screen to show today\'s customers with correct day format',
                  '📸 Added camera capture functionality for shop images',
                ], themeProvider),
                const SizedBox(height: 20),
                _buildVersionSection(context, 'v2.07.2025', 'August 6, 2025', [
                  '🔐 Enhanced fingerprint authentication',
                  '👤 Improved customer logo preview system',
                  '💰 Better payment processing with cheque support',
                  '📊 Enhanced sales analytics and reporting',
                  '🎨 Complete dark mode implementation',
                  '📦 Stock keeper dashboard improvements',
                  '🔒 Enhanced security with encrypted storage',
                ], themeProvider),
                const SizedBox(height: 20),
                _buildVersionSection(context, 'v2.06.2025', 'August 5, 2025', [
                  '🛒 Smart product management in sales',
                  '📱 Personalized login experience',
                  '👥 Customer logo integration from API',
                  '📈 Enhanced inventory analytics',
                  '🔧 Improved error handling',
                  '⚡ Performance optimizations',
                ], themeProvider),
                const SizedBox(height: 32),
                _buildFooter(context, themeProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: themeProvider.isDarkMode 
            ? [Colors.blue[800]!, Colors.blue[600]!]
            : [Colors.blue[600]!, Colors.blue[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.new_releases, size: 48, color: Colors.white),
          const SizedBox(height: 12),
          const Text(
            'Chev Energies v2.08.2025',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Latest Updates & Improvements',
            style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionSection(BuildContext context, String version, String date, List<String> changes, ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode ? Colors.blue[700] : Colors.blue[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(version, style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.blue[700],
                  )),
                ),
                const SizedBox(width: 12),
                Text(date, style: TextStyle(
                  fontSize: 14,
                  color: themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                )),
              ],
            ),
            const SizedBox(height: 12),
            ...changes.map((change) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(
                    fontSize: 16,
                    color: themeProvider.isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  )),
                  Expanded(child: Text(change, style: TextStyle(
                    fontSize: 14,
                    color: themeProvider.isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    height: 1.4,
                  ))),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text('© ${DateTime.now().year} Techsavanna Software Technologies', style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600,
            color: themeProvider.isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text('All Rights Reserved', style: TextStyle(
            fontSize: 12,
            color: themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('techsavanna.co.ke', style: TextStyle(
            fontSize: 12,
            color: themeProvider.isDarkMode ? Colors.blue[300] : Colors.blue[600],
            decoration: TextDecoration.underline,
          ), textAlign: TextAlign.center),
        ],
      ),
    );
  }
} 