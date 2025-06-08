import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:savitri_app/services/auth_service.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  late AuthService authService;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    authService = AuthService(dio: mockDio);
  });

  group('AuthService', () {
    test('login returns true on success', () async {
      when(mockDio.post(any, data: anyNamed('data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        ),
      );

      final result = await authService.login('test@test.com', 'password');
      expect(result, true);
    });

    test('login returns false on failure', () async {
      when(mockDio.post(any, data: anyNamed('data'))).thenThrow(Exception());

      final result = await authService.login('test@test.com', 'password');
      expect(result, false);
    });

    test('register returns true on success', () async {
      when(mockDio.post(any, data: anyNamed('data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 201,
        ),
      );

      final result = await authService.register('test@test.com', 'password');
      expect(result, true);
    });

    test('register returns false on failure', () async {
      when(mockDio.post(any, data: anyNamed('data'))).thenThrow(Exception());

      final result = await authService.register('test@test.com', 'password');
      expect(result, false);
    });

    test('verifyMfa returns true on success', () async {
      when(mockDio.post(any, data: anyNamed('data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        ),
      );

      final result = await authService.verifyMfa('123456');
      expect(result, true);
    });

    test('verifyMfa returns false on failure', () async {
      when(mockDio.post(any, data: anyNamed('data'))).thenThrow(Exception());

      final result = await authService.verifyMfa('123456');
      expect(result, false);
    });
  });
}
