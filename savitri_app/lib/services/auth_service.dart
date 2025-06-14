import 'package:dio/dio.dart';

class AuthService {
  final Dio _dio;

  AuthService({Dio? dio}) : _dio = dio ?? Dio();

  Future<bool> login(String email, String password) async {
    try {
      await _dio.post('https://api.savitri.com/login', data: {
        'email': email,
        'password': password,
      });
      return true;
    } catch (e) {
      // In production, use proper logging instead of print
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      await _dio.post('https://api.savitri.com/register', data: {
        'email': email,
        'password': password,
      });
      return true;
    } catch (e) {
      // In production, use proper logging instead of print
      return false;
    }
  }

  Future<bool> verifyMfa(String code) async {
    try {
      await _dio.post('https://api.savitri.com/verify-mfa', data: {
        'code': code,
      });
      return true;
    } catch (e) {
      // In production, use proper logging instead of print
      return false;
    }
  }
}
