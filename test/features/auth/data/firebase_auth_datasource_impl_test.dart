import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:incauca_labs/features/auth/data/firebase_auth_datasource_impl.dart';
import 'package:incauca_labs/features/auth/domain/entities/app_user.dart';

// Mock classes
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;
  late FirebaseAuthDatasourceImpl datasource;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    datasource = FirebaseAuthDatasourceImpl(mockFirebaseAuth);
  });

  group('FirebaseAuthDatasourceImpl', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';

    group('signIn', () {
      test('returns AppUser when sign in succeeds', () async {
        when(() => mockUser.uid).thenReturn('uid-123');
        when(() => mockUser.email).thenReturn(testEmail);
        when(() => mockUser.displayName).thenReturn('Test User');
        when(() => mockUser.photoURL).thenReturn(null);
        when(() => mockUser.getIdToken(any())).thenAnswer((_) async => 'id-token-abc');

        when(() => mockUserCredential.user).thenReturn(mockUser);

        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            )).thenAnswer((_) async => mockUserCredential);

        final result = await datasource.signIn(testEmail, testPassword);

        expect(result, isA<AppUser>());
        expect(result.uid, 'uid-123');
        expect(result.email, testEmail);
      });

      test('returns AppUser.empty when user is null in credential', () async {
        when(() => mockUserCredential.user).thenReturn(null);

        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            )).thenAnswer((_) async => mockUserCredential);

        final result = await datasource.signIn(testEmail, testPassword);

        expect(result, equals(AppUser.empty));
        expect(result.uid, '');
      });

      test('throws when FirebaseAuth throws FirebaseAuthException', () async {
        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(
          FirebaseAuthException(code: 'user-not-found'),
        );

        await expectLater(
          () => datasource.signIn(testEmail, testPassword),
          throwsA(isA<FirebaseAuthException>()),
        );
      });
    });

    group('signOut', () {
      test('calls FirebaseAuth.signOut', () async {
        when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});

        await datasource.signOut();

        verify(() => mockFirebaseAuth.signOut()).called(1);
      });

      test('throws when FirebaseAuth.signOut throws', () async {
        when(() => mockFirebaseAuth.signOut())
            .thenThrow(FirebaseAuthException(code: 'network-request-failed'));

        await expectLater(
          () => datasource.signOut(),
          throwsA(isA<FirebaseAuthException>()),
        );
      });
    });
  });
}
