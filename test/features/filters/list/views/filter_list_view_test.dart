import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:incauca_labs/features/auth/application/bloc/auth_bloc.dart';
import 'package:incauca_labs/features/auth/application/bloc/auth_event.dart';
import 'package:incauca_labs/features/auth/application/bloc/auth_state.dart';
import 'package:incauca_labs/features/filters/domain/models/filter_detail.dart';
import 'package:incauca_labs/features/filters/list/bloc/filter_list_bloc.dart';
import 'package:incauca_labs/features/filters/list/bloc/filter_list_event.dart';
import 'package:incauca_labs/features/filters/list/bloc/filter_list_state.dart';
import 'package:incauca_labs/features/filters/list/views/filter_list_view.dart';
import 'package:incauca_labs/features/filters/notifications/bloc/notifications_bloc.dart';
import 'package:incauca_labs/features/filters/notifications/bloc/notifications_event.dart';
import 'package:incauca_labs/features/filters/notifications/bloc/notifications_state.dart';
import 'package:incauca_labs/features/filters/detail/views/filter_detail_view.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}
class MockFilterListBloc extends MockBloc<FilterListEvent, FilterListState> implements FilterListBloc {}
class MockNotificationsBloc extends MockBloc<NotificationsEvent, NotificationsState> implements NotificationsBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockFilterListBloc mockFilterListBloc;
  late MockNotificationsBloc mockNotificationsBloc;

  setUpAll(() {
    registerFallbackValue(FilterListSubscriptionRequested());
    registerFallbackValue(FilterListRefreshRequested());
    registerFallbackValue(const FilterListPageChanged(0));
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockFilterListBloc = MockFilterListBloc();
    mockNotificationsBloc = MockNotificationsBloc();

    final getIt = GetIt.instance;
    getIt.allowReassignment = true;
    getIt.registerFactory<FilterListBloc>(() => mockFilterListBloc);
    getIt.registerFactory<AuthBloc>(() => mockAuthBloc);
    getIt.registerFactory<NotificationsBloc>(() => mockNotificationsBloc);

    when(() => mockAuthBloc.state).thenReturn(AuthInitial());
    when(() => mockFilterListBloc.state).thenReturn(FilterListState.initial());
    when(() => mockNotificationsBloc.state).thenReturn(const NotificationsState(notifications: []));
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  Widget buildTestableWidget() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: mockAuthBloc),
        BlocProvider<NotificationsBloc>.value(value: mockNotificationsBloc),
      ],
      child: const MaterialApp(
        home: FilterListView(),
      ),
    );
  }

  testWidgets('renders FilterListView and shows loading indicator', (tester) async {
    when(() => mockFilterListBloc.state).thenReturn(
      FilterListState.initial().copyWith(isLoading: true),
    );

    await tester.pumpWidget(buildTestableWidget());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows error message when state has error', (tester) async {
    when(() => mockFilterListBloc.state).thenReturn(
      FilterListState.initial().copyWith(error: 'Some error'),
    );

    await tester.pumpWidget(buildTestableWidget());

    expect(find.text('Error: Some error'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('renders list of filters when state has filters', (tester) async {
    final detail = FilterDetail(
      id: '1',
      imageUrl: 'url',
      impurityCount: 10,
      metal: 1,
      other: 2,
      firstEffect: 1,
      secondAndThirdEffect: 2,
      fourthEffect: 1,
      fifthEffect: 1,
      quality: 90,
      processedAt: DateTime(2024, 5, 4),
    );

    when(() => mockFilterListBloc.state).thenReturn(
      FilterListState.initial().copyWith(filters: [detail], total: 1),
    );

    await tester.pumpWidget(buildTestableWidget());

    expect(find.text('Filtro #1'), findsOneWidget);
    expect(find.textContaining('Impurezas: 10'), findsOneWidget);
  });

  testWidgets('shows empty message when no filters found', (tester) async {
    when(() => mockFilterListBloc.state).thenReturn(
      FilterListState.initial().copyWith(filters: []),
    );

    await tester.pumpWidget(buildTestableWidget());

    expect(find.text('Sin resultados para los filtros aplicados.'), findsOneWidget);
  });

  testWidgets('navigates to detail when a filter is tapped', (tester) async {
    final detail = FilterDetail(
      id: '1',
      imageUrl: 'url',
      impurityCount: 10,
      metal: 1,
      other: 2,
      firstEffect: 1,
      secondAndThirdEffect: 2,
      fourthEffect: 1,
      fifthEffect: 1,
      quality: 90,
      processedAt: DateTime(2024, 5, 4),
    );

    when(() => mockFilterListBloc.state).thenReturn(
      FilterListState.initial().copyWith(filters: [detail], total: 1),
    );

    await tester.pumpWidget(buildTestableWidget());
    await tester.tap(find.text('Filtro #1'));
    await tester.pumpAndSettle();

    expect(find.byType(FilterDetailView), findsOneWidget);
  });

  testWidgets('adds SignOutRequested when logout button is pressed', (tester) async {
    when(() => mockFilterListBloc.state).thenReturn(FilterListState.initial());
    await tester.pumpWidget(buildTestableWidget());
    
    await tester.tap(find.byIcon(Icons.logout));
    verify(() => mockAuthBloc.add(SignOutRequested())).called(1);
  });

  testWidgets('adds FilterListPageChanged when pagination buttons are pressed', (tester) async {
    final initialState = FilterListState.initial().copyWith(
      filters: List.generate(10, (i) => FilterDetail(
        id: '$i',
        imageUrl: 'url',
        impurityCount: i,
        metal: 1,
        other: 2,
        firstEffect: 1,
        secondAndThirdEffect: 2,
        fourthEffect: 1,
        fifthEffect: 1,
        quality: 90,
        processedAt: DateTime(2024, 5, 4),
      )),
      total: 25,
      currentPage: 0,
    );

    final streamController = StreamController<FilterListState>.broadcast();
    when(() => mockFilterListBloc.state).thenReturn(initialState);
    when(() => mockFilterListBloc.stream).thenAnswer((_) => streamController.stream);

    await tester.pumpWidget(buildTestableWidget());
    
    // Test Next Page
    await tester.tap(find.byTooltip('Siguiente'));
    verify(() => mockFilterListBloc.add(const FilterListPageChanged(1))).called(1);

    // Update state via stream to enable Previous Page button
    final nextState = initialState.copyWith(currentPage: 1);
    when(() => mockFilterListBloc.state).thenReturn(nextState);
    streamController.add(nextState);
    await tester.pumpAndSettle();
    
    await tester.tap(find.byTooltip('Anterior'));
    verify(() => mockFilterListBloc.add(const FilterListPageChanged(0))).called(1);
    
    await streamController.close();
  });

  testWidgets('triggers refresh when pulled', (tester) async {
    when(() => mockFilterListBloc.state).thenReturn(
      FilterListState.initial().copyWith(
        filters: [FilterDetail(
          id: '1',
          imageUrl: 'url',
          impurityCount: 10,
          metal: 1,
          other: 2,
          firstEffect: 1,
          secondAndThirdEffect: 2,
          fourthEffect: 1,
          fifthEffect: 1,
          quality: 90,
          processedAt: DateTime(2024, 5, 4),
        )],
      ),
    );

    await tester.pumpWidget(buildTestableWidget());
    
    await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    verify(() => mockFilterListBloc.add(FilterListRefreshRequested())).called(1);
  });

  testWidgets('interacts with filter sheet: Apply and Clear', (tester) async {
    when(() => mockFilterListBloc.state).thenReturn(FilterListState.initial());
    await tester.pumpWidget(buildTestableWidget());
    
    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();

    // Tap Apply
    await tester.tap(find.text('Aplicar'));
    await tester.pumpAndSettle();
    verify(() => mockFilterListBloc.add(any(that: isA<FilterListFiltersApplied>()))).called(1);

    // Open again to tap Clear
    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Limpiar'));
    await tester.pumpAndSettle();
    verify(() => mockFilterListBloc.add(FilterListFiltersCleared())).called(1);
  });

  testWidgets('switches tabs using BottomNavigationBar', (tester) async {
    when(() => mockFilterListBloc.state).thenReturn(FilterListState.initial());
    await tester.pumpWidget(buildTestableWidget());
    
    await tester.tap(find.text('Notificaciones'));
    await tester.pumpAndSettle();
    
    expect(find.text('No hay notificaciones recientes'), findsOneWidget);
    expect(find.text('Notificaciones'), findsNWidgets(2)); // Title and Label
  });

  testWidgets('deletes filter from active filters bar', (tester) async {
    final now = DateTime(2024, 5, 4);
    when(() => mockFilterListBloc.state).thenReturn(
      FilterListState.initial().copyWith(startDate: now),
    );
    
    await tester.pumpWidget(buildTestableWidget());
    
    expect(find.byType(Chip), findsOneWidget);
    
    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pumpAndSettle();
    
    verify(() => mockFilterListBloc.add(any(that: isA<FilterListFiltersApplied>()))).called(1);
  });
}

