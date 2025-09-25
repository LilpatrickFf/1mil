import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:solofit/models/user_profile.dart';
import 'package:solofit/services/firestore_service.dart';
import 'package:solofit/widgets/aura_background.dart';
import 'package:solofit/screens/onboarding/target_physique_screen.dart';

class PhysiqueUploadScreen extends StatefulWidget {
  const PhysiqueUploadScreen({super.key});

  @override
  State<PhysiqueUploadScreen> createState() => _PhysiqueUploadScreenState();
}

class _PhysiqueUploadScreenState extends State<PhysiqueUploadScreen> {
  File? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  Future<void> _uploadImageAndContinue() async {
    if (_imageFile == null) {
      // Optionally, allow skipping or show a warning
      _continueWithoutUpload();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle error: user not logged in
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final storageRef = FirebaseStorage.instance.ref().child('user_physiques/${user.uid}/current_physique.jpg');
      await storageRef.putFile(_imageFile!);
      final downloadUrl = await storageRef.getDownloadURL();

      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      final userProfile = (await firestoreService.getUserProfile(user.uid))!;
      await firestoreService.saveUserProfile(userProfile.copyWith(currentPhysiquePhotoUrl: downloadUrl));

      setState(() {
        _isLoading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TargetPhysiqueScreen()),
      );
    } catch (e) {
      print('Error uploading image: $e');
      setState(() {
        _isLoading = false;
      });
      // Show error to user
    }
  }

  void _continueWithoutUpload() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TargetPhysiqueScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuraBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Current Physique Scan',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload a photo for The Codex to perform a Status Analysis. (Faces are not needed for privacy).',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                _imageFile != null
                    ? Image.file(
                        _imageFile!,
                        height: 200,
                        fit: BoxFit.contain,
                      )
                    : Container(
                        height: 200,
                        color: Colors.grey.withOpacity(0.2),
                        child: const Icon(Icons.camera_alt, size: 50, color: Colors.white54),
                      ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('SELECT IMAGE'),
                ),
                const SizedBox(height: 32),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _uploadImageAndContinue,
                        child: const Text('CONTINUE'),
                      ),
                TextButton(
                  onPressed: _continueWithoutUpload,
                  child: const Text('SKIP FOR NOW'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

