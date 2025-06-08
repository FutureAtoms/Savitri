import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:savitri_app/main.dart' as app;
import 'package:savitri_app/screens/benefits_screen.dart';
import 'package:savitri_app/screens/consent_screen.dart';
import 'package:savitri_app/screens/welcome_screen.dart';
import 'package:savitri_app/screens/login_screen.dart';
import 'package:savitri_app/widgets/therapeutic_button.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Onboarding Flow Integration Tests', () {
    testWidgets('Complete onboarding flow works correctly', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Test 1: Verify app starts on Welcome Screen
      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.text('Welcome to Savitri'), findsOneWidget);
      expect(find.text('Your AI-powered mental health companion'), findsOneWidget);
      
      // Verify the Get Started button exists
      final getStartedButton = find.widgetWithText(TherapeuticButton, 'Get Started');
      expect(getStartedButton, findsOneWidget);

      // Test 2: Navigate to Benefits Screen
      await tester.tap(getStartedButton);
      await tester.pumpAndSettle();
      
      // Verify we're on Benefits Screen
      expect(find.byType(BenefitsScreen), findsOneWidget);
      expect(find.text('Why Choose Savitri?'), findsOneWidget);
      
      // Verify all benefits are displayed
      expect(find.text('24/7 Support'), findsOneWidget);
      expect(find.text('Evidence-Based'), findsOneWidget);
      expect(find.text('Confidential'), findsOneWidget);
      expect(find.text('Personalized'), findsOneWidget);
      
      // Find and tap Next button
      final nextButton = find.widgetWithText(TherapeuticButton, 'Next');
      expect(nextButton, findsOneWidget);
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Test 3: Navigate to Consent Screen
      expect(find.byType(ConsentScreen), findsOneWidget);
      expect(find.text('Privacy & Consent'), findsOneWidget);
      
      // Verify Agree button is initially disabled
      final agreeButtonFinder = find.widgetWithText(TherapeuticButton, 'Agree');
      expect(agreeButtonFinder, findsOneWidget);
      
      TherapeuticButton agreeButton = tester.widget(agreeButtonFinder);
      expect(agreeButton.onPressed, isNull, reason: 'Agree button should be disabled initially');

      // Test 4: Scroll consent content
      final scrollableFinder = find.byType(SingleChildScrollView);
      expect(scrollableFinder, findsOneWidget);
      
      // Scroll to the bottom
      await tester.drag(scrollableFinder, const Offset(0, -5000));
      await tester.pumpAndSettle();
      
      // Verify checkbox is visible after scrolling
      final checkboxFinder = find.byType(Checkbox);
      expect(checkboxFinder, findsOneWidget);
      
      // Verify checkbox is initially unchecked
      Checkbox checkbox = tester.widget(checkboxFinder);
      expect(checkbox.value, isFalse);

      // Test 5: Check the consent checkbox
      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();
      
      // Verify checkbox is now checked
      checkbox = tester.widget(checkboxFinder);
      expect(checkbox.value, isTrue);
      
      // Verify Agree button is now enabled
      agreeButton = tester.widget(agreeButtonFinder);
      expect(agreeButton.onPressed, isNotNull, reason: 'Agree button should be enabled after checking consent');

      // Test 6: Complete onboarding by tapping Agree
      await tester.tap(agreeButtonFinder);
      await tester.pumpAndSettle();
      
      // Verify we've navigated away from consent screen
      expect(find.byType(ConsentScreen), findsNothing);
      
      // In a real app, this would navigate to login/registration
      // For now, verify we're on the login screen
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Back navigation works correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Benefits Screen
      await tester.tap(find.widgetWithText(TherapeuticButton, 'Get Started'));
      await tester.pumpAndSettle();
      expect(find.byType(BenefitsScreen), findsOneWidget);

      // Navigate back to Welcome Screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(WelcomeScreen), findsOneWidget);

      // Navigate forward again
      await tester.tap(find.widgetWithText(TherapeuticButton, 'Get Started'));
      await tester.pumpAndSettle();
      expect(find.byType(BenefitsScreen), findsOneWidget);

      // Navigate to Consent Screen
      await tester.tap(find.widgetWithText(TherapeuticButton, 'Next'));
      await tester.pumpAndSettle();
      expect(find.byType(ConsentScreen), findsOneWidget);

      // Navigate back to Benefits Screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(BenefitsScreen), findsOneWidget);
    });

    testWidgets('Consent validation prevents navigation without agreement', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Consent Screen
      await tester.tap(find.widgetWithText(TherapeuticButton, 'Get Started'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TherapeuticButton, 'Next'));
      await tester.pumpAndSettle();

      // Try to tap Agree button without scrolling or checking
      final agreeButton = find.widgetWithText(TherapeuticButton, 'Agree');
      await tester.tap(agreeButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify we're still on Consent Screen
      expect(find.byType(ConsentScreen), findsOneWidget);

      // Scroll but don't check the checkbox
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -5000));
      await tester.pumpAndSettle();

      // Try to tap Agree again
      await tester.tap(agreeButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify we're still on Consent Screen
      expect(find.byType(ConsentScreen), findsOneWidget);
    });

    testWidgets('UI elements are properly styled', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify TherapeuticButton styling on Welcome Screen
      final getStartedButton = tester.widget<TherapeuticButton>(
        find.widgetWithText(TherapeuticButton, 'Get Started')
      );
      expect(getStartedButton.onPressed, isNotNull);

      // Navigate to Benefits Screen
      await tester.tap(find.widgetWithText(TherapeuticButton, 'Get Started'));
      await tester.pumpAndSettle();

      // Verify benefit cards are displayed
      final cards = find.byType(Card);
      expect(cards, findsNWidgets(4)); // 4 benefit cards

      // Verify icons are present
      expect(find.byIcon(Icons.access_time), findsOneWidget);
      expect(find.byIcon(Icons.psychology), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });
  });
}
