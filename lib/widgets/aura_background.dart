// lib/widgets/aura_background.dart

import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class AuraBackground extends StatelessWidget {
  final Widget child;

  const AuraBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The animated gradient background
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF121212), // Base dark color
            ),
          ),
        ),
        // Using Plasma renderer for a cool, moving aura effect
        PlasmaRenderer(
          type: PlasmaType.infinity,
          particles: 10,
          color: const Color(0x448A2BE2), // Semi-transparent neon purple
          blur: 0.4,
          size: 0.5,
          speed: 0.5,
          offset: 0,
          blendMode: BlendMode.plus,
          variation1: 0,
          variation2: 0,
          variation3: 0,
          rotation: 0.0,
        ),
        // The actual screen content goes on top
        Positioned.fill(
          child: child,
        ),
      ],
    );
  }
}


// PlasmaRenderer is part of simple_animations package. 
// If you encounter issues, ensure simple_animations is correctly imported and pub get is run.
// For the purpose of this code generation, I'm assuming PlasmaRenderer is available from simple_animations.

