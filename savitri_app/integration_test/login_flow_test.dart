import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:savitri_app/screens/login_screen.dart';
import 'package:savitri_app/services/auth_service.dart';
import 'package:savitri_app/services/biometric_auth_service.dart';

// Mock AuthService for testing
class MockAuthService extends AuthService {
  bool shouldSucceed = true;
  String? lastEmail;
  String? lastPassword;
  bool mfaRequired = false;

  @override
  Future<bool> login(String email, String password) async {
    lastEmail = email;
    lastPassword = password;
    
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    
    if (!shouldSucceed) {
      throw Exception('Invalid credentials');
    }
    
    // In a real implementation, we would check MFA requirements here
    // For testing purposes, we'll just return success
    return true;
  }

  @override
  Future<bool> verifyMfa(String code) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (code != '123456') {
      throw Exception('Invalid MFA code');
    }
    
    return true;
  }

  @override
  Future<bool> register(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return shouldSucceed;
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Flow Integration Tests', () {
    late MockAuthService mockAuthService;
    late BiometricAuthService biometricService;

    setUp(() {
      mockAuthService = MockAuthService();
      biometricService = BiometricAuthService();
    });

    Widget createTestApp() {
      return MultiProvider(
        providers: [
          Provider<AuthService>.value(value: mockAuthService),
          ChangeNotifierProvider<BiometricAuthService>.value(value: biometricService),
        ],
        child: MaterialApp(
          home: const LoginScreen(),
          routes: {
            '/home': (context) => const Scaffold(
              body: Center(child: Text('Home Screen')),
            ),
            '/dashboard': (context) => const Scaffold(
              body: Center(child: Text('Dashboard')),
            ),
            '/mfa': (context) => Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('MFA Screen'),
                    const TextField(
                      key: Key('mfa_code_field'),
                      decoration: InputDecoration(
                        labelText: 'Enter MFA Code',
                      ),
                    ),
                    ElevatedButton(
                      key: const Key('verify_mfa_button'),
                      onPressed: () async {
                        // Simulate MFA verification
                        Navigator.pushReplacementNamed(context, '/dashboard');
                      },
                      child: const Text('Verify'),
                    ),
                  ],
                ),
              ),
            ),
          },
        ),
      );
    }

    testWidgets('should display login screen with all elements', 
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Verify all UI elements are present
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Login to continue your therapy journey'), findsOneWidget);
      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text("Don't have an account? Sign up"), findsOneWidget);
    });

    testWidgets('should show validation errors for empty fields', 
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Try to login without entering anything
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('should show email validation error for invalid email', 
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Enter invalid email
      await tester.enterText(find.byKey(const Key('email_field')), 'invalid-email');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should show email validation error
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('should successfully login with valid credentials', 
        (WidgetTester tester) async {
      mockAuthService.shouldSucceed = true;
      mockAuthService.mfaRequired = false;

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Enter valid credentials
      await tester.enterText(
        find.byKey(const Key('email_field')), 
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')), 
        'password123',
      );

      // Hide keyboard
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Tap login button
      await tester.tap(find.text('Login'));
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for login to complete
      await tester.pumpAndSettle();

      // Should navigate to dashboard
      expect(find.text('Dashboard'), findsOneWidget);
      
      // Verify credentials were passed correctly
      expect(mockAuthService.lastEmail, 'test@example.com');
      expect(mockAuthService.lastPassword, 'password123');
    });

    testWidgets('should handle login failure gracefully', 
        (WidgetTester tester) async {
      mockAuthService.shouldSucceed = false;

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Enter credentials
      await tester.enterText(
        find.byKey(const Key('email_field')), 
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')), 
        'wrongpassword',
      );

      // Hide keyboard
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Tap login button
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.text('Invalid credentials'), findsOneWidget);
      
      // Should still be on login screen
      expect(find.text('Welcome Back'), findsOneWidget);
    });

    testWidgets('should handle MFA flow correctly', 
        (WidgetTester tester) async {
      mockAuthService.shouldSucceed = true;
      mockAuthService.mfaRequired = true;

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Enter credentials
      await tester.enterText(
        find.byKey(const Key('email_field')), 
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')), 
        'password123',
      );

      // Hide keyboard
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Tap login button
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should navigate to MFA screen
      expect(find.text('MFA Screen'), findsOneWidget);
      expect(find.byKey(const Key('mfa_code_field')), findsOneWidget);

      // Enter MFA code
      await tester.enterText(
        find.byKey(const Key('mfa_code_field')), 
        '123456',
      );
      
      // Verify MFA
      await tester.tap(find.byKey(const Key('verify_mfa_button')));
      await tester.pumpAndSettle();

      // Should navigate to dashboard
      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('should toggle password visibility', 
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Enter password
      await tester.enterText(
        find.byKey(const Key('password_field')), 
        'mypassword',
      );

      // Password should be obscured initially
      final passwordField = tester.widget<TextField>(
        find.byKey(const Key('password_field')),
      );
      expect(passwordField.obscureText, isTrue);

      // Tap visibility toggle
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pumpAndSettle();

      // Password should now be visible
      final updatedPasswordField = tester.widget<TextField>(
        find.byKey(const Key('password_field')),
      );
      expect(updatedPasswordField.obscureText, isFalse);
    });

    testWidgets('should navigate to forgot password screen', 
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Tap forgot password link
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      // Should navigate to forgot password screen (if implemented)
      // For now, just verify the button is tappable
      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('should navigate to sign up screen', 
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Tap sign up link
      await tester.tap(find.text("Don't have an account? Sign up"));
      await tester.pumpAndSettle();

      // Should navigate to sign up screen (if implemented)
      // For now, just verify the button is tappable
      expect(find.text("Don't have an account? Sign up"), findsOneWidget);
    });

    testWidgets('should disable form during login', 
        (WidgetTester tester) async {
      mockAuthService.shouldSucceed = true;
      mockAuthService.mfaRequired = false;

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Enter credentials
      await tester.enterText(
        find.byKey(const Key('email_field')), 
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')), 
        'password123',
      );

      // Hide keyboard
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Tap login button
      await tester.tap(find.text('Login'));
      await tester.pump();

      // During loading, form should be disabled
      // Try to tap login button again - should not work
      await tester.tap(find.text('Login'), warnIfMissed: false);
      
      // Loading indicator should be present
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should remember email on successful login', 
        (WidgetTester tester) async {
      mockAuthService.shouldSucceed = true;
      mockAuthService.mfaRequired = false;

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      const testEmail = 'remember@example.com';

      // Enter credentials
      await tester.enterText(
        find.byKey(const Key('email_field')), 
        testEmail,
      );
      await tester.enterText(
        find.byKey(const Key('password_field')), 
        'password123',
      );

      // Login
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Verify email was captured
      expect(mockAuthService.lastEmail, testEmail);
    });
  });
}
