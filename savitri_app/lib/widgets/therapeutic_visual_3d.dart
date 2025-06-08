import 'package:flutter/material.dart';
import 'package:savitri_app/widgets/emotion_indicator.dart';

class TherapeuticVisual3D extends StatelessWidget {
  const TherapeuticVisual3D({
    super.key,
    required this.emotionalState,
  });

  final EmotionalState emotionalState;

  Color _getColorForState() {
    switch (emotionalState) {
      case EmotionalState.calm:
        return Colors.blue.shade200;
      case EmotionalState.neutral:
        return Colors.grey.shade400;
      case EmotionalState.distressed:
        return Colors.orange.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: _getColorForState(),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          '3D Visualization',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
} 