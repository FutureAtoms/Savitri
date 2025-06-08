import 'package:flutter/material.dart';

class BreathingGuide extends StatefulWidget {
  const BreathingGuide({super.key});

  @override
  State<BreathingGuide> createState() => _BreathingGuideState();
}

class _BreathingGuideState extends State<BreathingGuide> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String _text = 'Inhale';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 19), // 4 (inhale) + 7 (hold) + 8 (exhale) = 19
    )..repeat();

    _animation = TweenSequence<double>([
      // Inhale
      TweenSequenceItem(tween: Tween<double>(begin: 50, end: 150), weight: 4),
      // Hold
      TweenSequenceItem(tween: ConstantTween<double>(150), weight: 7),
      // Exhale
      TweenSequenceItem(tween: Tween<double>(begin: 150, end: 50), weight: 8),
    ]).animate(_controller);

    _controller.addListener(() {
      final status = _controller.status;
      if (status == AnimationStatus.forward || status == AnimationStatus.reverse) {
        final t = _controller.value;
        if (t < 4 / 19) {
          setState(() {
            _text = 'Inhale';
          });
        } else if (t < (4 + 7) / 19) {
          setState(() {
            _text = 'Hold';
          });
        } else {
          setState(() {
            _text = 'Exhale';
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: _animation.value,
              height: _animation.value,
              decoration: const BoxDecoration(
                color: Colors.lightBlueAccent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _text,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        );
      },
    );
  }
} 