import 'package:chevenergies/shared%20utils/widgets.dart';
import 'package:chevenergies/shared utils/app_theme.dart';
import 'package:chevenergies/screens/stock_keeper_dashboard.dart';
import 'package:chevenergies/services/biometric_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/app_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _fieldError; // either 'email' or 'password'
  String? _error; // general ошибки
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _isLoadingCredentials = true;
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    _checkBiometricStatus();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    // simple regex
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('saved_email');
      final savedPassword = prefs.getString('saved_password');
      final rememberMe = prefs.getBool('remember_me') ?? false;

      if (mounted) {
        setState(() {
          if (savedEmail != null && savedPassword != null && rememberMe) {
            _emailController.text = savedEmail;
            _passwordController.text = savedPassword;
            _rememberMe = true;
          }
          _isLoadingCredentials = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCredentials = false;
        });
      }
    }
  }

  Future<void> _saveCredentials() async {
    if (!_rememberMe) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_email', _emailController.text.trim());
      await prefs.setString('saved_password', _passwordController.text);
      await prefs.setBool('remember_me', true);
    } catch (e) {
      // Silently handle save errors
    }
  }

  Future<void> _clearSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
      await prefs.setBool('remember_me', false);
      // Also clear from BiometricService
      await BiometricService.disableBiometric();
    } catch (e) {
      // Silently handle clear errors
    }
  }

  Future<void> _login() async {
    setState(() => _fieldError = null);

    final email = _emailController.text.trim();
    final pass = _passwordController.text;

    if (email.isEmpty || pass.isEmpty) {
      setState(() => _fieldError = email.isEmpty ? 'email' : 'password');
      return;
    }
    if (!_isValidEmail(email)) {
      setState(() => _fieldError = 'email');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Provider.of<AppState>(context, listen: false).login(email, pass);

      // Save credentials if "Remember Me" is checked
      if (_rememberMe) {
        print('🔐 Saving credentials to SharedPreferences...');
        await _saveCredentials();
        print('🔐 Saving credentials to BiometricService...');
        // Also save to BiometricService for fingerprint authentication
        await BiometricService.enableBiometric(email, pass);
        setState(() => _isBiometricEnabled = true);
        print('🔐 Credentials saved successfully!');
      } else {
        print('🔐 Clearing credentials...');
        await _clearSavedCredentials();
        // Also clear from BiometricService
        await BiometricService.disableBiometric();
        setState(() => _isBiometricEnabled = false);
        print('🔐 Credentials cleared successfully!');
      }

      // Check if widget is still mounted before proceeding
      if (!mounted) return;

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);

        // For testing: Redirect to stock keeper dashboard on login failure
        // In production, this would show the error dialog instead
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StockKeeperDashboard()),
        );

        // Uncomment the following lines for production error handling:
        // showDialog(
        //   context: context,
        //   builder:
        //       (_) => const ErrorDialog(
        //         message: 'Authentication Failed - check your credentials',
        //       ),
        // );
      }
    }
  }

  Future<void> _checkBiometricStatus() async {
    final isAvailable = await BiometricService.isBiometricAvailable();
    final isEnabled = await BiometricService.isBiometricEnabled();

    if (mounted) {
      setState(() {
        _isBiometricAvailable = isAvailable;
        _isBiometricEnabled = isEnabled;
      });
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    setState(() => _isLoading = true);

    try {
      print('🔐 Starting biometric authentication...');

      // First authenticate with biometrics
      final biometricSuccess =
          await BiometricService.authenticateWithBiometrics();

      print('🔐 Biometric authentication result: $biometricSuccess');

      if (!biometricSuccess) {
        setState(() => _isLoading = false);
        return;
      }

      // Get stored credentials
      final credentials = await BiometricService.getStoredCredentials();
      print(
        '🔐 Retrieved credentials: ${credentials != null ? 'Found' : 'Not found'}',
      );

      if (credentials == null) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No stored credentials found. Please login manually first.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Check if credentials are still valid
      final areValid = await BiometricService.areCredentialsValid();
      print('🔐 Credentials validity: $areValid');

      if (!areValid) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Stored credentials have expired. Please login manually.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      print('🔐 Attempting login with stored credentials...');

      // Login with stored credentials
      await Provider.of<AppState>(
        context,
        listen: false,
      ).login(credentials['email']!, credentials['password']!);

      print('🔐 Login successful!');

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      print('🔐 Biometric login error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Biometric login failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final emailErrorText =
        _fieldError == 'email' ? 'Enter a valid email address' : null;
    final passErrorText =
        _fieldError == 'password' ? 'Password cannot be empty' : null;

    // Show loading screen while credentials are being loaded
    if (_isLoadingCredentials) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const CircularProgressIndicator(
                  color: AppTheme.primaryColor,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Loading...',
                style: AppTheme.headingMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Image.asset(
                        'assets/logo.png',
                        height: 60,
                        width: 60,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'POWER GAS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Welcome back!',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Login form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Container(
                decoration: AppTheme.cardDecoration,
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('LOGIN', style: AppTheme.headingMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your credentials to continue',
                      style: AppTheme.bodySmall,
                    ),
                    const SizedBox(height: 30),

                    // Email field
                    StyledTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email),
                      validator: (value) => emailErrorText,
                    ),
                    const SizedBox(height: 20),

                    // Password field
                    StyledTextField(
                      controller: _passwordController,
                      label: 'Password',
                      obscureText: true,
                      prefixIcon: const Icon(Icons.lock),
                      validator: (value) => passErrorText,
                    ),
                    const SizedBox(height: 20),

                    // Remember Me checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                          activeColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _rememberMe = !_rememberMe;
                              });
                            },
                            child: Text(
                              'Remember Me',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Login button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: AppTheme.primaryButtonStyle,
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text(
                                  'SIGN IN',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                      ),
                    ),

                    // Biometric authentication section
                    if (_isBiometricAvailable) ...[
                      const SizedBox(height: 20),

                      // Divider with "OR" text
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppTheme.textLight)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: AppTheme.textLight)),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Fingerprint button
                      if (_isBiometricEnabled) ...[
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed:
                                _isLoading ? null : _authenticateWithBiometrics,
                            icon: const Icon(Icons.fingerprint, size: 24),
                            label: const Text(
                              'Login with Fingerprint',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              side: BorderSide(color: AppTheme.primaryColor),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.fingerprint,
                                color: AppTheme.primaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Login once to enable fingerprint authentication',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
