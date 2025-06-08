import 'package:flutter/material.dart';
import 'package:savitri_app/screens/settings_screen.dart';
import 'package:savitri_app/services/auth_service.dart';
import 'package:savitri_app/widgets/therapeutic_button.dart';

class MfaScreen extends StatefulWidget {
  const MfaScreen({super.key});

  @override
  State<MfaScreen> createState() => _MfaScreenState();
}

class _MfaScreenState extends State<MfaScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _mfaController = TextEditingController();
  bool _isLoading = false;

  void _verifyMfa() async {
    setState(() {
      _isLoading = true;
    });

    final success = await _authService.verifyMfa(_mfaController.text);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()),
      );
    } else {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to verify MFA')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Two-Factor Authentication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _mfaController,
              decoration: const InputDecoration(labelText: 'MFA Code'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              TherapeuticButton(
                onPressed: _verifyMfa,
                text: 'Verify',
              ),
          ],
        ),
      ),
    );
  }
}
