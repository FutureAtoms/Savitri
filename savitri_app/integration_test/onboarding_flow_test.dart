import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:savitri_app/main.dart' as app;
import 'package:savitri_app/screens/benefits_screen.dart';
import 'package:savitri_app/screens/consent_screen.dart';
import 'package:savitri_app/screens/welcome_screen.dart';
import 'package:savitri_app/widgets/therapeutic_button.dart';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Onboarding flow works correctly', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Starts on WelcomeScreen
    expect(find.byType(WelcomeScreen), findsOneWidget);

    // Tap 'Get Started' to navigate to BenefitsScreen
    await tester.tap(find.widgetWithText(TherapeuticButton, 'Get Started'));
    await tester.pumpAndSettle();
    expect(find.byType(BenefitsScreen), findsOneWidget);

    // Tap 'Next' to navigate to ConsentScreen
    await tester.tap(find.widgetWithText(TherapeuticButton, 'Next'));
    await tester.pumpAndSettle();
    expect(find.byType(ConsentScreen), findsOneWidget);

    // On ConsentScreen, 'Agree' button should be disabled initially
    TherapeuticButton agreeButton = tester.widget(find.widgetWithText(TherapeuticButton, 'Agree'));
    expect(agreeButton.onPressed, isNull);

    // Scroll to the bottom
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -5000));
    await tester.pumpAndSettle();

    // Check the checkbox
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    // 'Agree' button should now be enabled
    agreeButton = tester.widget(find.widgetWithText(TherapeuticButton, 'Agree'));
    expect(agreeButton.onPressed, isNotNull);

    // Tap the 'Agree' button
    await tester.tap(find.widgetWithText(TherapeuticButton, 'Agree'));
    await tester.pumpAndSettle();

    // Assert that we have navigated away from the consent screen
    // (in a real app, this would navigate to a registration or home screen)
    expect(find.byType(ConsentScreen), findsNothing);
  });
}
