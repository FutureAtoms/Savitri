import 'package:flutter/material.dart';
import 'package:savitri_app/screens/benefits_screen.dart';
import 'package:savitri_app/widgets/therapeutic_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Savitri'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Your personal mental wellness companion.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 50),
            TherapeuticButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BenefitsScreen()),
                );
              },
              text: 'Get Started',
            ),
          ],
        ),
      ),
    );
  }
} 