// lib/models/user_profile.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum Gender { male, female, other }
enum FitnessLevel { beginner, intermediate, advanced }
enum WorkoutLocation { home, gym, outdoor }
enum TargetPhysique { lean, ripped, bulky, athletic, custom }

class UserProfile {
  final String uid;
  String email;
  String? displayName;
  String? photoUrl;

  // Onboarding data
  int? age;
  double? heightCm;
  double? weightKg;
  Gender? gender;
  FitnessLevel? fitnessLevel;
  List<String>? availableEquipment; // e.g., ['dumbbells', 'resistance_bands']
  WorkoutLocation? workoutLocation;
  int? timeCommitmentMinutes;
  String? currentPhysiquePhotoUrl; // URL to Firebase Storage
  TargetPhysique? targetPhysiquePreset;
  String? targetPhysiquePhotoUrl; // URL to Firebase Storage if custom
  String? country; // For localized meal plans

  // AI Analysis results
  double? bodyFatPercentage;
  Map<String, double>? muscleBalance; // e.g., {'chest': 0.8, 'back': 0.9}
  List<String>? postureIssues; // e.g., ['rounded_shoulders', 'anterior_pelvic_tilt']

  // Gamification data
  String currentRank;
  int exp;
  int level;
  Map<String, int>? stats; // e.g., {'strength': 10, 'agility': 8}

  UserProfile({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.age,
    this.heightCm,
    this.weightKg,
    this.gender,
    this.fitnessLevel,
    this.availableEquipment,
    this.workoutLocation,
    this.timeCommitmentMinutes,
    this.currentPhysiquePhotoUrl,
    this.targetPhysiquePreset,
    this.targetPhysiquePhotoUrl,
    this.country,
    this.bodyFatPercentage,
    this.muscleBalance,
    this.postureIssues,
    this.currentRank = 'F',
    this.exp = 0,
    this.level = 1,
    this.stats,
  });

  // Convert UserProfile object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'age': age,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'gender': gender?.name,
      'fitnessLevel': fitnessLevel?.name,
      'availableEquipment': availableEquipment,
      'workoutLocation': workoutLocation?.name,
      'timeCommitmentMinutes': timeCommitmentMinutes,
      'currentPhysiquePhotoUrl': currentPhysiquePhotoUrl,
      'targetPhysiquePreset': targetPhysiquePreset?.name,
      'targetPhysiquePhotoUrl': targetPhysiquePhotoUrl,
      'country': country,
      'bodyFatPercentage': bodyFatPercentage,
      'muscleBalance': muscleBalance,
      'postureIssues': postureIssues,
      'currentRank': currentRank,
      'exp': exp,
      'level': level,
      'stats': stats,
    };
  }

  // Create UserProfile object from a Firestore Map
  factory UserProfile.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) {
      throw StateError('Missing data for UserProfile');
    }
    return UserProfile(
      uid: snapshot.id,
      email: data['email'] as String,
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      age: data['age'] as int?,
      heightCm: (data['heightCm'] as num?)?.toDouble(),
      weightKg: (data['weightKg'] as num?)?.toDouble(),
      gender: data['gender'] != null ? Gender.values.byName(data['gender']) : null,
      fitnessLevel: data['fitnessLevel'] != null ? FitnessLevel.values.byName(data['fitnessLevel']) : null,
      availableEquipment: (data['availableEquipment'] as List<dynamic>?)?.map((e) => e as String).toList(),
      workoutLocation: data['workoutLocation'] != null ? WorkoutLocation.values.byName(data['workoutLocation']) : null,
      timeCommitmentMinutes: data['timeCommitmentMinutes'] as int?,
      currentPhysiquePhotoUrl: data['currentPhysiquePhotoUrl'] as String?,
      targetPhysiquePreset: data['targetPhysiquePreset'] != null ? TargetPhysique.values.byName(data['targetPhysiquePreset']) : null,
      targetPhysiquePhotoUrl: data['targetPhysiquePhotoUrl'] as String?,
      country: data['country'] as String?,
      bodyFatPercentage: (data['bodyFatPercentage'] as num?)?.toDouble(),
      muscleBalance: (data['muscleBalance'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(key, (value as num).toDouble())),
      postureIssues: (data['postureIssues'] as List<dynamic>?)?.map((e) => e as String).toList(),
      currentRank: data['currentRank'] as String? ?? 'F',
      exp: data['exp'] as int? ?? 0,
      level: data['level'] as int? ?? 1,
      stats: (data['stats'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(key, value as int)),
    );
  }

  // Helper to update specific fields
  UserProfile copyWith({
    String? email,
    String? displayName,
    String? photoUrl,
    int? age,
    double? heightCm,
    double? weightKg,
    Gender? gender,
    FitnessLevel? fitnessLevel,
    List<String>? availableEquipment,
    WorkoutLocation? workoutLocation,
    int? timeCommitmentMinutes,
    String? currentPhysiquePhotoUrl,
    TargetPhysique? targetPhysiquePreset,
    String? targetPhysiquePhotoUrl,
    String? country,
    double? bodyFatPercentage,
    Map<String, double>? muscleBalance,
    List<String>? postureIssues,
    String? currentRank,
    int? exp,
    int? level,
    Map<String, int>? stats,
  }) {
    return UserProfile(
      uid: uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      gender: gender ?? this.gender,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      availableEquipment: availableEquipment ?? this.availableEquipment,
      workoutLocation: workoutLocation ?? this.workoutLocation,
      timeCommitmentMinutes: timeCommitmentMinutes ?? this.timeCommitmentMinutes,
      currentPhysiquePhotoUrl: currentPhysiquePhotoUrl ?? this.currentPhysiquePhotoUrl,
      targetPhysiquePreset: targetPhysiquePreset ?? this.targetPhysiquePreset,
      targetPhysiquePhotoUrl: targetPhysiquePhotoUrl ?? this.targetPhysiquePhotoUrl,
      country: country ?? this.country,
      bodyFatPercentage: bodyFatPercentage ?? this.bodyFatPercentage,
      muscleBalance: muscleBalance ?? this.muscleBalance,
      postureIssues: postureIssues ?? this.postureIssues,
      currentRank: currentRank ?? this.currentRank,
      exp: exp ?? this.exp,
      level: level ?? this.level,
      stats: stats ?? this.stats,
    );
  }
}

