import 'package:flutter/material.dart';
import 'package:savitri_app/screens/login_screen.dart';
import 'package:savitri_app/widgets/therapeutic_button.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolledToEnd = false;
  bool _isConsentChecked = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        setState(() {
          _isScrolledToEnd = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consent Form'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'This is a long consent form that the user must scroll through...'
                  '\n\n' * 50, // Making the text long to ensure scrolling
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _isConsentChecked,
                      onChanged: _isScrolledToEnd
                          ? (bool? value) {
                              setState(() {
                                _isConsentChecked = value!;
                              });
                            }
                          : null,
                    ),
                    const Text('I have read and agree to the terms.'),
                  ],
                ),
                const SizedBox(height: 10),
                TherapeuticButton(
                  onPressed: _isConsentChecked ? () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  } : null,
                  text: 'Agree',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 