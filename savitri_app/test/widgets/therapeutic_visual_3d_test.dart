import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savitri_app/widgets/therapeutic_visual_3d.dart';
import 'package:savitri_app/widgets/emotion_indicator.dart';
import 'package:savitri_app/widgets/breathing_guide.dart';

void main() {
  group('TherapeuticVisual3D Widget Tests', () {
    testWidgets('renders correctly with default properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TherapeuticVisual3D(
              emotionalState: EmotionalState.neutral,
            ),
          ),
        ),
      );

      // Verify the widget renders
      expect(find.byType(TherapeuticVisual3D), findsOneWidget);
      
      // Verify container exists
      expect(find.byType(Container), findsWidgets);
      
      // Verify emotion indicator is shown
      expect(find.byType(EmotionIndicator), findsOneWidget);
    });

    testWidgets('shows breathing guide when enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TherapeuticVisual3D(
              emotionalState: EmotionalState.anxious,
              showBreathingGuide: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify breathing guide is shown
      expect(find.byType(BreathingGuide), findsOneWidget);
    });

    testWidgets('hides breathing guide when disabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TherapeuticVisual3D(
              emotionalState: EmotionalState.calm,
              showBreathingGuide: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify breathing guide is not shown
      expect(find.byType(BreathingGuide), findsNothing);
    });

    testWidgets('responds to tap events', (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TherapeuticVisual3D(
              emotionalState: EmotionalState.neutral,
              onTap: () {
                wasTapped = true;
              },
            ),
          ),
        ),
      );

      // Tap the widget
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();

      // Verify tap was registered
      expect(wasTapped, isTrue);
    });

    testWidgets('displays emotional state text correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TherapeuticVisual3D(
              emotionalState: EmotionalState.happy,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify emotional state text is displayed
      expect(find.text('happy'), findsOneWidget);
    });

    testWidgets('shows audio level indicator when audio level > 0', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TherapeuticVisual3D(
              emotionalState: EmotionalState.neutral,
              audioLevel: 0.5,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Look for the audio level indicator container
      final audioIndicator = find.byWidgetPredicate(
        (widget) => widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).borderRadius == BorderRadius.circular(3),
      );
      
      expect(audioIndicator, findsWidgets);
    });

    testWidgets('hides audio level indicator when audio level is 0', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TherapeuticVisual3D(
              emotionalState: EmotionalState.neutral,
              audioLevel: 0.0,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // The audio level indicator should not be visible
      final bottomPositioned = find.byWidgetPredicate(
        (widget) => widget is Positioned && widget.bottom == 20 && widget.left == 20,
      );
      
      expect(bottomPositioned, findsNothing);
    });

    testWidgets('emotional state changes update the display', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TherapeuticVisual3D(
              emotionalState: EmotionalState.calm,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('calm'), findsOneWidget);

      // Update to anxious state
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TherapeuticVisual3D(
              emotionalState: EmotionalState.anxious,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('anxious'), findsOneWidget);
      expect(find.text('calm'), findsNothing);
    });

    testWidgets('widget has correct dimensions', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                height: 400,
                child: TherapeuticVisual3D(
                  emotionalState: EmotionalState.neutral,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the main container with height 300
      final mainContainer = find.byWidgetPredicate(
        (widget) => widget is Container &&
            widget.constraints?.maxHeight == 300,
      );
      
      expect(mainContainer, findsOneWidget);
    });

    testWidgets('loading indicator appears before WebView is ready', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TherapeuticVisual3D(
              emotionalState: EmotionalState.neutral,
            ),
          ),
        ),
      );

      // Initially, the loading indicator should be visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
