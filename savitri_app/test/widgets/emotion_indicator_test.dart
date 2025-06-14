import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savitri_app/widgets/emotion_indicator.dart';
import 'package:savitri_app/utils/constants.dart';

void main() {
  group('EmotionIndicator', () {
    testWidgets('renders with correct dimensions', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmotionIndicator(state: EmotionalState.calm),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.maxWidth, 100);
      expect(container.constraints?.maxHeight, 100);
      
      final size = tester.getSize(find.byType(EmotionIndicator));
      expect(size.width, 100);
      expect(size.height, 100);
    });

    testWidgets('has circular shape for all states', (WidgetTester tester) async {
      for (final state in EmotionalState.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EmotionIndicator(state: state),
            ),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.shape, BoxShape.circle);
      }
    });

    testWidgets('calm state has correct color', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmotionIndicator(state: EmotionalState.calm),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.calm);
    });

    testWidgets('neutral state has correct color', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmotionIndicator(state: EmotionalState.neutral),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.neutral);
    });

    testWidgets('distressed state has correct color', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmotionIndicator(state: EmotionalState.distressed),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.anxious); // distressed uses anxious color
    });

    testWidgets('all emotional states have distinct colors', (WidgetTester tester) async {
      final Map<EmotionalState, Color> stateColors = {};
      
      for (final state in EmotionalState.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EmotionIndicator(state: state),
            ),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        stateColors[state] = decoration.color!;
      }

      // Verify all colors are different (except distressed which uses anxious color)
      final uniqueColors = stateColors.values.toSet();
      expect(uniqueColors.length, 6, reason: 'Should have 6 distinct colors (distressed uses anxious color)');
      
      // Verify specific color mappings
      expect(stateColors[EmotionalState.calm], AppColors.calm);
      expect(stateColors[EmotionalState.happy], AppColors.happy);
      expect(stateColors[EmotionalState.anxious], AppColors.anxious);
      expect(stateColors[EmotionalState.sad], AppColors.sad);
      expect(stateColors[EmotionalState.angry], AppColors.angry);
      expect(stateColors[EmotionalState.neutral], AppColors.neutral);
      expect(stateColors[EmotionalState.distressed], AppColors.anxious);
    });

    testWidgets('handles state changes correctly', (WidgetTester tester) async {
      EmotionalState currentState = EmotionalState.calm;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    EmotionIndicator(state: currentState),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          const states = EmotionalState.values;
                          final currentIndex = states.indexOf(currentState);
                          currentState = states[(currentIndex + 1) % states.length];
                        });
                      },
                      child: const Text('Change State'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Start with calm
      var container = tester.widget<Container>(find.byType(Container));
      var decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.calm);

      // Change to happy
      await tester.tap(find.text('Change State'));
      await tester.pump();
      container = tester.widget<Container>(find.byType(Container));
      decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.happy);

      // Change to anxious
      await tester.tap(find.text('Change State'));
      await tester.pump();
      container = tester.widget<Container>(find.byType(Container));
      decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.anxious);

      // Change to sad
      await tester.tap(find.text('Change State'));
      await tester.pump();
      container = tester.widget<Container>(find.byType(Container));
      decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.sad);
    });

    testWidgets('renders correctly in different layouts', (WidgetTester tester) async {
      // Test in Row
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                EmotionIndicator(state: EmotionalState.calm),
                EmotionIndicator(state: EmotionalState.neutral),
                EmotionIndicator(state: EmotionalState.distressed),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(EmotionIndicator), findsNWidgets(3));
      final containers = tester.widgetList<Container>(find.byType(Container));
      expect(containers.length, 3);

      // Test in Column
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                EmotionIndicator(state: EmotionalState.calm),
                EmotionIndicator(state: EmotionalState.neutral),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(EmotionIndicator), findsNWidgets(2));
    });

    testWidgets('maintains consistent styling across states', (WidgetTester tester) async {
      for (final state in EmotionalState.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EmotionIndicator(state: state),
            ),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        
        // All states should have the same shape and size
        expect(decoration.shape, BoxShape.circle);
        expect(container.constraints?.maxWidth, 100);
        expect(container.constraints?.maxHeight, 100);
        
        // All states should have a color (not null)
        expect(decoration.color, isNotNull);
      }
    });

    testWidgets('color mapping is exhaustive for all enum values', (WidgetTester tester) async {
      // This test ensures that if new EmotionalState values are added, 
      // they will be properly handled
      final testedStates = <EmotionalState>{};
      
      for (final state in EmotionalState.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EmotionIndicator(state: state),
            ),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, isNotNull, reason: 'State $state should have a color');
        
        testedStates.add(state);
      }
      
      expect(testedStates, containsAll(EmotionalState.values), 
        reason: 'All emotional states should be tested');
    });

    testWidgets('widget is accessible and findable', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmotionIndicator(state: EmotionalState.calm),
          ),
        ),
      );

      expect(find.byType(EmotionIndicator), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
      
      // Widget should be at the expected position
      final emotionIndicatorRect = tester.getRect(find.byType(EmotionIndicator));
      expect(emotionIndicatorRect.size.width, 100);
      expect(emotionIndicatorRect.size.height, 100);
    });

    testWidgets('visual consistency validation', (WidgetTester tester) async {
      const expectedWidth = 100.0;
      const expectedHeight = 100.0;
      
      for (final state in EmotionalState.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: EmotionIndicator(state: state),
              ),
            ),
          ),
        );

        final size = tester.getSize(find.byType(EmotionIndicator));
        expect(size.width, expectedWidth, reason: 'Width should be consistent for $state');
        expect(size.height, expectedHeight, reason: 'Height should be consistent for $state');
        
        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.shape, BoxShape.circle, reason: 'Shape should be circular for $state');
      }
    });

    testWidgets('rapid state changes', (WidgetTester tester) async {
      EmotionalState currentState = EmotionalState.calm;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    EmotionIndicator(state: currentState),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // Cycle through states rapidly
                          const states = EmotionalState.values;
                          final currentIndex = states.indexOf(currentState);
                          currentState = states[(currentIndex + 1) % states.length];
                        });
                      },
                      child: const Text('Next State'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Define expected colors in order
      final expectedColors = [
        AppColors.calm,
        AppColors.happy,
        AppColors.anxious,
        AppColors.sad,
        AppColors.angry,
        AppColors.neutral,
        AppColors.anxious, // distressed uses anxious color
      ];
      
      // Perform rapid state changes
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.text('Next State'));
        await tester.pump();
        
        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        final expectedColorIndex = (i + 1) % expectedColors.length;
        expect(decoration.color, expectedColors[expectedColorIndex]);
      }
    });
  });
}
