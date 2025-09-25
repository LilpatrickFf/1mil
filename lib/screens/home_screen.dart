// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider';
import 'package:solofit/auth/auth_service.dart';
import 'package:solofit/widgets/aura_background.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuraBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome, Awakened!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await Provider.of<AuthService>(context, listen: false).signOut();
                },
                child: const Text('LOGOUT'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

