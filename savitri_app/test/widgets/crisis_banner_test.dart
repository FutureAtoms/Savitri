import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savitri_app/widgets/crisis_banner.dart';

void main() {
  testWidgets('CrisisBanner shows when in crisis', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CrisisBanner(isCrisis: true),
        ),
      ),
    );

    // The banner should be visible.
    expect(find.byType(Container), findsOneWidget);
    expect(find.textContaining('988'), findsOneWidget);

    // Check for red background color
    final container = tester.widget<Container>(find.byType(Container));
    expect(container.color, Colors.red);
  });

  testWidgets('CrisisBanner is hidden when not in crisis', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CrisisBanner(isCrisis: false),
        ),
      ),
    );

    // The banner should not be visible.
    expect(find.byType(Container), findsNothing);
  });
}
