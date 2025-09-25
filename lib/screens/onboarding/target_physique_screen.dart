import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:solofit/models/user_profile.dart';
import 'package:solofit/services/firestore_service.dart';
import 'package:solofit/widgets/aura_background.dart';
import 'package:solofit/screens/home_screen.dart'; // Or your next screen

class TargetPhysiqueScreen extends StatefulWidget {
  const TargetPhysiqueScreen({super.key});

  @override
  State<TargetPhysiqueScreen> createState() => _TargetPhysiqueScreenState();
}

class _TargetPhysiqueScreenState extends State<TargetPhysiqueScreen> {
  File? _imageFile;
  TargetPhysique? _selectedPreset;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        _selectedPreset = TargetPhysique.custom;
      }
    });
  }

  Future<void> _saveAndContinue() async {
    if (_selectedPreset == null) {
      // Show a warning that a selection is required
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a target physique or upload a custom image.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle error
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      final userProfile = (await firestoreService.getUserProfile(user.uid))!;
      String? downloadUrl;

      if (_imageFile != null) {
        final storageRef = FirebaseStorage.instance.ref().child('user_physiques/${user.uid}/target_physique.jpg');
        await storageRef.putFile(_imageFile!);
        downloadUrl = await storageRef.getDownloadURL();
      }

      await firestoreService.saveUserProfile(
        userProfile.copyWith(
          targetPhysiquePreset: _selectedPreset,
          targetPhysiquePhotoUrl: downloadUrl,
        ),
      );

      setState(() {
        _isLoading = false;
      });

      // Navigate to the next part of the app, e.g., the home screen or a summary screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Error saving target physique: $e');
      setState(() {
        _isLoading = false;
      });
      // Show error to user
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
                  'Target Physique',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'A goal is the first step towards Ascension. An Awakened without a target is merely adrift in the chaos. Define your future self.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),

                // Preset options
                ...TargetPhysique.values.where((p) => p != TargetPhysique.custom).map((preset) {
                  return RadioListTile<TargetPhysique>(
                    title: Text(preset.name.toUpperCase()),
                    value: preset,
                    groupValue: _selectedPreset,
                    onChanged: (TargetPhysique? value) {
                      setState(() {
                        _selectedPreset = value;
                        _imageFile = null; // Clear custom image if a preset is selected
                      });
                    },
                  );
                }).toList(),

                const SizedBox(height: 20),
                // Custom image upload
                _imageFile != null
                    ? Image.file(
                        _imageFile!,
                        height: 150,
                        fit: BoxFit.contain,
                      )
                    : Container(),
                OutlinedButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: const Text('UPLOAD CUSTOM TARGET'),
                  onPressed: _pickImage,
                ),

                const SizedBox(height: 32),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _saveAndContinue,
                        child: const Text('COMPLETE ONBOARDING'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

