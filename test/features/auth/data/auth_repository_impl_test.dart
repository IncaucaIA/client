import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:incauca_labs/features/auth/domain/auth_datasource.dart';
import 'package:incauca_labs/features/auth/domain/entities/app_user.dart';
import 'package:incauca_labs/features/auth/data/auth_repository_impl.dart';

class MockAuthDatasource extends Mock implements AuthDatasource {}

void main() {
  late MockAuthDatasource mockDatasource;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockDatasource = MockAuthDatasource();
    repository = AuthRepositoryImpl(mockDatasource);
  });

  group('AuthRepositoryImpl', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';
    const testUser = AppUser(uid: '123', email: testEmail);

    test('signIn should call datasource and return AppUser', () async {
      when(() => mockDatasource.signIn(testEmail, testPassword))
          .thenAnswer((_) async => testUser);

      final result = await repository.signIn(testEmail, testPassword);

      verify(() => mockDatasource.signIn(testEmail, testPassword)).called(1);
      expect(result, equals(testUser));
    });

    test('signOut should call datasource', () async {
      when(() => mockDatasource.signOut()).thenAnswer((_) async {});

      await repository.signOut();

      verify(() => mockDatasource.signOut()).called(1);
    });
  });
}
