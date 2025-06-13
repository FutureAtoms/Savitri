import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:savitri_app/services/biometric_auth_service.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BiometricAuthService Tests', () {
    late BiometricAuthService service;
    late List<MethodCall> methodCallLog;
    late bool biometricsSupported;
    late List<String> availableBiometrics;

    setUp(() {
      methodCallLog = <MethodCall>[];
      biometricsSupported = true;
      availableBiometrics = ['TouchID'];

      // Set up all mocks using test helpers
      setupAllMocks();

      // Override LocalAuthentication channel mock for specific test needs
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/local_auth'),
        (MethodCall methodCall) async {
          methodCallLog.add(methodCall);
          switch (methodCall.method) {
            case 'isDeviceSupported':
              return true;
            case 'deviceSupportsBiometrics':
              return biometricsSupported;
            case 'getAvailableBiometrics':
              return availableBiometrics;
            case 'authenticate':
              final Map<String, dynamic> args = Map<String, dynamic>.from(methodCall.arguments);
              return args['localizedReason'] == 'fail' ? false : true;
            case 'stopAuthentication':
              return true;
            default:
              return null;
          }
        },
      );

      // Set up FlutterSecureStorage channel mock
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
        (MethodCall methodCall) async {
          methodCallLog.add(methodCall);
          switch (methodCall.method) {
            case 'read':
              final Map<String, dynamic> args = Map<String, dynamic>.from(methodCall.arguments);
              final String key = args['key'];
              if (key == 'biometric_enabled') {
                return 'true';
              } else if (key == 'biometric_enrolled') {
                return 'true';
              }
              return null;
            case 'write':
              return null;
            case 'delete':
              return null;
            default:
              return null;
          }
        },
      );

      // Create service after mocks are set up
      service = BiometricAuthService();
    });

    tearDown(() {
      clearAllMocks();
      methodCallLog.clear();
      // Don't dispose service to avoid MissingPluginException
    });

    test('constructor should initialize biometrics', () async {
      // Give time for initialization
      await Future.delayed(const Duration(milliseconds: 100));

      // Check that service properties are initialized
      expect(service.isAvailable, isTrue);
      expect(service.isEnabled, isTrue);
      expect(service.isEnrolled, isTrue);
    });

    test('checkBiometricAvailability should return true when available', () async {
      final result = await service.checkBiometricAvailability();
      
      expect(result, isTrue);
      expect(service.isAvailable, isTrue);
    });

    test('checkBiometricAvailability should handle exceptions', () async {
      // Create a new service with mock that throws exception
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/local_auth'),
        (MethodCall methodCall) async {
          throw PlatformException(code: 'ERROR', message: 'Test error');
        },
      );

      final newService = BiometricAuthService();
      // Give time for initialization error
      await Future.delayed(const Duration(milliseconds: 100));
      
      final result = await newService.checkBiometricAvailability();
      
      expect(result, isFalse);
      expect(newService.isAvailable, isFalse);
    });

    test('enableBiometric should return true when available', () async {
      // Ensure service is initialized with available biometrics
      await Future.delayed(const Duration(milliseconds: 100));
      
      final result = await service.enableBiometric();
      
      expect(result, isTrue);
      expect(service.isEnabled, isTrue);
    });

    test('enableBiometric should return false when not available', () async {
      // Mock device not supporting biometrics
      biometricsSupported = false;
      
      // Re-initialize service to pick up new mock
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/local_auth'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'deviceSupportsBiometrics':
              return false;
            case 'getAvailableBiometrics':
              return [];
            default:
              return null;
          }
        },
      );
      
      final newService = BiometricAuthService();
      await Future.delayed(const Duration(milliseconds: 100));

      final result = await newService.enableBiometric();
      expect(result, isFalse);
    });

    test('enableBiometric should handle authentication failure', () async {
      // Mock authentication failure
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/local_auth'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'authenticate') {
            return false;
          }
          if (methodCall.method == 'deviceSupportsBiometrics') {
            return true;
          }
          if (methodCall.method == 'getAvailableBiometrics') {
            return ['TouchID'];
          }
          return null;
        },
      );

      final newService = BiometricAuthService();
      await Future.delayed(const Duration(milliseconds: 100));
      
      final result = await newService.enableBiometric();
      expect(result, isFalse);
    });

    test('disableBiometric should authenticate and disable', () async {
      // First enable biometric
      await Future.delayed(const Duration(milliseconds: 100));
      await service.enableBiometric();
      
      final result = await service.disableBiometric();
      
      expect(result, isTrue);
      expect(service.isEnabled, isFalse);
      expect(service.isEnrolled, isFalse);
    });

    test('enrollBiometric should fail when not enabled', () async {
      // Make sure biometric is not enabled
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'read') {
            return null; // Not enabled
          }
          return null;
        },
      );
      
      final newService = BiometricAuthService();
      await Future.delayed(const Duration(milliseconds: 100));
      
      final result = await newService.enrollBiometric();
      expect(result, isFalse);
    });

    test('enrollBiometric should succeed when enabled', () async {
      // First enable biometric
      await Future.delayed(const Duration(milliseconds: 100));
      await service.enableBiometric();
      
      final result = await service.enrollBiometric();
      
      expect(result, isTrue);
      expect(service.isEnrolled, isTrue);
    });

    test('authenticate should handle platform exceptions', () async {
      // Mock platform exception
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/local_auth'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'authenticate') {
            throw PlatformException(
              code: 'NotAvailable',
              message: 'Biometric authentication not available',
            );
          }
          return null;
        },
      );

      final newService = BiometricAuthService();
      await Future.delayed(const Duration(milliseconds: 100));
      
      final result = await newService.authenticate(reason: 'Test authentication');
      expect(result, isFalse);
    });

    test('authenticate should prevent concurrent authentications', () async {
      // Mock slow authentication
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/local_auth'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'authenticate') {
            await Future.delayed(const Duration(milliseconds: 200));
            return true;
          }
          if (methodCall.method == 'deviceSupportsBiometrics') {
            return true;
          }
          if (methodCall.method == 'getAvailableBiometrics') {
            return ['TouchID'];
          }
          return null;
        },
      );

      await Future.delayed(const Duration(milliseconds: 100));

      // Start first authentication
      final future1 = service.authenticate(reason: 'First auth');
      
      // Try to start second authentication immediately
      final result2 = await service.authenticate(reason: 'Second auth');
      
      // Second should fail because first is in progress
      expect(result2, isFalse);
      
      // Wait for first to complete
      final result1 = await future1;
      expect(result1, isTrue);
    });

    test('stopAuthentication should call platform method', () async {
      await service.stopAuthentication();
      
      expect(service.isAuthenticating, isFalse);
    });

    test('stopAuthentication should handle exceptions gracefully', () async {
      // Mock exception
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/local_auth'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'stopAuthentication') {
            throw PlatformException(code: 'ERROR', message: 'Stop failed');
          }
          return null;
        },
      );

      final newService = BiometricAuthService();
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Should not throw
      await newService.stopAuthentication();
      expect(newService.isAuthenticating, isFalse);
    });

    test('clearBiometricData should delete stored settings', () async {
      await service.clearBiometricData();
      
      expect(service.isEnabled, isFalse);
      expect(service.isEnrolled, isFalse);
    });

    test('clearBiometricData should handle exceptions gracefully', () async {
      // Mock exception
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'delete') {
            throw PlatformException(code: 'ERROR', message: 'Delete failed');
          }
          return null;
        },
      );

      final newService = BiometricAuthService();
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Should not throw
      await newService.clearBiometricData();
      expect(newService.isEnabled, isFalse);
      expect(newService.isEnrolled, isFalse);
    });

    test('getBiometricTypeName should return correct names', () {
      expect(service.getBiometricTypeName(), contains('Auth'));
    });

    test('getBiometricIcon should return an icon', () {
      final icon = service.getBiometricIcon();
      expect(icon, isNotNull);
    });

    test('dispose should clean up without errors', () async {
      // Create a disposable service
      final disposableService = BiometricAuthService();
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Dispose should not throw
      expect(() => disposableService.dispose(), returnsNormally);
    });
  });
}
