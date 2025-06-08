import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for managing biometric authentication
class BiometricAuthService extends ChangeNotifier {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricEnrolledKey = 'biometric_enrolled';
  
  bool _isAvailable = false;
  bool _isEnabled = false;
  bool _isEnrolled = false;
  List<BiometricType> _availableBiometrics = [];
  bool _isAuthenticating = false;

  bool get isAvailable => _isAvailable;
  bool get isEnabled => _isEnabled;
  bool get isEnrolled => _isEnrolled;
  bool get isAuthenticating => _isAuthenticating;
  List<BiometricType> get availableBiometrics => _availableBiometrics;

  BiometricAuthService() {
    _initializeBiometrics();
  }

  /// Initialize biometric capabilities
  Future<void> _initializeBiometrics() async {
    try {
      // Check if device supports biometrics
      _isAvailable = await _localAuth.canCheckBiometrics;
      
      if (_isAvailable) {
        // Get available biometric types
        _availableBiometrics = await _localAuth.getAvailableBiometrics();
        
        // Check if biometrics are enabled by user
        final enabledString = await _secureStorage.read(key: _biometricEnabledKey);
        _isEnabled = enabledString == 'true';
        
        // Check if user has enrolled
        final enrolledString = await _secureStorage.read(key: _biometricEnrolledKey);
        _isEnrolled = enrolledString == 'true';
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing biometrics: $e');
      _isAvailable = false;
      _isEnabled = false;
      _isEnrolled = false;
      notifyListeners();
    }
  }

  /// Check if biometric authentication is available
  Future<bool> checkBiometricAvailability() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      
      _isAvailable = canCheck && isDeviceSupported;
      
      if (_isAvailable) {
        _availableBiometrics = await _localAuth.getAvailableBiometrics();
      }
      
      notifyListeners();
      return _isAvailable;
    } catch (e) {
      debugPrint('Error checking biometric availability: $e');
      return false;
    }
  }

  /// Enable biometric authentication
  Future<bool> enableBiometric() async {
    try {
      if (!_isAvailable) {
        debugPrint('Biometric authentication not available');
        return false;
      }

      // First authenticate to enable biometrics
      final authenticated = await authenticate(
        reason: 'Please authenticate to enable biometric login',
      );

      if (authenticated) {
        await _secureStorage.write(key: _biometricEnabledKey, value: 'true');
        _isEnabled = true;
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error enabling biometric: $e');
      return false;
    }
  }

  /// Disable biometric authentication
  Future<bool> disableBiometric() async {
    try {
      // Authenticate before disabling
      final authenticated = await authenticate(
        reason: 'Please authenticate to disable biometric login',
      );

      if (authenticated) {
        await _secureStorage.write(key: _biometricEnabledKey, value: 'false');
        await _secureStorage.write(key: _biometricEnrolledKey, value: 'false');
        _isEnabled = false;
        _isEnrolled = false;
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error disabling biometric: $e');
      return false;
    }
  }

  /// Enroll user for biometric authentication
  Future<bool> enrollBiometric() async {
    try {
      if (!_isAvailable || !_isEnabled) {
        debugPrint('Biometric not available or not enabled');
        return false;
      }

      // Authenticate to enroll
      final authenticated = await authenticate(
        reason: 'Please authenticate to complete biometric enrollment',
      );

      if (authenticated) {
        await _secureStorage.write(key: _biometricEnrolledKey, value: 'true');
        _isEnrolled = true;
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error enrolling biometric: $e');
      return false;
    }
  }

  /// Authenticate using biometrics
  Future<bool> authenticate({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
    bool biometricOnly = false,
  }) async {
    if (_isAuthenticating) {
      debugPrint('Authentication already in progress');
      return false;
    }

    try {
      _isAuthenticating = true;
      notifyListeners();

      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: biometricOnly,
        ),
      );

      return authenticated;
    } on PlatformException catch (e) {
      debugPrint('Platform exception during authentication: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Error during authentication: $e');
      return false;
    } finally {
      _isAuthenticating = false;
      notifyListeners();
    }
  }

  /// Get user-friendly biometric type name
  String getBiometricTypeName() {
    if (_availableBiometrics.isEmpty) {
      return 'Biometric Authentication';
    }

    if (_availableBiometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Touch ID';
    } else if (_availableBiometrics.contains(BiometricType.iris)) {
      return 'Iris Authentication';
    }

    return 'Biometric Authentication';
  }

  /// Get appropriate icon for available biometric type
  IconData getBiometricIcon() {
    if (_availableBiometrics.isEmpty) {
      return Icons.fingerprint;
    }

    if (_availableBiometrics.contains(BiometricType.face)) {
      return Icons.face;
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return Icons.fingerprint;
    } else if (_availableBiometrics.contains(BiometricType.iris)) {
      return Icons.remove_red_eye;
    }

    return Icons.fingerprint;
  }

  /// Stop any ongoing authentication
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
      _isAuthenticating = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error stopping authentication: $e');
    }
  }

  /// Clear all biometric settings
  Future<void> clearBiometricData() async {
    try {
      await _secureStorage.delete(key: _biometricEnabledKey);
      await _secureStorage.delete(key: _biometricEnrolledKey);
      _isEnabled = false;
      _isEnrolled = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing biometric data: $e');
    }
  }

  @override
  void dispose() {
    stopAuthentication();
    super.dispose();
  }
}
