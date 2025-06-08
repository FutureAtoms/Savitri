import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savitri_app/widgets/crisis_banner.dart';

void main() {
  group('CrisisBanner', () {
    testWidgets('shows when in crisis with all elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CrisisBanner(isCrisis: true),
          ),
        ),
      );

      // Verify the banner is visible
      expect(find.byType(CrisisBanner), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
      
      // Verify the red background color
      final container = tester.widget<Container>(find.byType(Container));
      expect(container.color, Colors.red);
      
      // Verify the warning icon is present and has correct color
      expect(find.byIcon(Icons.warning), findsOneWidget);
      final icon = tester.widget<Icon>(find.byIcon(Icons.warning));
      expect(icon.color, Colors.white);
      
      // Verify the crisis text is present
      expect(find.textContaining('988'), findsOneWidget);
      expect(find.textContaining('In crisis?'), findsOneWidget);
      expect(find.textContaining('free, confidential support'), findsOneWidget);
      
      // Verify text color is white
      final text = tester.widget<Text>(find.textContaining('988'));
      expect(text.style?.color, Colors.white);
      
      // Verify layout structure - Row with proper children
      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Expanded), findsOneWidget);
      
      // Check for spacing SizedBox (with width 8.0)
      final spacingSizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      expect(spacingSizedBoxes.any((box) => box.width == 8.0), isTrue);
    });

    testWidgets('is hidden when not in crisis', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CrisisBanner(isCrisis: false),
          ),
        ),
      );

      // Verify the banner components are not visible
      expect(find.byType(CrisisBanner), findsOneWidget);
      expect(find.byType(Container), findsNothing);
      expect(find.byIcon(Icons.warning), findsNothing);
      expect(find.textContaining('988'), findsNothing);
      
      // Verify it returns a SizedBox.shrink()
      expect(find.byType(SizedBox), findsOneWidget);
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.width, 0.0);
      expect(sizedBox.height, 0.0);
    });

    testWidgets('maintains proper padding and spacing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CrisisBanner(isCrisis: true),
          ),
        ),
      );

      // Verify container padding
      final container = tester.widget<Container>(find.byType(Container));
      expect(container.padding, const EdgeInsets.all(12.0));
      
      // Verify spacing between icon and text
      final spacingSizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final spacingBox = spacingSizedBoxes.firstWhere((box) => box.width == 8.0);
      expect(spacingBox.width, 8.0);
    });

    testWidgets('handles state changes correctly', (WidgetTester tester) async {
      // Create a stateful widget to test state changes
      bool isCrisis = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    CrisisBanner(isCrisis: isCrisis),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isCrisis = !isCrisis;
                        });
                      },
                      child: const Text('Toggle Crisis'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Initially not in crisis
      expect(find.byType(Container), findsNothing);
      expect(find.textContaining('988'), findsNothing);

      // Trigger crisis state
      await tester.tap(find.text('Toggle Crisis'));
      await tester.pump();

      // Now in crisis - should show banner
      expect(find.byType(Container), findsOneWidget);
      expect(find.textContaining('988'), findsOneWidget);

      // Toggle back to not in crisis
      await tester.tap(find.text('Toggle Crisis'));
      await tester.pump();

      // Should hide banner again
      expect(find.byType(Container), findsNothing);
      expect(find.textContaining('988'), findsNothing);
    });

    testWidgets('renders consistently in different layouts', (WidgetTester tester) async {
      // Test in Column
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CrisisBanner(isCrisis: true),
                Text('Other Content'),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.textContaining('988'), findsOneWidget);

      // Test in ListView
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: const [
                CrisisBanner(isCrisis: true),
                ListTile(title: Text('Item 1')),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.textContaining('988'), findsOneWidget);
    });

    testWidgets('icon and text positioning is correct', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CrisisBanner(isCrisis: true),
          ),
        ),
      );

      // Verify Row alignment
      final row = tester.widget<Row>(find.byType(Row));
      expect(row.mainAxisAlignment, MainAxisAlignment.center);
      
      // Verify the structure: Icon -> SizedBox -> Expanded(Text)
      final rowChildren = row.children;
      expect(rowChildren.length, 3);
      expect(rowChildren[0] is Icon, isTrue);
      expect(rowChildren[1] is SizedBox, isTrue);
      expect(rowChildren[2] is Expanded, isTrue);
    });

    testWidgets('text content is complete and accurate', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CrisisBanner(isCrisis: true),
          ),
        ),
      );

      // Check for exact text content
      expect(find.text('In crisis? Call or text 988 for free, confidential support.'), findsOneWidget);
      
      // Check that text includes all key components
      final textWidget = tester.widget<Text>(find.textContaining('988'));
      final textContent = textWidget.data!;
      expect(textContent.contains('In crisis?'), isTrue);
      expect(textContent.contains('Call or text'), isTrue);
      expect(textContent.contains('988'), isTrue);
      expect(textContent.contains('free'), isTrue);
      expect(textContent.contains('confidential'), isTrue);
      expect(textContent.contains('support'), isTrue);
    });

    testWidgets('widget takes appropriate space when visible', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CrisisBanner(isCrisis: true),
                Expanded(child: Text('Content below')),
              ],
            ),
          ),
        ),
      );

      // Verify the banner takes up space
      final bannerSize = tester.getSize(find.byType(CrisisBanner));
      expect(bannerSize.height, greaterThan(0));
      expect(bannerSize.width, greaterThan(0));
      
      // Verify content below is still visible
      expect(find.text('Content below'), findsOneWidget);
    });

    testWidgets('widget takes no space when hidden', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CrisisBanner(isCrisis: false),
                Expanded(child: Text('Content below')),
              ],
            ),
          ),
        ),
      );

      // Verify the banner takes up no space
      final bannerSize = tester.getSize(find.byType(CrisisBanner));
      expect(bannerSize.height, equals(0));
      expect(bannerSize.width, equals(0));
      
      // Verify content below is still visible and positioned correctly
      expect(find.text('Content below'), findsOneWidget);
    });

    testWidgets('handles rapid state toggles', (WidgetTester tester) async {
      bool isCrisis = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    CrisisBanner(isCrisis: isCrisis),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isCrisis = !isCrisis;
                        });
                      },
                      child: const Text('Toggle'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Perform rapid toggles
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.text('Toggle'));
        await tester.pump();
        
        if (i % 2 == 0) {
          // Should be visible on odd iterations
          expect(find.textContaining('988'), findsOneWidget);
        } else {
          // Should be hidden on even iterations
          expect(find.textContaining('988'), findsNothing);
        }
      }
    });

    testWidgets('crisis banner styling matches design requirements', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CrisisBanner(isCrisis: true),
          ),
        ),
      );

      // Verify container styling
      final container = tester.widget<Container>(find.byType(Container));
      expect(container.color, Colors.red);
      expect(container.padding, const EdgeInsets.all(12.0));

      // Verify icon styling
      final icon = tester.widget<Icon>(find.byIcon(Icons.warning));
      expect(icon.icon, Icons.warning);
      expect(icon.color, Colors.white);

      // Verify text styling
      final text = tester.widget<Text>(find.textContaining('988'));
      expect(text.style?.color, Colors.white);
    });
  });
}
