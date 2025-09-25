import 'package:flutter/material.dart';
import 'package:provider/provider';
import 'package:solofit/models/user_profile.dart';
import 'package:solofit/services/firestore_service.dart';
import 'package:solofit/widgets/aura_background.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:solofit/screens/onboarding/physique_upload_screen.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _age;
  double? _heightCm;
  double? _weightKg;
  Gender? _gender;
  FitnessLevel? _fitnessLevel;
  String? _country;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle case where user is not logged in, maybe navigate back to welcome
      return const Center(child: Text('User not logged in'));
    }

    return Scaffold(
      body: AuraBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Your Core Data',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The Codex requires your fundamental data to begin your Combat Protocol.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),

                  // Age
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your age';
                      }
                      if (int.tryParse(value) == null || int.parse(value) <= 0) {
                        return 'Please enter a valid age';
                      }
                      return null;
                    },
                    onSaved: (value) => _age = int.parse(value!),
                  ),
                  const SizedBox(height: 16),

                  // Height
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Height (cm)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your height';
                      }
                      if (double.tryParse(value) == null || double.parse(value) <= 0) {
                        return 'Please enter a valid height';
                      }
                      return null;
                    },
                    onSaved: (value) => _heightCm = double.parse(value!),
                  ),
                  const SizedBox(height: 16),

                  // Weight
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Weight (kg)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your weight';
                      }
                      if (double.tryParse(value) == null || double.parse(value) <= 0) {
                        return 'Please enter a valid weight';
                      }
                      return null;
                    },
                    onSaved: (value) => _weightKg = double.parse(value!),
                  ),
                  const SizedBox(height: 16),

                  // Gender
                  DropdownButtonFormField<Gender>(
                    decoration: const InputDecoration(labelText: 'Gender'),
                    value: _gender,
                    items: Gender.values.map((Gender gender) {
                      return DropdownMenuItem<Gender>(
                        value: gender,
                        child: Text(gender.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (Gender? newValue) {
                      setState(() {
                        _gender = newValue;
                      });
                    },
                    validator: (value) => value == null ? 'Please select your gender' : null,
                  ),
                  const SizedBox(height: 16),

                  // Fitness Level
                  DropdownButtonFormField<FitnessLevel>(
                    decoration: const InputDecoration(labelText: 'Fitness Level'),
                    value: _fitnessLevel,
                    items: FitnessLevel.values.map((FitnessLevel level) {
                      return DropdownMenuItem<FitnessLevel>(
                        value: level,
                        child: Text(level.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (FitnessLevel? newValue) {
                      setState(() {
                        _fitnessLevel = newValue;
                      });
                    },
                    validator: (value) => value == null ? 'Please select your fitness level' : null,
                  ),
                  const SizedBox(height: 16),

                  // Country (for localized meal plans)
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Country (for localized meal plans)'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your country';
                      }
                      return null;
                    },
                    onSaved: (value) => _country = value!,
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        final firestoreService = Provider.of<FirestoreService>(context, listen: false);
                        final userProfile = UserProfile(
                          uid: user.uid,
                          email: user.email!,
                          age: _age,
                          heightCm: _heightCm,
                          weightKg: _weightKg,
                          gender: _gender,
                          fitnessLevel: _fitnessLevel,
                          country: _country,
                        );
                        await firestoreService.saveUserProfile(userProfile);

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PhysiqueUploadScreen()),
                        );
                      }
                    },
                    child: const Text('CONTINUE'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

