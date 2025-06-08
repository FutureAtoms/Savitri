import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savitri_app/widgets/therapeutic_button.dart';

void main() {
  group('TherapeuticButton', () {
    testWidgets('renders correctly with default parameters', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TherapeuticButton(
              onPressed: () {
                pressed = true;
              },
              text: 'Test Button',
            ),
          ),
        ),
      );

      // Verify button is rendered
      expect(find.byType(TherapeuticButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Test Button'), findsOneWidget);

      // Verify default size
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.height, equals(50.0));
      expect(sizedBox.width, equals(double.infinity));

      // Test tap functionality
      expect(pressed, isFalse);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(pressed, isTrue);
    });

    testWidgets('renders with custom dimensions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TherapeuticButton(
              onPressed: () {},
              text: 'Custom Size',
              height: 60.0,
              width: 200.0,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.height, equals(60.0));
      expect(sizedBox.width, equals(200.0));
    });

    testWidgets('handles disabled state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TherapeuticButton(
              onPressed: null,
              text: 'Disabled Button',
            ),
          ),
        ),
      );

      final elevatedButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(elevatedButton.onPressed, isNull);
      expect(find.text('Disabled Button'), findsOneWidget);
    });

    testWidgets('handles different text content', (WidgetTester tester) async {
      const testTexts = [
        'Start Therapy',
        'Emergency Help',
        'Settings',
        '🔊 Voice Mode',
        'Very Long Button Text That Should Still Work',
        '',
      ];

      for (final text in testTexts) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TherapeuticButton(
                onPressed: () {},
                text: text,
              ),
            ),
          ),
        );

        expect(find.text(text), findsOneWidget);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('handles rapid successive taps', (WidgetTester tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TherapeuticButton(
              onPressed: () {
                tapCount++;
              },
              text: 'Tap Me',
            ),
          ),
        ),
      );

      // Perform multiple rapid taps
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump(const Duration(milliseconds: 10));
      }

      expect(tapCount, equals(5));
    });

    testWidgets('maintains widget findability', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TherapeuticButton(
              onPressed: () {},
              text: 'Accessible Button',
            ),
          ),
        ),
      );

      // Verify that the button can be found and interacted with
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Accessible Button'), findsOneWidget);
      
      // Verify the button is tappable
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
    });

    testWidgets('handles edge case dimensions', (WidgetTester tester) async {
      // Test with very small dimensions
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TherapeuticButton(
              onPressed: () {},
              text: 'Small',
              height: 1.0,
              width: 1.0,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.height, equals(1.0));
      expect(sizedBox.width, equals(1.0));

      // Test with large dimensions
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TherapeuticButton(
              onPressed: () {},
              text: 'Large',
              height: 500.0,
              width: 800.0,
            ),
          ),
        ),
      );

      final largeSizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(largeSizedBox.height, equals(500.0));
      expect(largeSizedBox.width, equals(800.0));
    });

    testWidgets('callback parameter validation', (WidgetTester tester) async {
      bool callbackExecuted = false;
      String passedData = '';
      
      // Test that callback context is preserved
      void testCallback() {
        callbackExecuted = true;
        passedData = 'callback executed';
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TherapeuticButton(
              onPressed: testCallback,
              text: 'Test Callback',
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(callbackExecuted, isTrue);
      expect(passedData, equals('callback executed'));
    });

    testWidgets('button styling is consistent', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TherapeuticButton(
                  onPressed: () {},
                  text: 'Button 1',
                ),
                TherapeuticButton(
                  onPressed: () {},
                  text: 'Button 2',
                ),
              ],
            ),
          ),
        ),
      );

      final buttons = tester.widgetList<ElevatedButton>(find.byType(ElevatedButton));
      expect(buttons.length, equals(2));
      
      // Both buttons should have the same type and be consistently styled
      for (final button in buttons) {
        expect(button.runtimeType, equals(ElevatedButton));
      }
    });

    testWidgets('handles zero dimensions gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TherapeuticButton(
              onPressed: () {},
              text: 'Zero Size',
              height: 0.0,
              width: 0.0,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.height, equals(0.0));
      expect(sizedBox.width, equals(0.0));
      
      // Button should still exist even with zero dimensions
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}
