import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savitri_app/widgets/therapeutic_button.dart';

void main() {
  testWidgets('TherapeuticButton renders correctly and handles tap', (WidgetTester tester) async {
    // A variable to track whether the button was pressed.
    bool pressed = false;

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TherapeuticButton(
            onPressed: () {
              pressed = true;
            },
            text: 'Press Me',
          ),
        ),
      ),
    );

    // Verify that our button has the correct text.
    expect(find.text('Press Me'), findsOneWidget);

    // Verify that the button has not been pressed yet.
    expect(pressed, isFalse);

    // Tap the button.
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify that the button was pressed.
    expect(pressed, isTrue);
  });
} 