import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savitri_app/services/biometric_auth_service.dart';
import 'package:savitri_app/screens/biometric_enrollment_screen.dart';
import 'package:savitri_app/widgets/biometric_login_button.dart';
import 'package:local_auth/local_auth.dart';

// Mock BiometricAuthService for testing
class MockBiometricAuthService extends BiometricAuthService {
  bool _mockIsAvailable = true;
  bool _mockIsEnabled = false;
  bool _mockIsEnrolled = false;
  bool _mockAuthResult = true;
  List<BiometricType> _mockBiometrics = [BiometricType.fingerprint];

  @override
  bool get isAvailable => _mockIsAvailable;
  
  @override
  bool get isEnabled => _mockIsEnabled;
  
  @override
  bool get isEnrolled => _mockIsEnrolled;
  
  @override
  List<BiometricType> get availableBiometrics => _mockBiometrics;

  void setMockAvailability(bool available) {
    _mockIsAvailable = available;
    notifyListeners();
  }

  void setMockEnabled(bool enabled) {
    _mockIsEnabled = enabled;
    notifyListeners();
  }

  void setMockEnrolled(bool enrolled) {
    _mockIsEnrolled = enrolled;
    notifyListeners();
  }

  void setMockAuthResult(bool result) {
    _mockAuthResult = result;
  }

  void setMockBiometrics(List<BiometricType> biometrics) {
    _mockBiometrics = biometrics;
    notifyListeners();
  }

  @override
  Future<bool> authenticate({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
    bool biometricOnly = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockAuthResult;
  }

  @override
  Future<bool> enableBiometric() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (_mockIsAvailable) {
      _mockIsEnabled = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  @override
  Future<bool> enrollBiometric() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (_mockIsAvailable && _mockIsEnabled) {
      _mockIsEnrolled = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  @override
  Future<bool> disableBiometric() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _mockIsEnabled = false;
    _mockIsEnrolled = false;
    notifyListeners();
    return true;
  }
}

void main() {
  group('BiometricAuthService Tests', () {
    late MockBiometricAuthService mockService;

    setUp(() {
      mockService = MockBiometricAuthService();
    });

    test('should initialize with correct default values', () {
      expect(mockService.isAvailable, isTrue);
      expect(mockService.isEnabled, isFalse);
      expect(mockService.isEnrolled, isFalse);
      expect(mockService.isAuthenticating, isFalse);
    });

    test('getBiometricTypeName should return correct names', () {
      mockService.setMockBiometrics([BiometricType.face]);
      expect(mockService.getBiometricTypeName(), 'Face ID');

      mockService.setMockBiometrics([BiometricType.fingerprint]);
      expect(mockService.getBiometricTypeName(), 'Touch ID');

      mockService.setMockBiometrics([BiometricType.iris]);
      expect(mockService.getBiometricTypeName(), 'Iris Authentication');

      mockService.setMockBiometrics([]);
      expect(mockService.getBiometricTypeName(), 'Biometric Authentication');
    });

    test('getBiometricIcon should return correct icons', () {
      mockService.setMockBiometrics([BiometricType.face]);
      expect(mockService.getBiometricIcon(), Icons.face);

      mockService.setMockBiometrics([BiometricType.fingerprint]);
      expect(mockService.getBiometricIcon(), Icons.fingerprint);

      mockService.setMockBiometrics([BiometricType.iris]);
      expect(mockService.getBiometricIcon(), Icons.remove_red_eye);
    });

    test('enableBiometric should work when available', () async {
      mockService.setMockAvailability(true);
      final result = await mockService.enableBiometric();
      expect(result, isTrue);
      expect(mockService.isEnabled, isTrue);
    });

    test('enableBiometric should fail when not available', () async {
      mockService.setMockAvailability(false);
      final result = await mockService.enableBiometric();
      expect(result, isFalse);
      expect(mockService.isEnabled, isFalse);
    });

    test('enrollBiometric should work when enabled', () async {
      mockService.setMockAvailability(true);
      await mockService.enableBiometric();
      final result = await mockService.enrollBiometric();
      expect(result, isTrue);
      expect(mockService.isEnrolled, isTrue);
    });

    test('disableBiometric should clear all settings', () async {
      mockService.setMockAvailability(true);
      await mockService.enableBiometric();
      await mockService.enrollBiometric();
      
      final result = await mockService.disableBiometric();
      expect(result, isTrue);
      expect(mockService.isEnabled, isFalse);
      expect(mockService.isEnrolled, isFalse);
    });
  });

  group('BiometricEnrollmentScreen Tests', () {
    late MockBiometricAuthService mockService;

    setUp(() {
      mockService = MockBiometricAuthService();
    });

    testWidgets('should display correct UI elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<BiometricAuthService>.value(
            value: mockService,
            child: const BiometricEnrollmentScreen(),
          ),
        ),
      );

      expect(find.text('Enable Touch ID'), findsOneWidget);
      expect(find.text('Enhanced Security'), findsOneWidget);
      expect(find.text('Quick Access'), findsOneWidget);
      expect(find.text('Privacy Protected'), findsOneWidget);
      expect(find.text('Skip for now'), findsOneWidget);
    });

