import 'package:flutter/material.dart';

class TherapeuticButton extends StatelessWidget {
  const TherapeuticButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.height = 50.0,
    this.width = double.infinity,
  });

  final VoidCallback? onPressed;
  final String text;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
} 