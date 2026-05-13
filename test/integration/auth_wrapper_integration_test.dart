import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:incauca_labs/main.dart';
import 'package:incauca_labs/features/auth/application/bloc/auth_bloc.dart';
import 'package:incauca_labs/features/auth/application/bloc/auth_event.dart';
import 'package:incauca_labs/features/auth/application/bloc/auth_state.dart';
import 'package:incauca_labs/features/auth/application/views/sign_in_view.dart';
import 'package:incauca_labs/features/auth/domain/entities/app_user.dart';
import 'package:incauca_labs/features/filters/list/views/filter_list_view.dart';
import 'package:incauca_labs/features/filters/notifications/bloc/notifications_bloc.dart';
import 'package:incauca_labs/features/filters/notifications/bloc/notifications_event.dart';
import 'package:incauca_labs/features/filters/notifications/bloc/notifications_state.dart';
import 'package:incauca_labs/features/filters/domain/models/filter_detail.dart';
import 'package:incauca_labs/features/filters/list/bloc/filter_list_bloc.dart';
import 'package:incauca_labs/features/filters/list/bloc/filter_list_event.dart';
import 'package:incauca_labs/features/filters/list/bloc/filter_list_state.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}
class MockNotificationsBloc extends MockBloc<NotificationsEvent, NotificationsState> implements NotificationsBloc {}
class MockFilterListBloc extends MockBloc<FilterListEvent, FilterListState> implements FilterListBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockNotificationsBloc mockNotificationsBloc;
  late MockFilterListBloc mockFilterListBloc;

  setUpAll(() {
    registerFallbackValue(AuthInitial());
    registerFallbackValue(const NotificationsState());
    registerFallbackValue(FilterListState.initial());
  });

  setUp(() async {
    mockAuthBloc = MockAuthBloc();
    mockNotificationsBloc = MockNotificationsBloc();
    mockFilterListBloc = MockFilterListBloc();
    
    await GetIt.instance.reset();
    GetIt.instance.registerFactory<FilterListBloc>(() => mockFilterListBloc);
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: mockAuthBloc),
          BlocProvider<NotificationsBloc>.value(value: mockNotificationsBloc),
        ],
        child: const Scaffold(body: AuthWrapper()),
      ),
    );
  }

  group('AuthWrapper Integration Tests (Test 8)', () {
    testWidgets('Test 8: AuthWrapper navega correctamente según estados de AuthBloc y muestra snackbar', (tester) async {
      final authStreamController = StreamController<AuthState>.broadcast();
      final notificationsStreamController = StreamController<NotificationsState>.broadcast();

      when(() => mockAuthBloc.state).thenReturn(AuthInitial());
      when(() => mockAuthBloc.stream).thenAnswer((_) => authStreamController.stream);

      when(() => mockNotificationsBloc.state).thenReturn(const NotificationsState());
      when(() => mockNotificationsBloc.stream).thenAnswer((_) => notificationsStreamController.stream);

      when(() => mockFilterListBloc.state).thenReturn(FilterListState.initial());
      when(() => mockFilterListBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(buildTestWidget());

      // 1. AuthInitial -> Loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 2. Unauthenticated -> SignInView
      when(() => mockAuthBloc.state).thenReturn(const Unauthenticated());
      authStreamController.add(const Unauthenticated());
      await tester.pump();

      expect(find.byType(SignInView), findsOneWidget);

      // 3. AuthLoading -> SignInView should remain visible
      when(() => mockAuthBloc.state).thenReturn(AuthLoading());
      authStreamController.add(AuthLoading());
      await tester.pump();

      expect(find.byType(SignInView), findsOneWidget);

      // 4. Authenticated -> FilterListView
      final user = const AppUser(uid: '1');
      when(() => mockAuthBloc.state).thenReturn(Authenticated(user));
      authStreamController.add(Authenticated(user));
      await tester.pump();

      expect(find.byType(FilterListView), findsOneWidget);

      // 5. NotificationsBloc emite nueva notificación -> SnackBar
      final newNotification = FilterDetail(
        id: '123',
        imageUrl: 'http://test.com/img.png',
        impurityCount: 0,
        metal: 0,
        other: 0,
        firstEffect: 0,
        secondAndThirdEffect: 0,
        fourthEffect: 0,
        fifthEffect: 0,
        quality: 1,
        processedAt: DateTime.now(),
      );

      when(() => mockNotificationsBloc.state).thenReturn(NotificationsState(notifications: [newNotification]));
      notificationsStreamController.add(NotificationsState(notifications: [newNotification]));

      await tester.pump(); // frame for the bloc listener
      await tester.pump(); // frame for snackbar animation

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Nuevos resultados disponibles (#123)'), findsOneWidget);

      await authStreamController.close();
      await notificationsStreamController.close();
    });
  });
}