    testWidgets('should show Face ID for face biometric', (WidgetTester tester) async {
      mockService.setMockBiometrics([BiometricType.face]);
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<BiometricAuthService>.value(
            value: mockService,
            child: const BiometricEnrollmentScreen(),
          ),
        ),
      );

      expect(find.text('Enable Face ID'), findsOneWidget);
    });

    testWidgets('should handle enrollment process', (WidgetTester tester) async {
      mockService.setMockAvailability(true);
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<BiometricAuthService>.value(
            value: mockService,
            child: const BiometricEnrollmentScreen(),
          ),
        ),
      );

      // Tap enable button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Enable Touch ID'));
      await tester.pump();

      // Should show loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for enrollment process
      await tester.pumpAndSettle();

      // Should be enrolled
      expect(mockService.isEnabled, isTrue);
      expect(mockService.isEnrolled, isTrue);
    });

    testWidgets('should handle unavailable biometric', (WidgetTester tester) async {
      mockService.setMockAvailability(false);
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<BiometricAuthService>.value(
            value: mockService,
            child: const BiometricEnrollmentScreen(),
          ),
        ),
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Enable Touch ID'));
      await tester.pumpAndSettle();

      expect(find.text('Biometric authentication is not available on this device'), 
             findsOneWidget);
    });
  });

  group('BiometricLoginButton Tests', () {
    late MockBiometricAuthService mockService;

    setUp(() {
      mockService = MockBiometricAuthService();
    });

    testWidgets('should not show when biometric not enrolled', 
        (WidgetTester tester) async {
      mockService.setMockEnrolled(false);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<BiometricAuthService>.value(
              value: mockService,
              child: BiometricLoginButton(
                onSuccess: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(BiometricLoginButton), findsOneWidget);
      expect(find.text('Login with Touch ID'), findsNothing);
    });

    testWidgets('should show when biometric is enrolled', 
        (WidgetTester tester) async {
      mockService.setMockAvailability(true);
      mockService.setMockEnabled(true);
      mockService.setMockEnrolled(true);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<BiometricAuthService>.value(
              value: mockService,
              child: BiometricLoginButton(
                onSuccess: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Login with Touch ID'), findsOneWidget);
      expect(find.text('OR'), findsOneWidget);
    });

    testWidgets('should handle successful authentication', 
        (WidgetTester tester) async {
      bool successCalled = false;
      mockService.setMockAvailability(true);
      mockService.setMockEnabled(true);
      mockService.setMockEnrolled(true);
      mockService.setMockAuthResult(true);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<BiometricAuthService>.value(
              value: mockService,
              child: BiometricLoginButton(
                onSuccess: () {
                  successCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Login with Touch ID'));
      await tester.pumpAndSettle();

      expect(successCalled, isTrue);
    });

    testWidgets('should handle failed authentication', 
        (WidgetTester tester) async {
      bool errorCalled = false;
      mockService.setMockAvailability(true);
      mockService.setMockEnabled(true);
      mockService.setMockEnrolled(true);
      mockService.setMockAuthResult(false);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<BiometricAuthService>.value(
              value: mockService,
              child: BiometricLoginButton(
                onSuccess: () {},
                onError: () {
                  errorCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Login with Touch ID'));
      await tester.pumpAndSettle();

      expect(errorCalled, isTrue);
      expect(find.text('Authentication failed'), findsOneWidget);
    });

    testWidgets('should show loading during authentication', 
        (WidgetTester tester) async {
      mockService.setMockAvailability(true);
      mockService.setMockEnabled(true);
      mockService.setMockEnrolled(true);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<BiometricAuthService>.value(
              value: mockService,
              child: BiometricLoginButton(
                onSuccess: () {},
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Login with Touch ID'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('BiometricSettingsDialog Tests', () {
    late MockBiometricAuthService mockService;

    setUp(() {
      mockService = MockBiometricAuthService();
    });

    testWidgets('should display correct settings', (WidgetTester tester) async {
      mockService.setMockEnabled(true);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<BiometricAuthService>.value(
              value: mockService,
              child: const BiometricSettingsDialog(),
            ),
          ),
        ),
      );

      expect(find.text('Touch ID Settings'), findsOneWidget);
      expect(find.text('Enable Touch ID'), findsOneWidget);
      expect(find.text('Currently enabled'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('should show complete setup when not enrolled', 
        (WidgetTester tester) async {
      mockService.setMockEnabled(true);
      mockService.setMockEnrolled(false);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<BiometricAuthService>.value(
              value: mockService,
              child: const BiometricSettingsDialog(),
            ),
          ),
        ),
      );

      expect(find.text('Complete Setup'), findsOneWidget);
    });

    testWidgets('should toggle biometric enable state', 
        (WidgetTester tester) async {
      mockService.setMockEnabled(false);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<BiometricAuthService>.value(
              value: mockService,
              child: const BiometricSettingsDialog(),
            ),
          ),
        ),
      );

      // Toggle switch
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(mockService.isEnabled, isTrue);
    });
  });
}
