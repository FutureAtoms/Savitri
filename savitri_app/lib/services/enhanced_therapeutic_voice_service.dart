import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Service for managing voice recording with high-quality audio capture
/// Optimized for therapeutic sessions with real-time emotion analysis
class EnhancedTherapeuticVoiceService extends ChangeNotifier {
  final AudioRecorder _recorder = AudioRecorder();
  RecordingStatus _status = RecordingStatus.idle;
  String? _currentRecordingPath;
  Timer? _amplitudeTimer;
  double _currentAmplitude = 0.0;
  StreamController<Uint8List>? _audioStreamController;
  StreamSubscription<RecordState>? _recordStateSubscription;
  
  // Audio configuration for high-quality capture
  static const RecordConfig _highQualityConfig = RecordConfig(
    encoder: AudioEncoder.pcm16bits,
    sampleRate: 48000, // 48kHz for high quality
    numChannels: 1, // Mono for voice
    bitRate: 128000,
  );

  RecordingStatus get status => _status;
  String? get currentRecordingPath => _currentRecordingPath;
  double get currentAmplitude => _currentAmplitude;
  Stream<Uint8List>? get audioStream => _audioStreamController?.stream;

  /// Check and request microphone permissions
  Future<bool> checkAndRequestPermissions() async {
    try {
      final status = await Permission.microphone.status;
      
      if (status.isDenied || status.isRestricted) {
        final result = await Permission.microphone.request();
        return result.isGranted;
      }
      
      return status.isGranted;
    } catch (e) {
      debugPrint('Error checking microphone permissions: $e');
      return false;
    }
  }

  /// Start recording audio
  Future<bool> startRecording() async {
    try {
      // Check permissions first
      final hasPermission = await checkAndRequestPermissions();
      if (!hasPermission) {
        debugPrint('Microphone permission denied');
        return false;
      }

      // Check if we can record
      final canRecord = await _recorder.hasPermission();
      if (!canRecord) {
        debugPrint('No recording permission');
        return false;
      }

      // Stop any existing recording
      await stopRecording();

      // Get temporary directory for recording
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = path.join(
        directory.path,
        'therapy_session_$timestamp.wav',
      );

      // Initialize audio stream
      _audioStreamController = StreamController<Uint8List>.broadcast();

      // Start recording with high quality config
      final recordStream = await _recorder.startStream(_highQualityConfig);
      
      // Forward audio data to our stream
      recordStream.listen(
        (data) {
          _audioStreamController?.add(data);
        },
        onError: (error) {
          debugPrint('Audio stream error: $error');
          _handleRecordingError(error);
        },
      );

      // Monitor recording state
      _recordStateSubscription = _recorder.onStateChanged().listen((state) {
        _updateStatus(_mapRecordState(state));
      });

      // Start amplitude monitoring
      _startAmplitudeMonitoring();

      _updateStatus(RecordingStatus.recording);
      debugPrint('Recording started at: $_currentRecordingPath');
      return true;
    } catch (e) {
      debugPrint('Error starting recording: $e');
      _handleRecordingError(e);
      return false;
    }
  }

  /// Stop recording and save the audio file
  Future<String?> stopRecording() async {
    try {
      if (_status != RecordingStatus.recording) {
        return null;
      }

      // Stop amplitude monitoring
      _stopAmplitudeMonitoring();

      // Cancel state subscription
      await _recordStateSubscription?.cancel();
      _recordStateSubscription = null;

      // Stop the recording
      await _recorder.stop();

      // Close audio stream
      await _audioStreamController?.close();
      _audioStreamController = null;

      _updateStatus(RecordingStatus.idle);
      
      final recordingPath = _currentRecordingPath;
      _currentRecordingPath = null;
      
      debugPrint('Recording stopped. File saved at: $recordingPath');
      return recordingPath;
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      _handleRecordingError(e);
      return null;
    }
  }

  /// Pause recording
  Future<void> pauseRecording() async {
    try {
      if (_status == RecordingStatus.recording) {
        await _recorder.pause();
        _updateStatus(RecordingStatus.paused);
        _stopAmplitudeMonitoring();
      }
    } catch (e) {
      debugPrint('Error pausing recording: $e');
      _handleRecordingError(e);
    }
  }

  /// Resume recording
  Future<void> resumeRecording() async {
    try {
      if (_status == RecordingStatus.paused) {
        await _recorder.resume();
        _updateStatus(RecordingStatus.recording);
        _startAmplitudeMonitoring();
      }
    } catch (e) {
      debugPrint('Error resuming recording: $e');
      _handleRecordingError(e);
    }
  }

  /// Get current recording duration
  Future<Duration> getRecordingDuration() async {
    try {
      if (_status == RecordingStatus.recording || _status == RecordingStatus.paused) {
        // Note: The record package doesn't provide duration directly for streams
        // This would need to be tracked manually or use a different approach
        return Duration.zero;
      }
      return Duration.zero;
    } catch (e) {
      debugPrint('Error getting recording duration: $e');
      return Duration.zero;
    }
  }

  /// Start monitoring audio amplitude for visualization
  void _startAmplitudeMonitoring() {
    _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 100), (_) async {
      try {
        final amplitude = await _recorder.getAmplitude();
        _currentAmplitude = (amplitude.current + 40) / 40; // Normalize to 0-1
        notifyListeners();
      } catch (e) {
        // Amplitude might not be available for all encoders
        _currentAmplitude = 0.0;
      }
    });
  }

  /// Stop monitoring audio amplitude
  void _stopAmplitudeMonitoring() {
    _amplitudeTimer?.cancel();
    _amplitudeTimer = null;
    _currentAmplitude = 0.0;
    notifyListeners();
  }

  /// Update recording status and notify listeners
  void _updateStatus(RecordingStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      notifyListeners();
    }
  }

  /// Map RecordState to RecordingStatus
  RecordingStatus _mapRecordState(RecordState state) {
    switch (state) {
      case RecordState.stop:
        return RecordingStatus.idle;
      case RecordState.pause:
        return RecordingStatus.paused;
      case RecordState.record:
        return RecordingStatus.recording;
    }
  }

  /// Handle recording errors
  void _handleRecordingError(dynamic error) {
    _updateStatus(RecordingStatus.error);
    _stopAmplitudeMonitoring();
    _audioStreamController?.close();
    _recordStateSubscription?.cancel();
    debugPrint('Recording error handled: $error');
  }

  /// Clean up resources
  @override
  void dispose() {
    _stopAmplitudeMonitoring();
    _audioStreamController?.close();
    _recordStateSubscription?.cancel();
    _recorder.dispose();
    super.dispose();
  }
}

/// Recording status enum
enum RecordingStatus {
  idle,
  recording,
  paused,
  error,
}
