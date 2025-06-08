import 'package:flutter/material.dart';

class CrisisBanner extends StatelessWidget {
  const CrisisBanner({
    super.key,
    required this.isCrisis,
  });

  final bool isCrisis;

  @override
  Widget build(BuildContext context) {
    if (!isCrisis) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.red,
      padding: const EdgeInsets.all(12.0),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.warning,
            color: Colors.white,
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(
              'In crisis? Call or text 988 for free, confidential support.',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
} 