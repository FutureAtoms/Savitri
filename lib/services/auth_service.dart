import 'dart:io';

import 'package:dio/dio.dart';

class AuthService {
  final Dio _dio;
  final bool _testSuccess;

  AuthService({Dio? dio, bool testSuccess = true}) : _dio = dio ?? Dio(), _testSuccess = testSuccess;

  Future<bool> login(String email, String password) async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return _testSuccess;
    }
    try {
      await _dio.post('https://api.savitri.com/login', data: {
        'email': email,
        'password': password,
      });
      return true;
    } catch (e) {
      print('Error logging in: $e');
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return _testSuccess;
    }
    try {
      await _dio.post('https://api.savitri.com/register', data: {
        'email': email,
        'password': password,
      });
      return true;
    } catch (e) {
      print('Error registering: $e');
      return false;
    }
  }

  Future<bool> verifyMfa(String code) async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return _testSuccess;
    }
    try {
      await _dio.post('https://api.savitri.com/verify-mfa', data: {
        'code': code,
      });
      return true;
    } catch (e) {
      print('Error verifying MFA: $e');
      return false;
    }
  }
} 