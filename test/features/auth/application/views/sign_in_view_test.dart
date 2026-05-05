import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:incauca_labs/features/auth/application/bloc/auth_bloc.dart';
import 'package:incauca_labs/features/auth/application/bloc/auth_event.dart';
import 'package:incauca_labs/features/auth/application/bloc/auth_state.dart';
import 'package:incauca_labs/features/auth/application/views/sign_in_view.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class FakeAuthEvent extends Fake implements AuthEvent {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUpAll(() {
    registerFallbackValue(FakeAuthEvent());
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());
  });

  Widget buildSubject() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const SignInView(),
        ),
      ),
    );
  }

  group('SignInView', () {
    testWidgets('renders SignInView correctly', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('Bienvenido a SIVIA'), findsOneWidget);
    });

    testWidgets('shows SnackBar when state is Unauthenticated with error', (tester) async {
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([
          const Unauthenticated(error: 'Invalid credentials'),
        ]),
        initialState: AuthInitial(),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump(); // Allow SnackBar to show
      await tester.pump(const Duration(milliseconds: 100)); // allow animation

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('toggles password visibility when icon is pressed', (tester) async {
      await tester.pumpWidget(buildSubject());

      final passwordField = find.byType(TextFormField).last;
      final textField = find.descendant(of: passwordField, matching: find.byType(TextField));
      expect(tester.widget<TextField>(textField).obscureText, isTrue);

      final visibilityIcon = find.byIcon(Icons.visibility);
      await tester.tap(visibilityIcon);
      await tester.pumpAndSettle();

      expect(tester.widget<TextField>(textField).obscureText, isFalse);

      final visibilityOffIcon = find.byIcon(Icons.visibility_off);
      await tester.tap(visibilityOffIcon);
      await tester.pumpAndSettle();

      expect(tester.widget<TextField>(textField).obscureText, isTrue);
    });

    testWidgets('shows validation errors when form is empty and submitted', (tester) async {
      await tester.pumpWidget(buildSubject());

      final submitButton = find.byType(ElevatedButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Por favor ingresa tu correo'), findsOneWidget);
      expect(find.text('Por favor ingresa tu contraseña'), findsOneWidget);
      verifyNever(() => mockAuthBloc.add(any()));
    });

    testWidgets('adds SignInRequested to AuthBloc when form is valid and submitted', (tester) async {
      await tester.pumpWidget(buildSubject());

      final emailField = find.widgetWithText(TextFormField, 'Correo Electrónico');
      final passwordField = find.widgetWithText(TextFormField, 'Contraseña');

      await tester.enterText(emailField, 'test@test.com');
      await tester.enterText(passwordField, 'password123');

      final submitButton = find.byType(ElevatedButton);
      await tester.tap(submitButton);
      await tester.pump(); // wait for validation

      verify(() => mockAuthBloc.add(const SignInRequested('test@test.com', 'password123'))).called(1);
    });

    testWidgets('disables submit button and shows loading indicator when state is AuthLoading', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthLoading());

      await tester.pumpWidget(buildSubject());

      final submitButton = find.byType(ElevatedButton);
      final buttonWidget = tester.widget<ElevatedButton>(submitButton);
      expect(buttonWidget.enabled, isFalse);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    
    testWidgets('forgot password button can be pressed', (tester) async {
      await tester.pumpWidget(buildSubject());
      final forgotPasswordButton = find.text('¿Olvidaste tu contraseña?');
      await tester.tap(forgotPasswordButton);
      await tester.pump();
    });
  });
}
