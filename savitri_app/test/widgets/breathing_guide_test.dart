import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savitri_app/widgets/breathing_guide.dart';

void main() {
  testWidgets('BreathingGuide animation works correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BreathingGuide(),
        ),
      ),
    );

    // At the beginning, the text should be 'Inhale'.
    expect(find.text('Inhale'), findsOneWidget);

    // Advance the animation to the 'Hold' phase.
    await tester.pump(const Duration(seconds: 5));
    expect(find.text('Hold'), findsOneWidget);

    // Advance the animation to the 'Exhale' phase.
    await tester.pump(const Duration(seconds: 8));
    expect(find.text('Exhale'), findsOneWidget);
  });
}
