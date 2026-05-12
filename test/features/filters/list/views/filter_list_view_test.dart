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

  testWidgets('opens filter sheet when filter icon is pressed', (tester) async {
    when(() => mockFilterListBloc.state).thenReturn(FilterListState.initial());

    await tester.pumpWidget(buildTestableWidget());
    
    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();

    expect(find.text('Filtros'), findsOneWidget);
    expect(find.text('Rango de fechas'), findsOneWidget);
  });
}
