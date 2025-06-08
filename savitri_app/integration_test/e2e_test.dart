import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:savitri_app/main.dart' as app;
import 'package:savitri_app/widgets/therapeutic_button.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Welcome screen
    expect(find.text('Welcome to Savitri'), findsOneWidget);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Benefits screen
    expect(find.text('Benefits'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Consent screen
    expect(find.text('Consent Form'), findsOneWidget);
    await tester.scrollUntilVisible(find.byType(Checkbox), 500);
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agree'));
    await tester.pumpAndSettle();

    // Login screen
    await tester.pumpAndSettle(const Duration(seconds: 2));
    debugDumpApp();
    expect(find.text('Login'), findsNWidgets(2));
    await tester.enterText(find.byKey(const ValueKey('email_field')), 'test@test.com');
    await tester.enterText(find.byKey(const ValueKey('password_field')), 'password');
    await tester.tap(find.widgetWithText(TherapeuticButton, 'Login'));
    await tester.pumpAndSettle();

    // MFA screen
    expect(find.text('Enter MFA Code'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('mfa_field')), '123456');
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();

    // Settings screen
    expect(find.text('Settings'), findsOneWidget);
  });
} 