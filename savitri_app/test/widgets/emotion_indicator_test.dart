import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savitri_app/widgets/emotion_indicator.dart';

void main() {
  testWidgets('EmotionIndicator changes color based on state', (WidgetTester tester) async {
    // Test for calm state
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmotionIndicator(state: EmotionalState.calm),
        ),
      ),
    );
    var container = tester.widget<Container>(find.byType(Container));
    var decoration = container.decoration as BoxDecoration;
    expect(decoration.color, Colors.blue);

    // Test for neutral state
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmotionIndicator(state: EmotionalState.neutral),
        ),
      ),
    );
    container = tester.widget<Container>(find.byType(Container));
    decoration = container.decoration as BoxDecoration;
    expect(decoration.color, Colors.grey);

    // Test for distressed state
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmotionIndicator(state: EmotionalState.distressed),
        ),
      ),
    );
    container = tester.widget<Container>(find.byType(Container));
    decoration = container.decoration as BoxDecoration;
    expect(decoration.color, Colors.orange);
  });
}
