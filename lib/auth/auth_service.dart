// lib/auth/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;

  AuthService(this._firebaseAuth);

  // Stream to notify the app about authentication state changes (login/logout)
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Signs in a user with email and password.
  /// Returns a success message or an error message.
  Future<String> signIn({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return "Success: Logged In";
    } on FirebaseAuthException catch (e) {
      // Provide user-friendly error messages
      if (e.code == 'user-not-found') {
        return 'Error: No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Error: Incorrect password provided.';
      }
      return 'Error: Login failed. Please try again.';
    }
  }

  /// Creates a new user account with email and password.
  /// Returns a success message or an error message.
  Future<String> signUp({required String email, required String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      return "Success: Account Created";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'Error: The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'Error: An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        return 'Error: The email address is not valid.';
      }
      return 'Error: Sign up failed. Please try again.';
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Gets the current logged-in user.
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}

