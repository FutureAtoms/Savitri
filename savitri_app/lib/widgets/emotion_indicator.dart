import 'package:flutter/material.dart';
import '../utils/constants.dart';

enum EmotionalState {
  calm,
  happy,
  anxious,
  sad,
  angry,
  neutral,
  distressed,
}

class EmotionIndicator extends StatelessWidget {
  const EmotionIndicator({
    super.key,
    required this.state,
  });

  final EmotionalState state;

  Color _getColorForState() {
    switch (state) {
      case EmotionalState.calm:
        return AppColors.calm;
      case EmotionalState.happy:
        return AppColors.happy;
      case EmotionalState.anxious:
        return AppColors.anxious;
      case EmotionalState.sad:
        return AppColors.sad;
      case EmotionalState.angry:
        return AppColors.angry;
      case EmotionalState.neutral:
        return AppColors.neutral;
      case EmotionalState.distressed:
        return AppColors.anxious; // Using anxious color for distressed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: _getColorForState(),
        shape: BoxShape.circle,
      ),
    );
  }
}
