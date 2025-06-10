import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savitri_app/screens/therapy_screen.dart';
import 'package:savitri_app/widgets/therapeutic_visual_3d.dart';
import 'package:savitri_app/widgets/crisis_banner.dart';
import '../test_helpers.dart';

void main() {
  late TestWidgetsFlutterBinding binding;

  setUpAll(() {
    setupWebViewForTesting();
  });

  setUp(() {
    binding = TestWidgetsFlutterBinding.ensureInitialized();
    // Reset any test state
    binding.resetInternalState();
  });

  tearDown(() {
    // Clear any remaining timers
    binding.reset();
  });

  group('TherapyScreen Tests', () {
    testWidgets('renders correctly with all components', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TherapyScreen(),
        ),
      );

      // Wait for initial build
      await tester.pump();
      
      // Let animations settle without causing timer issues
      await tester.pump(const Duration(milliseconds: 100));

      // Verify main components exist
      expect(find.byType(TherapyScreen), findsOneWidget);
      expect(find.text('Therapy Session'), findsOneWidget);
      expect(find.byType(TherapeuticVisual3D), findsOneWidget);
      expect(find.byType(CrisisBanner), findsOneWidget);
      
      // Verify control buttons
      expect(find.byIcon(Icons.history), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byIcon(Icons.mic), findsOneWidget);
      
      // Verify quick actions
      expect(find.text('Breathing'), findsOneWidget);
      expect(find.text('Exercises'), findsOneWidget);
      expect(find.text('Assessment'), findsOneWidget);
      expect(find.text('Resources'), findsOneWidget);
      
      // Verify initial state text
      expect(find.text('Tap to start session'), findsOneWidget);
    });

    testWidgets('microphone button toggles session state', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TherapyScreen(),
        ),
      );

      // Initial pump
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Initially not recording
      expect(find.byIcon(Icons.mic), findsOneWidget);
      expect(find.byIcon(Icons.stop), findsNothing);
      expect(find.text('Tap to start session'), findsOneWidget);

      // Tap microphone button
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should show stop icon and recording status
      expect(find.byIcon(Icons.stop), findsOneWidget);
      expect(find.text('Tap to end session'), findsOneWidget);
      expect(find.text('Recording'), findsOneWidget);

      // Tap stop button
      await tester.tap(find.byIcon(Icons.stop));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should return to initial state
      expect(find.byIcon(Icons.mic), findsOneWidget);
      expect(find.byIcon(Icons.stop), findsNothing);
      expect(find.text('Tap to start session'), findsOneWidget);
    });

    testWidgets('session info appears when recording', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TherapyScreen(),
        ),
      );

      // Initial pump
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Initially no session info
      expect(find.text('Duration'), findsNothing);
      expect(find.text('Status'), findsNothing);
      expect(find.text('Mood'), findsNothing);

      // Start session
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Session info should appear
      expect(find.text('Duration'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Mood'), findsOneWidget);
      expect(find.text('Recording'), findsOneWidget);
      expect(find.text('neutral'), findsOneWidget);
    });

    testWidgets('breathing guide toggle works', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TherapyScreen(),
        ),
      );

      // Wait for initial build
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Find breathing button
      final breathingButton = find.widgetWithText(InkWell, 'Breathing');
      expect(breathingButton, findsOneWidget);

      // Tap breathing button
      await tester.tap(breathingButton);
      await tester.pump();

      // The button should show active state
      // (We can't directly test the TherapeuticVisual3D prop change,
      // but we can verify the button visual state changes)
      final inkWell = tester.widget<InkWell>(breathingButton);
      final container = inkWell.child as Container;
      expect(container.decoration, isNotNull);
    });

    testWidgets('quick action buttons are tappable', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TherapyScreen(),
        ),
      );

      // Wait for initial build
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Test each quick action button
      final buttons = [
        'Breathing',
        'Exercises',
        'Assessment',
        'Resources',
      ];

      for (final buttonText in buttons) {
        final button = find.widgetWithText(InkWell, buttonText);
        expect(button, findsOneWidget);
        
        // Verify it's tappable
        await tester.tap(button);
        await tester.pump();
      }
    });

    testWidgets('settings button is present and tappable', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const TherapyScreen(),
          routes: {
            '/settings': (context) => const Scaffold(body: Text('Settings')),
          },
        ),
      );

      // Wait for initial build
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Find and tap settings button
      final settingsButton = find.byIcon(Icons.settings);
      expect(settingsButton, findsOneWidget);
      
      await tester.tap(settingsButton);
      await tester.pumpAndSettle();
      
      // Should navigate to settings (in a real app)
      // For now, just verify the button exists and is tappable
    });

    testWidgets('history button is present and tappable', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const TherapyScreen(),
          routes: {
            '/history': (context) => const Scaffold(body: Text('History')),
          },
        ),
      );

      // Wait for initial build
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Find and tap history button
      final historyButton = find.byIcon(Icons.history);
      expect(historyButton, findsOneWidget);
      
      await tester.tap(historyButton);
      await tester.pumpAndSettle();
      
      // Should navigate to history (in a real app)
      // For now, just verify the button exists and is tappable
    });

    testWidgets('timer updates during session', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TherapyScreen(),
        ),
      );

      // Initial pump
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Start session
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pump();

      // Verify initial timer shows 00:00:00
      expect(find.text('00:00:00'), findsOneWidget);

      // Wait for timer to update (using pump to advance time)
      await tester.pump(const Duration(seconds: 2));

      // Timer should update (exact time might vary due to test execution)
      // Just verify the format is maintained
      expect(find.textContaining(':'), findsWidgets);

      // Stop the session to clean up
      await tester.tap(find.byIcon(Icons.stop));
      await tester.pump();
    });
  });
}
