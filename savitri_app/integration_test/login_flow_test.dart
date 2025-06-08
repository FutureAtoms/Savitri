import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:savitri_app/main.dart' as app;
import 'package:savitri_app/screens/login_screen.dart';
import 'package:savitri_app/screens/mfa_screen.dart';
import 'package:savitri_app/screens/settings_screen.dart';
import 'package:savitri_app/widgets/therapeutic_button.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Login flow works correctly', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // For the purpose of this test, we will navigate directly to the LoginScreen.
    // In a real app, this would be part of the onboarding flow.
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    // Enter email and password.
    await tester.enterText(find.byType(TextField).at(0), 'test@test.com');
    await tester.enterText(find.byType(TextField).at(1), 'password');

    // Tap the login button.
    await tester.tap(find.widgetWithText(TherapeuticButton, 'Login'));
    await tester.pumpAndSettle();

    // Should be on the MFA screen.
    expect(find.byType(MfaScreen), findsOneWidget);

    // Enter the MFA code.
    await tester.enterText(find.byType(TextField), '123456');

    // Tap the verify button.
    await tester.tap(find.widgetWithText(TherapeuticButton, 'Verify'));
    await tester.pumpAndSettle();

    // Should be on the SettingsScreen (acting as the home screen for this test).
    expect(find.byType(SettingsScreen), findsOneWidget);
  });
}
