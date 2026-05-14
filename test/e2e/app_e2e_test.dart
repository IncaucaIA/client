import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:incauca_labs/core/config.dart';
import 'package:incauca_labs/core/service_locator.dart';
import 'package:incauca_labs/main.dart';
import 'package:incauca_labs/features/auth/application/bloc/auth_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:incauca_labs/firebase_options.dart';
import 'e2e_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    if (getIt.isRegistered<AuthBloc>()) {
      await getIt.reset();
    }
    
    final environment = const String.fromEnvironment('ENVIRONMENT', defaultValue: 'local');
    AppConfig.setEnvironmentForTesting(environment);
    AppConfig.initialize();

    if (environment == 'cloud') {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } catch (e) {
        // Already initialized
      }
    }
    
    setupServiceLocator();
  });

  Future<void> login(WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    final emailField = find.byKey(const Key('signIn_emailInput'));
    final passwordField = find.byKey(const Key('signIn_passwordInput'));
    final submitBtn = find.byKey(const Key('signIn_submitButton'));

    await tester.enterText(emailField, E2EConfig.testEmail);
    await tester.enterText(passwordField, E2EConfig.testPassword);
    await tester.tap(submitBtn);

    // Increase timeout for API call
    await tester.pumpAndSettle(const Duration(seconds: 15));
  }

  group('E2E Tests', () {
    testWidgets('login_success_shows_filter_list', (WidgetTester tester) async {
      await tester.pumpWidget(const MainApp());
      await tester.pumpAndSettle();

      expect(find.text('Bienvenido a SIVIA'), findsOneWidget);
      expect(find.byKey(const Key('signIn_submitButton')), findsOneWidget);

      await tester.enterText(find.byKey(const Key('signIn_emailInput')), E2EConfig.testEmail);
      await tester.enterText(find.byKey(const Key('signIn_passwordInput')), E2EConfig.testPassword);
      await tester.tap(find.byKey(const Key('signIn_submitButton')));

      // Wait for login
      await tester.pumpAndSettle(const Duration(seconds: 15));

      expect(find.text('Registros'), findsWidgets);
      expect(find.textContaining('Filtro #'), findsWidgets);
      expect(find.byKey(const Key('filterList_logoutButton')), findsOneWidget);
    });

    testWidgets('login_failure_shows_error', (WidgetTester tester) async {
      await tester.pumpWidget(const MainApp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('signIn_emailInput')), 'wrong@test.com');
      await tester.enterText(find.byKey(const Key('signIn_passwordInput')), 'wrongpassword');
      await tester.tap(find.byKey(const Key('signIn_submitButton')));

      for (int i = 0; i < 50; i++) {
        await tester.pump(const Duration(milliseconds: 200));
        if (find.byType(SnackBar).evaluate().isNotEmpty) {
          break;
        }
      }

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Bienvenido a SIVIA'), findsOneWidget);
    });

    testWidgets('filter_list_pagination_navigation', (WidgetTester tester) async {
      await login(tester);

      // Verify Page 1
      expect(find.textContaining('Página 1'), findsOneWidget);
      
      final prevBtn = find.widgetWithIcon(IconButton, Icons.chevron_left);
      final nextBtn = find.widgetWithIcon(IconButton, Icons.chevron_right);

      // Next button should exist and we tap it if enabled
      final nextBtnWidget = tester.widget<IconButton>(nextBtn);
      if (nextBtnWidget.onPressed != null) {
        await tester.tap(nextBtn);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        expect(find.textContaining('Página 2'), findsOneWidget);

        // Prev button should now be enabled
        final prevBtnWidget = tester.widget<IconButton>(prevBtn);
        expect(prevBtnWidget.onPressed, isNotNull);

        await tester.tap(prevBtn);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        expect(find.textContaining('Página 1'), findsOneWidget);
      }
    });

    testWidgets('navigate_to_filter_detail', (WidgetTester tester) async {
      await login(tester);

      final filterItem = find.textContaining('Filtro #').first;
      await tester.tap(filterItem);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      expect(find.text('Detalle del Filtro'), findsOneWidget);
      expect(find.text('Sección Efectos'), findsOneWidget);
      expect(find.text('Primer Efecto'), findsOneWidget);
      expect(find.text('Otros Resultados'), findsOneWidget);

      final backButton = find.byType(BackButton);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(find.text('Registros'), findsWidgets);
    });

    testWidgets('logout_returns_to_sign_in', (WidgetTester tester) async {
      await login(tester);

      final logoutBtn = find.byKey(const Key('filterList_logoutButton'));
      await tester.tap(logoutBtn);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Bienvenido a SIVIA'), findsOneWidget);
      expect(find.byKey(const Key('signIn_submitButton')), findsOneWidget);
    });

    testWidgets('tab_navigation_records_and_notifications', (WidgetTester tester) async {
      await login(tester);

      expect(find.text('Registros'), findsWidgets);

      final notificationsTab = find.text('Notificaciones');
      await tester.tap(notificationsTab);
      await tester.pumpAndSettle();

      // Title should change
      expect(find.descendant(of: find.byType(AppBar), matching: find.text('Notificaciones')), findsOneWidget);

      final recordsTab = find.text('Registros').last; // BottomNavigationBarItem
      await tester.tap(recordsTab);
      await tester.pumpAndSettle();

      expect(find.descendant(of: find.byType(AppBar), matching: find.text('Registros')), findsOneWidget);
    });
  });
}
