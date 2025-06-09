import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savitri_app/screens/consent_screen.dart';
import 'package:savitri_app/screens/login_screen.dart';
import 'package:savitri_app/widgets/therapeutic_button.dart';

void main() {
  testWidgets('ConsentScreen logic test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(
      home: ConsentScreen(),
    ));

    // Find widgets
    final agreeButton = find.widgetWithText(TherapeuticButton, 'Agree');
    final checkbox = find.byType(Checkbox);
    final scrollView = find.byType(SingleChildScrollView);

    // Initially, the checkbox and button should be disabled.
    expect(tester.widget<TherapeuticButton>(agreeButton).onPressed, isNull);
    expect(tester.widget<Checkbox>(checkbox).onChanged, isNull);

    // Scroll to the end of the list.
    await tester.drag(scrollView, const Offset(0, -5000));
    await tester.pumpAndSettle();

    // Now, the checkbox should be enabled, but the button still disabled.
    expect(tester.widget<Checkbox>(checkbox).onChanged, isNotNull);
    expect(tester.widget<TherapeuticButton>(agreeButton).onPressed, isNull);
    
    // Tap the checkbox.
    await tester.tap(checkbox);
    await tester.pump();

    // The button should now be enabled.
    expect(tester.widget<TherapeuticButton>(agreeButton).onPressed, isNotNull);

    // Tap the button and verify navigation.
    await tester.tap(agreeButton);
    await tester.pumpAndSettle();

    // Verify that we have navigated to the LoginScreen
    expect(find.byType(LoginScreen), findsOneWidget);
  });
} 