import 'package:flutter/material.dart';

/// Application constants and configuration
class AppConstants {
  // App Information
  static const String appName = 'Savitri';
  static const String appVersion = '1.0.0';
  
  // API Endpoints
  static const String authEndpoint = '/api/auth';
  static const String sessionsEndpoint = '/api/sessions';
  static const String emotionsEndpoint = '/api/emotions';
  
  // WebView URLs
  static const String liveAudioUrl = '/live-audio';
  
  // Duration constants
  static const Duration sessionTimeout = Duration(minutes: 30);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration breathingCycleDuration = Duration(seconds: 19); // 4-7-8 pattern
  
  // Audio configuration
  static const int audioSampleRate = 48000;
  static const int audioBitrate = 128000;
  
  // HIPAA compliance
  static const int sessionExpiryDays = 30;
  static const int maxLoginAttempts = 3;
  
  // Assessment IDs
  static const String phq9AssessmentId = 'PHQ-9';
  static const String gad7AssessmentId = 'GAD-7';
}

/// Theme colors for the application
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF5B9FED);
  static const Color primaryDark = Color(0xFF3B7EC8);
  static const Color primaryLight = Color(0xFF8BB9F2);
  
  // Emotional state colors
  static const Color calm = Color(0xFF7CB8CF);
  static const Color happy = Color(0xFFF7D060);
  static const Color anxious = Color(0xFFFF9F40);
  static const Color sad = Color(0xFF6C7A89);
  static const Color angry = Color(0xFFE74C3C);
  static const Color neutral = Color(0xFF95A5A6);
  
  // UI colors
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFE74C3C);
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  
  // Text colors
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textLight = Color(0xFFBDC3C7);
  
  // Crisis colors
  static const Color crisisBackground = Color(0xFFFFEBEE);
  static const Color crisisText = Color(0xFFD32F2F);
}

/// Text styles for the application
class AppTextStyles {
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle headline3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
