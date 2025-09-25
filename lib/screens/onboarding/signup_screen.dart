// lib/screens/onboarding/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider';
import 'package:solofit/auth/auth_service.dart';
import 'package:solofit/widgets/aura_background.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  void _handleSignUp() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final result = await authService.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (result.startsWith('Success')) {
      // On successful signup, the AuthWrapper in main.dart will handle navigation
      // so we don't need to do anything here.
    } else {
      setState(() {
        _errorMessage = result; // Display the error message from the service
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuraBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create Your Account',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Begin your journey as an Awakened.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                // Email Field
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                // Password Field
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                // Display error message if any
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 8),
                // Sign Up Button
                ElevatedButton(
                  onPressed: _handleSignUp,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('CREATE ACCOUNT'),
                ),
                // Back button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back to Welcome'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

