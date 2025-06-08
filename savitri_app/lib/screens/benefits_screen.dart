import 'package:flutter/material.dart';
import 'package:savitri_app/screens/consent_screen.dart';
import 'package:savitri_app/widgets/therapeutic_button.dart';

class BenefitsScreen extends StatelessWidget {
  const BenefitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Benefits'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Discover a safe space to improve your mental wellbeing:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const ListTile(
              leading: Icon(Icons.check_circle_outline, color: Colors.green),
              title: Text('24/7 confidential support'),
            ),
            const ListTile(
              leading: Icon(Icons.check_circle_outline, color: Colors.green),
              title: Text('Personalized therapeutic techniques'),
            ),
            const ListTile(
              leading: Icon(Icons.check_circle_outline, color: Colors.green),
              title: Text('Track your emotional progress'),
            ),
            const Spacer(),
            TherapeuticButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ConsentScreen()),
                );
              },
              text: 'Next',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
} 