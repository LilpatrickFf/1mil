// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:solofit/models/user_profile.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get a stream of a single user's profile
  Stream<UserProfile> streamUserProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snapshot) {
      return UserProfile.fromFirestore(snapshot as DocumentSnapshot<Map<String, dynamic>>);
    });
  }

  // Get a single user's profile
  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserProfile.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
    }
    return null;
  }

  // Create or update a user's profile
  Future<void> saveUserProfile(UserProfile userProfile) async {
    await _db.collection('users').doc(userProfile.uid).set(userProfile.toFirestore(), SetOptions(merge: true));
  }

  // Delete a user's profile (use with caution)
  Future<void> deleteUserProfile(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }
}

