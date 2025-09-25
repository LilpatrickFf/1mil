// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:solofit/api/api_keys.dart'; // Your API keys
import 'package:solofit/auth/auth_service.dart';
import 'package:solofit/screens/home_screen.dart';
import 'package:solofit/screens/onboarding/welcome_screen.dart';
import 'package:provider/provider';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:solofit/screens/onboarding/user_details_screen.dart'; // New import
import 'package:solofit/services/firestore_service.dart'; // New import
import 'package:solofit/models/user_profile.dart'; // New import

// Main function to run the app
void main() async {
  // Ensure Flutter is ready
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using your API keys
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: ApiKeys.firebaseApiKey,
      authDomain: ApiKeys.firebaseAuthDomain,
      projectId: ApiKeys.firebaseProjectId,
      storageBucket: ApiKeys.firebaseStorageBucket,
      messagingSenderId: ApiKeys.firebaseMessagingSenderId,
      appId: ApiKeys.firebaseAppId,
    ),
  );

  runApp(const SoloFitApp());
}

class SoloFitApp extends StatelessWidget {
  const SoloFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Using MultiProvider to make auth service available throughout the app
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(FirebaseAuth.instance),
        ),
        StreamProvider<User?>(
          create: (context) => context.read<AuthService>().authStateChanges,
          initialData: null,
        ),
        Provider<FirestoreService>(
          create: (_) => FirestoreService(),
        ), // New: Provide FirestoreService
      ],
      child: MaterialApp(
        title: 'SoloFit',
        // Define the futuristic, dark, neon-purple theme
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF8A2BE2), // Neon Purple
          scaffoldBackgroundColor: const Color(0xFF121212), // Very dark background
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFBB86FC), // Lighter Purple for buttons/highlights
            secondary: Color(0xFF03DAC6), // Teal accent
            surface: Color(0xFF1E1E1E), // Card backgrounds
            onPrimary: Colors.black,
            onSecondary: Colors.black,
            onBackground: Colors.white,
            onSurface: Colors.white,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(fontFamily: 'Orbitron', color: Colors.white),
            bodyMedium: TextStyle(fontFamily: 'Orbitron', color: Colors.white70),
            headlineLarge: TextStyle(fontFamily: 'Orbitron', fontWeight: FontWeight.bold, color: Color(0xFFBB86FC)),
            headlineMedium: TextStyle(fontFamily: 'Orbitron', fontWeight: FontWeight.bold, color: Color(0xFFBB86FC)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBB86FC),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(fontFamily: 'Orbitron', fontWeight: FontWeight.bold),
            ),
          ),
        ),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// This widget checks if the user is logged in and shows the correct screen.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();

    if (firebaseUser != null) {
      // If user is logged in, check if their profile is complete
      return FutureBuilder<UserProfile?>(
        future: Provider.of<FirestoreService>(context, listen: false).getUserProfile(firebaseUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData && snapshot.data?.age != null) {
            // User has completed onboarding
            return const HomeScreen();
          } else {
            // User has not completed onboarding
            return const UserDetailsScreen();
          }
        },
      );
    }
    // If user is not logged in, show WelcomeScreen
    return const WelcomeScreen();
  }
}

