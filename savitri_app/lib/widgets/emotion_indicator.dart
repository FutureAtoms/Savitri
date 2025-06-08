import 'package:flutter/material.dart';

enum EmotionalState {
  calm,
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
        return Colors.blue;
      case EmotionalState.neutral:
        return Colors.grey;
      case EmotionalState.distressed:
        return Colors.orange;
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