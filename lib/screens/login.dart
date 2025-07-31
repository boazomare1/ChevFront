import 'package:chevenergies/shared%20utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  String? _error;      // general ошибки

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

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      ),
    );

    try {
      await Provider.of<AppState>(context, listen: false)
          .login(email, pass);
      Navigator.pop(context); // close loader
    } catch (e) {
      Navigator.pop(context); // close loader
      showDialog(
        context: context,
        builder: (_) => const ErrorDialog(
          message: 'Authentication Failed - check your credentials',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final emailErrorText =
        _fieldError == 'email' ? 'Enter a valid email address' : null;
    final passErrorText =
        _fieldError == 'password' ? 'Password cannot be empty' : null;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(color: const Color(0xFF228B22), height: 20),
              const SizedBox(height: 150),
              Center(
                child: Card(
                  elevation: 8,
                  margin: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF228B22),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Image.asset(
                          'assets/logo.png',
                          height: 80,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.error, color: Colors.red),
                        ),
                        const SizedBox(height: 20),
                        // Email field with inline error
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            errorText: emailErrorText,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Password
                        StyledTextField(
                          label: 'Password',
                          controller: _passwordController,
                          obscureText: true,
                          keyboardType: TextInputType.visiblePassword,
                        ),
                        if (passErrorText != null) ...[
                          const SizedBox(height: 5),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              passErrorText,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 2, 97, 49),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.greenAccent,
                              ),
                            ),
                          ),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
