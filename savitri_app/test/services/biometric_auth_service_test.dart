import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:savitri_app/services/biometric_auth_service.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BiometricAuthService Tests', () {
    late BiometricAuthService service;
    late List<MethodCall> methodCallLog;

    setUp(() {
      service = BiometricAuthService();
      methodCallLog = <MethodCall>[];

      // Set up LocalAuthentication channel mock
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/local_auth'),
        (MethodCall methodCall) async {
          methodCallLog.add(methodCall);
          switch (methodCall.method) {
            case 'isDeviceSupported':
              return true;
            case 'deviceSupportsBiometrics':
              return true;
            case 'getAvailableBiometrics':
              return ['TouchID'];
            case 'authenticate':
              final Map<String, dynamic> args = methodCall.arguments;
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
              final Map<String, dynamic> args = methodCall.arguments;
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
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/local_auth'),
        null,
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
        null,
      );
      methodCallLog.clear();
    });

    test('constructor should initialize biometrics', () async {
      // Give time for initialization
      await Future.delayed(const Duration(milliseconds: 100));

      // Check that initialization methods were called
      expect(
        methodCallLog.any((call) => call.method == 'deviceSupportsBiometrics'),
        isTrue,
      );
      expect(
        methodCallLog.any((call) => call.method == 'getAvailableBiometrics'),
        isTrue,
      );
    });

    test('checkBiometricAvailability should return true when available', () async {
      final result = await service.checkBiometricAvailability();
      
      expect(result, isTrue);
      expect(service.isAvailable, isTrue);
      expect(
        methodCallLog.any((call) => call.method == 'deviceSupportsBiometrics'),
        isTrue,
      );
      expect(
        methodCallLog.any((call) => call.method == 'isDeviceSupported'),
        isTrue,
      );
    });

    test('checkBiometricAvailability should handle exceptions', () async {
      // Set up mock to throw exception
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/local_auth'),
        (MethodCall methodCall) async {
          throw PlatformException(code: 'ERROR', message: 'Test error');
        },
      );

      final result = await service.checkBiometricAvailability();
      
      expect(result, isFalse);
      expect(service.isAvailable, isFalse);
    });

    test('enableBiometric should return false when not available', () async {
      // Mock device not supporting biometrics
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/local_auth'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'deviceSupportsBiometrics') {
            return false;
          }
          return null;
        },
      );

      // Re-initialize to pick up new mock
      service = BiometricAuthService();
      await Future.delayed(const Duration(milliseconds: 100));

      final result = await service.enableBiometric();
      expect(result, isFalse);
    });

    test('enableBiometric should authenticate and enable when available', () async {
      // Ensure service is initialized with available biometrics
      await Future.delayed(const Duration(milliseconds: 100));
      
      final result = await service.enableBiometric();
      
      expect(result, isTrue);
      expect(service.isEnabled, isTrue);
      expect(
        methodCallLog.any((call) => 
          call.method == 'authenticate' &&
          call.arguments['localizedReason'] == 
            'Please authenticate to enable biometric login'
        ),
        isTrue,
      );
      expect(
        methodCallLog.any((call) => 
          call.method == 'write' &&
          call.arguments['key'] == 'biometric_enabled' &&
          call.arguments['value'] == 'true'
        ),
        isTrue,
      );
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

      await Future.delayed(const Duration(milliseconds: 100));
      
      final result = await service.enableBiometric();
      expect(result, isFalse);
      expect(service.isEnabled, isFalse);
    });

    test('disableBiometric should authenticate and disable', () async {
      // First enable biometric
      await Future.delayed(const Duration(milliseconds: 100));
      await service.enableBiometric();
      
      final result = await service.disableBiometric();
      
      expect(result, isTrue);
      expect(service.isEnabled, isFalse);
      expect(service.isEnrolled, isFalse);
      expect(
        methodCallLog.any((call) => 
          call.method == 'write' &&
          call.arguments['key'] == 'biometric_enabled' &&
          call.arguments['value'] == 'false'
        ),
        isTrue,
      );
    });

    test('enrollBiometric should fail when not enabled', () async {
      // Make sure biometric is not enabled
      await Future.delayed(const Duration(milliseconds: 100));
      
      final result = await service.enrollBiometric();
      expect(result, isFalse);
    });

    test('enrollBiometric should succeed when enabled', () async {
      // First enable biometric
      await Future.delayed(const Duration(milliseconds: 100));
      await service.enableBiometric();
      
      final result = await service.enrollBiometric();
      
      expect(result, isTrue);
      expect(service.isEnrolled, isTrue);
      expect(
        methodCallLog.any((call) => 
          call.method == 'write' &&
          call.arguments['key'] == 'biometric_enrolled' &&
          call.arguments['value'] == 'true'
        ),
        isTrue,
      );
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

      final result = await service.authenticate(reason: 'Test authentication');
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
      
      expect(
        methodCallLog.any((call) => call.method == 'stopAuthentication'),
        isTrue,
      );
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

      // Should not throw
      await service.stopAuthentication();
      expect(service.isAuthenticating, isFalse);
    });

    test('clearBiometricData should delete stored settings', () async {
      await service.clearBiometricData();
      
      expect(
        methodCallLog.any((call) => 
          call.method == 'delete' &&
          call.arguments['key'] == 'biometric_enabled'
        ),
        isTrue,
      );
      expect(
        methodCallLog.any((call) => 
          call.method == 'delete' &&
          call.arguments['key'] == 'biometric_enrolled'
        ),
        isTrue,
      );
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

      // Should not throw
      await service.clearBiometricData();
      expect(service.isEnabled, isFalse);
      expect(service.isEnrolled, isFalse);
    });

    test('getBiometricTypeName should return correct names', () {
      expect(service.getBiometricTypeName(), contains('Auth'));
    });

    test('getBiometricIcon should return an icon', () {
      final icon = service.getBiometricIcon();
      expect(icon, isNotNull);
    });

    test('dispose should stop authentication', () async {
      service.dispose();
      
      // Give time for async operations
      await Future.delayed(const Duration(milliseconds: 50));
      
      expect(
        methodCallLog.any((call) => call.method == 'stopAuthentication'),
        isTrue,
      );
    });
  });
}
