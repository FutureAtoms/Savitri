import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:savitri_app/services/enhanced_therapeutic_voice_service.dart';
import '../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EnhancedTherapeuticVoiceService Tests', () {
    late EnhancedTherapeuticVoiceService service;

    setUp(() {
      service = EnhancedTherapeuticVoiceService();
      
      // Set up platform channel mocks
      setupAllMocks();
    });

    tearDown(() {
      // Don't dispose service to avoid plugin exceptions
      clearAllMocks();
    });

    group('Permission Tests', () {
      test('checkAndRequestPermissions should handle permission flow', () async {
        // Mock permission granted
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/permissions/methods'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'checkPermissionStatus') {
              return 1; // Granted
            }
            return null;
          },
        );

        final result = await service.checkAndRequestPermissions();
        expect(result, isTrue);
      });
    });

    group('Recording Flow Tests', () {
      test('startRecording should update status to recording', () async {
        // Mock permission and recorder
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/permissions/methods'),
          (MethodCall methodCall) async {
            return 1; // Granted
          },
        );

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('com.llfbandit.record/messages'),
          (MethodCall methodCall) async {
            switch (methodCall.method) {
              case 'hasPermission':
                return true;
              case 'startStream':
                return 'mock_stream';
              case 'onStateChanged':
                return null;
              default:
                return null;
            }
          },
        );

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getTemporaryDirectory') {
              return '/tmp/test';
            }
            return null;
          },
        );

        final result = await service.startRecording();
        
        expect(result, isTrue);
        expect(service.status, RecordingStatus.recording);
        expect(service.currentRecordingPath, isNotNull);
      });
    });
  });
}
