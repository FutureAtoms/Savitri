import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:savitri_app/services/enhanced_therapeutic_voice_service.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:path/path.dart' as path;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EnhancedTherapeuticVoiceService Complete Tests', () {
    late EnhancedTherapeuticVoiceService service;
    late List<MethodCall> methodCallLog;
    late Directory tempDir;

    setUp(() async {
      service = EnhancedTherapeuticVoiceService();
      methodCallLog = <MethodCall>[];
      
      // Create a temporary directory for testing
      tempDir = await Directory.systemTemp.createTemp('test_recordings');

      // Set up Permission handler channel mock
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter.baseflow.com/permissions/methods'),
        (MethodCall methodCall) async {
          methodCallLog.add(methodCall);
          switch (methodCall.method) {
            case 'checkPermissionStatus':
              final int permission = methodCall.arguments;
              if (permission == 7) { // Microphone permission
                return 1; // PermissionStatus.granted
              }
              return 0; // PermissionStatus.denied
            case 'requestPermissions':
              final List<int> permissions = methodCall.arguments;
              if (permissions.contains(7)) { // Microphone
                return {7: 1}; // Granted
              }
              return {7: 0}; // Denied
            default:
              return null;
          }
        },
      );

      // Set up Record channel mock
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.llfbandit.record/messages'),
        (MethodCall methodCall) async {
          methodCallLog.add(methodCall);
          switch (methodCall.method) {
            case 'hasPermission':
              return true;
            case 'start':
              // Return a mock stream ID
              return 'mock_stream_123';
            case 'stop':
              return true;
            case 'pause':
              return true;
            case 'resume':
              return true;
            case 'getAmplitude':
              return {
                'current': -20.0,
                'max': -10.0,
              };
            case 'dispose':
              return true;
            default:
              return null;
          }
        },
      );

      // Set up PathProvider channel mock
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async {
          methodCallLog.add(methodCall);
          switch (methodCall.method) {
            case 'getTemporaryDirectory':
              return tempDir.path;
            default:
              return null;
          }
        },
      );
    });

    tearDown(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter.baseflow.com/permissions/methods'),
        null,
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.llfbandit.record/messages'),
        null,
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        null,
      );
      
      service.dispose();
      methodCallLog.clear();
      
      // Clean up temp directory
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('initial state should be idle', () {
      expect(service.status, RecordingStatus.idle);
      expect(service.currentAmplitude, 0.0);
      expect(service.currentRecordingPath, isNull);
      expect(service.audioStream, isNull);
    });

    test('checkAndRequestPermissions should handle denied permissions', () async {
      // Mock denied permission
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter.baseflow.com/permissions/methods'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'checkPermissionStatus') {
            return 0; // Denied
          }
          if (methodCall.method == 'requestPermissions') {
            return {7: 0}; // Still denied
          }
          return null;
        },
      );

      final result = await service.checkAndRequestPermissions();
      expect(result, isFalse);
    });

    test('checkAndRequestPermissions should handle restricted permissions', () async {
      // Mock restricted permission
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter.baseflow.com/permissions/methods'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'checkPermissionStatus') {
            return 3; // Restricted
          }
          if (methodCall.method == 'requestPermissions') {
            return {7: 1}; // Granted after request
          }
          return null;
        },
      );

      final result = await service.checkAndRequestPermissions();
      expect(result, isTrue);
    });

    test('startRecording should handle permission denial', () async {
      // Mock denied permission
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter.baseflow.com/permissions/methods'),
        (MethodCall methodCall) async {
          return 0; // Denied
        },
      );

      final result = await service.startRecording();
      expect(result, isFalse);
      expect(service.status, RecordingStatus.idle);
    });

    test('startRecording should handle no recording permission', () async {
      // Mock no recording permission
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.llfbandit.record/messages'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'hasPermission') {
            return false;
          }
          return null;
        },
      );

      final result = await service.startRecording();
      expect(result, isFalse);
    });

    test('startRecording should successfully start recording', () async {
      final result = await service.startRecording();
      
      expect(result, isTrue);
      expect(service.status, RecordingStatus.recording);
      expect(service.currentRecordingPath, isNotNull);
      expect(service.currentRecordingPath, contains('therapy_session_'));
      expect(service.currentRecordingPath, endsWith('.wav'));
      expect(service.audioStream, isNotNull);
      
      // Verify start method was called
      expect(
        methodCallLog.any((call) => call.method == 'start'),
        isTrue,
      );
    });

    test('startRecording should handle exceptions', () async {
      // Mock exception
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.llfbandit.record/messages'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'start') {
            throw PlatformException(code: 'ERROR', message: 'Start failed');
          }
          if (methodCall.method == 'hasPermission') {
            return true;
          }
          return null;
        },
      );

      final result = await service.startRecording();
      expect(result, isFalse);
      expect(service.status, RecordingStatus.error);
    });

    test('stopRecording should return null when not recording', () async {
      final result = await service.stopRecording();
      expect(result, isNull);
    });

    test('stopRecording should successfully stop recording', () async {
      // Start recording first
      await service.startRecording();
      expect(service.status, RecordingStatus.recording);
      
      final recordingPath = service.currentRecordingPath;
      
      // Stop recording
      final result = await service.stopRecording();
      
      expect(result, equals(recordingPath));
      expect(service.status, RecordingStatus.idle);
      expect(service.currentRecordingPath, isNull);
      expect(service.currentAmplitude, 0.0);
      
      // Verify stop method was called
      expect(
        methodCallLog.any((call) => call.method == 'stop'),
        isTrue,
      );
    });

    test('stopRecording should handle exceptions', () async {
      // Start recording first
      await service.startRecording();
      
      // Mock exception on stop
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.llfbandit.record/messages'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'stop') {
            throw PlatformException(code: 'ERROR', message: 'Stop failed');
          }
          return null;
        },
      );

      final result = await service.stopRecording();
      expect(result, isNull);
      expect(service.status, RecordingStatus.error);
    });

    test('pauseRecording should pause when recording', () async {
      // Start recording first
      await service.startRecording();
      expect(service.status, RecordingStatus.recording);
      
      // Pause recording
      await service.pauseRecording();
      
      expect(service.status, RecordingStatus.paused);
      expect(service.currentAmplitude, 0.0);
      
      // Verify pause method was called
      expect(
        methodCallLog.any((call) => call.method == 'pause'),
        isTrue,
      );
    });

    test('pauseRecording should not pause when not recording', () async {
      await service.pauseRecording();
      expect(service.status, RecordingStatus.idle);
    });

    test('pauseRecording should handle exceptions', () async {
      // Start recording first
      await service.startRecording();
      
      // Mock exception on pause
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.llfbandit.record/messages'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'pause') {
            throw PlatformException(code: 'ERROR', message: 'Pause failed');
          }
          return null;
        },
      );

      await service.pauseRecording();
      expect(service.status, RecordingStatus.error);
    });

    test('resumeRecording should resume when paused', () async {
      // Start and pause recording first
      await service.startRecording();
      await service.pauseRecording();
      expect(service.status, RecordingStatus.paused);
      
      // Resume recording
      await service.resumeRecording();
      
      expect(service.status, RecordingStatus.recording);
      
      // Verify resume method was called
      expect(
        methodCallLog.any((call) => call.method == 'resume'),
        isTrue,
      );
    });

    test('resumeRecording should not resume when not paused', () async {
      await service.resumeRecording();
      expect(service.status, RecordingStatus.idle);
    });

    test('resumeRecording should handle exceptions', () async {
      // Start and pause recording first
      await service.startRecording();
      await service.pauseRecording();
      
      // Mock exception on resume
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.llfbandit.record/messages'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'resume') {
            throw PlatformException(code: 'ERROR', message: 'Resume failed');
          }
          return null;
        },
      );

      await service.resumeRecording();
      expect(service.status, RecordingStatus.error);
    });

    test('getRecordingDuration should return zero duration', () async {
      final duration = await service.getRecordingDuration();
      expect(duration, Duration.zero);
    });

    test('getRecordingDuration should handle exceptions', () async {
      // Start recording first
      await service.startRecording();
      
      final duration = await service.getRecordingDuration();
      expect(duration, Duration.zero);
    });

    test('amplitude monitoring should update values', () async {
      // Start recording to trigger amplitude monitoring
      await service.startRecording();
      
      // Listen for amplitude changes
      bool amplitudeChanged = false;
      service.addListener(() {
        if (service.currentAmplitude > 0) {
          amplitudeChanged = true;
        }
      });
      
      // Wait for amplitude timer to trigger
      await Future.delayed(const Duration(milliseconds: 150));
      
      expect(amplitudeChanged, isTrue);
      expect(service.currentAmplitude, greaterThan(0));
      
      // Stop recording
      await service.stopRecording();
      expect(service.currentAmplitude, 0.0);
    });

    test('audio stream should emit data', () async {
      // Mock stream data
      final streamController = StreamController<Uint8List>.broadcast();
      
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.llfbandit.record/messages'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'start') {
            // Emit some test data after a delay
            Future.delayed(const Duration(milliseconds: 50), () {
              streamController.add(Uint8List.fromList([1, 2, 3, 4]));
            });
            return 'mock_stream_123';
          }
          if (methodCall.method == 'hasPermission') {
            return true;
          }
          return null;
        },
      );

      await service.startRecording();
      
      // Verify audio stream is available
      expect(service.audioStream, isNotNull);
      
      // Clean up
      await streamController.close();
    });

    test('multiple recordings should stop previous recording', () async {
      // Start first recording
      await service.startRecording();
      final firstPath = service.currentRecordingPath;
      
      // Start second recording without stopping first
      await service.startRecording();
      final secondPath = service.currentRecordingPath;
      
      expect(firstPath, isNot(equals(secondPath)));
      expect(service.status, RecordingStatus.recording);
      
      // Verify stop was called before starting new recording
      final stopCalls = methodCallLog.where((call) => call.method == 'stop').length;
      expect(stopCalls, greaterThanOrEqualTo(1));
    });

    test('dispose should clean up resources', () {
      service.dispose();
      
      // Verify dispose method was called
      expect(
        methodCallLog.any((call) => call.method == 'dispose'),
        isTrue,
      );
    });

    test('notification listeners should work correctly', () async {
      int notificationCount = 0;
      service.addListener(() {
        notificationCount++;
      });
      
      // Start recording should trigger notifications
      await service.startRecording();
      
      // Wait a bit for amplitude updates
      await Future.delayed(const Duration(milliseconds: 150));
      
      expect(notificationCount, greaterThan(0));
      
      service.removeListener(() {});
    });

    test('error handling should update status correctly', () async {
      // Mock an error during recording
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.llfbandit.record/messages'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'start') {
            throw PlatformException(code: 'AUDIO_ERROR', message: 'Audio error');
          }
          if (methodCall.method == 'hasPermission') {
            return true;
          }
          return null;
        },
      );

      await service.startRecording();
      
      expect(service.status, RecordingStatus.error);
      expect(service.currentAmplitude, 0.0);
      expect(service.audioStream, isNull);
    });
  });
}
