import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savitri_app/screens/welcome_screen.dart';

void main() {
  testWidgets('WelcomeScreen has a title and a button', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: WelcomeScreen(),
    ));

    expect(find.text('Welcome to Savitri'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
} 