import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:incauca_labs/features/auth/application/bloc/auth_bloc.dart';
import 'package:incauca_labs/features/auth/application/bloc/auth_event.dart';
import 'package:incauca_labs/features/auth/application/bloc/auth_state.dart';
import 'package:incauca_labs/features/auth/data/auth_repository_impl.dart';
import 'package:incauca_labs/features/auth/domain/auth_datasource.dart';
import 'package:incauca_labs/features/auth/domain/entities/app_user.dart';

class MockAuthDatasource extends Mock implements AuthDatasource {}

void main() {
  late MockAuthDatasource mockAuthDatasource;
  late AuthRepositoryImpl authRepository;
  late AuthBloc authBloc;

  setUp(() {
    mockAuthDatasource = MockAuthDatasource();
    authRepository = AuthRepositoryImpl(mockAuthDatasource);
    authBloc = AuthBloc(authRepository: authRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  group('Auth Integration Tests (Test 1 & 2)', () {
    test('Test 1: AuthBloc completa el flujo signIn -> Authenticated con repository real', () async {
      final testUser = const AppUser(uid: '1', email: 'test@test.com', displayName: 'Test User');
      
      when(() => mockAuthDatasource.signIn('test@test.com', 'password'))
          .thenAnswer((_) async => testUser);
      when(() => mockAuthDatasource.signOut())
          .thenAnswer((_) async {});

      expect(authBloc.state, isA<AuthInitial>());

      // Wait for states
      final expectedStatesSignIn = [
        isA<AuthLoading>(),
        isA<Authenticated>().having((state) => state.user, 'user', testUser),
      ];

      expectLater(authBloc.stream, emitsInOrder(expectedStatesSignIn));
      
      // Dispatch SignIn
      authBloc.add(const SignInRequested('test@test.com', 'password'));

      // wait a bit for events to process
      await Future.delayed(const Duration(milliseconds: 100));

      final expectedStatesSignOut = [
        isA<AuthLoading>(),
        isA<Unauthenticated>(),
      ];

      expectLater(authBloc.stream, emitsInOrder(expectedStatesSignOut));

      // Dispatch SignOut
      authBloc.add(SignOutRequested());

      await Future.delayed(const Duration(milliseconds: 100));
    });

    test('Test 2: AuthBloc maneja error de signIn propagando el mensaje', () async {
      when(() => mockAuthDatasource.signIn('test@test.com', 'wrong_password'))
          .thenThrow(Exception('Invalid credentials'));

      expect(authBloc.state, isA<AuthInitial>());

      // Wait for states
      final expectedStates = [
        isA<AuthLoading>(),
        isA<Unauthenticated>().having((state) => state.error, 'error', contains('Invalid credentials')),
      ];

      expectLater(authBloc.stream, emitsInOrder(expectedStates));

      // Dispatch SignIn
      authBloc.add(const SignInRequested('test@test.com', 'wrong_password'));

      await Future.delayed(const Duration(milliseconds: 100));
    });
  });
}
