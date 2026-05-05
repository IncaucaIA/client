import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:incauca_labs/core/config.dart';
import 'package:incauca_labs/features/auth/data/local_auth_datasource_impl.dart';
import 'package:incauca_labs/features/auth/domain/entities/app_user.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockHttpClient mockHttpClient;
  late LocalAuthDatasourceImpl datasource;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    AppConfig.initialize();
    SharedPreferences.setMockInitialValues({});
    mockHttpClient = MockHttpClient();
    datasource = LocalAuthDatasourceImpl(httpClient: mockHttpClient);
  });

  group('LocalAuthDatasourceImpl', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';

    group('signIn', () {
      test('returns AppUser and stores token when response is 200', () async {
        final responseBody = jsonEncode({'access_token': 'my-token-123'});
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response(responseBody, 200));

        final result = await datasource.signIn(testEmail, testPassword);

        expect(result, isA<AppUser>());
        expect(result.email, testEmail);
        expect(result.uid, testEmail);
        expect(result.displayName, 'test');

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('access_token'), 'my-token-123');
      });

      test('throws Exception when response is not 200', () async {
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response('Unauthorized', 401));

        expect(
          () => datasource.signIn(testEmail, testPassword),
          throwsA(isA<Exception>()),
        );
      });

      test('throws Exception when request throws', () async {
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenThrow(Exception('Network error'));

        await expectLater(
          () => datasource.signIn(testEmail, testPassword),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('signOut', () {
      test('removes token from shared preferences', () async {
        SharedPreferences.setMockInitialValues({'access_token': 'some-token'});

        await datasource.signOut();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('access_token'), isNull);
      });
    });

    group('getToken', () {
      test('returns token when it exists', () async {
        SharedPreferences.setMockInitialValues({'access_token': 'stored-token'});

        final token = await LocalAuthDatasourceImpl.getToken();
        expect(token, 'stored-token');
      });

      test('returns null when no token is stored', () async {
        SharedPreferences.setMockInitialValues({});

        final token = await LocalAuthDatasourceImpl.getToken();
        expect(token, isNull);
      });
    });
  });
}
