import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incauca_labs/features/auth/application/bloc/auth_bloc.dart';
import 'package:incauca_labs/features/auth/application/bloc/auth_event.dart';
import 'package:incauca_labs/features/auth/application/bloc/auth_state.dart';
import 'package:incauca_labs/features/auth/domain/auth_repository.dart';
import 'package:incauca_labs/features/auth/domain/entities/app_user.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('AuthBloc', () {
    late AuthRepository authRepository;
    late AuthBloc authBloc;

    const tUser = AppUser(uid: '1', email: 'test@test.com', displayName: 'Test User');
    const tEmail = 'test@test.com';
    const tPassword = 'password123';

    setUp(() {
      authRepository = MockAuthRepository();
      authBloc = AuthBloc(authRepository: authRepository);
    });

    tearDown(() {
      authBloc.close();
    });

    test('initial state is AuthInitial', () {
      expect(authBloc.state, equals(AuthInitial()));
    });

    group('AuthStarted', () {
      blocTest<AuthBloc, AuthState>(
        'emits [Unauthenticated] when AuthStarted is added',
        build: () => authBloc,
        act: (bloc) => bloc.add(AuthStarted()),
        expect: () => const <AuthState>[
          Unauthenticated(),
        ],
      );
    });

    group('SignInRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Authenticated] when SignInRequested is successful',
        build: () {
          when(() => authRepository.signIn(tEmail, tPassword))
              .thenAnswer((_) async => tUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(SignInRequested(tEmail, tPassword)),
        expect: () => <AuthState>[
          AuthLoading(),
          const Authenticated(tUser),
        ],
        verify: (_) {
          verify(() => authRepository.signIn(tEmail, tPassword)).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Unauthenticated] when SignInRequested fails',
        build: () {
          when(() => authRepository.signIn(tEmail, tPassword))
              .thenThrow(Exception('Failed to sign in'));
          return authBloc;
        },
        act: (bloc) => bloc.add(SignInRequested(tEmail, tPassword)),
        expect: () => <AuthState>[
          AuthLoading(),
          const Unauthenticated(error: 'Exception: Failed to sign in'),
        ],
      );
    });

    group('SignOutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Unauthenticated] when SignOutRequested is successful',
        build: () {
          when(() => authRepository.signOut()).thenAnswer((_) async {});
          return authBloc;
        },
        act: (bloc) => bloc.add(SignOutRequested()),
        expect: () => <AuthState>[
          AuthLoading(),
          const Unauthenticated(),
        ],
        verify: (_) {
          verify(() => authRepository.signOut()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, Unauthenticated(error)] when SignOutRequested fails',
        build: () {
          when(() => authRepository.signOut())
              .thenThrow(Exception('Failed to sign out'));
          return authBloc;
        },
        act: (bloc) => bloc.add(SignOutRequested()),
        expect: () => <AuthState>[
          AuthLoading(),
          const Unauthenticated(error: 'Exception: Failed to sign out'),
        ],
      );
    });

    group('Events and States equatable properties', () {
      test('AuthStarted props are correct', () {
        expect(AuthStarted().props, []);
      });

      test('SignInRequested props are correct', () {
        expect(const SignInRequested(tEmail, tPassword).props, [tEmail, tPassword]);
      });

      test('SignOutRequested props are correct', () {
        expect(SignOutRequested().props, []);
      });

      test('AuthInitial props are correct', () {
        expect(AuthInitial().props, []);
      });

      test('AuthLoading props are correct', () {
        expect(AuthLoading().props, []);
      });

      test('Authenticated props are correct', () {
        expect(const Authenticated(tUser).props, [tUser]);
      });

      test('Unauthenticated props are correct', () {
        expect(const Unauthenticated(error: 'error').props, ['error']);
      });
    });
  });
}
