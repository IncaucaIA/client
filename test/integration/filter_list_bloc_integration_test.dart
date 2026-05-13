import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:incauca_labs/core/config.dart';
import 'package:incauca_labs/features/filters/data/filter_repository_impl.dart';
import 'package:incauca_labs/features/filters/domain/websocket_datasource.dart';
import 'package:incauca_labs/features/filters/list/bloc/filter_list_bloc.dart';
import 'package:incauca_labs/features/filters/list/bloc/filter_list_event.dart';
import 'package:incauca_labs/features/filters/list/bloc/filter_list_state.dart';

class MockHttpClient extends Mock implements http.Client {}
class MockWebSocketDatasource extends Mock implements WebSocketDatasource {}

void main() {
  late MockHttpClient mockHttpClient;
  late MockWebSocketDatasource mockWebSocketDatasource;
  late FilterRepositoryImpl repository;
  late FilterListBloc bloc;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    mockWebSocketDatasource = MockWebSocketDatasource();
    
    AppConfig.setEnvironmentForTesting('local');
    AppConfig.initialize();
    
    repository = FilterRepositoryImpl(
      webSocketDataSource: mockWebSocketDatasource,
      httpClient: mockHttpClient,
      tokenProvider: () async => 'test_token',
    );

    bloc = FilterListBloc(filterRepository: repository);

    when(() => mockWebSocketDatasource.connect()).thenAnswer((_) async {});
    when(() => mockWebSocketDatasource.disconnect()).thenAnswer((_) async {});
    when(() => mockWebSocketDatasource.getMessageStream()).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() {
    bloc.close();
  });

  group('FilterListBloc Integration Tests (Test 5)', () {
    test('Test 5: FilterListBloc integra paginación + filtros con repository real', () async {
      // 1. Setup mock response for initial fetch (offset=0)
      final jsonResponsePage0 = {
        'items': List.generate(5, (i) => {'id': 'item_$i', 'createdAt': '2026-05-12T10:00:00Z', 'status': 'processed'}),
        'total': 12,
        'limit': 5,
        'offset': 0
      };

      when(() => mockHttpClient.get(any(that: predicate<Uri>((uri) => uri.queryParameters['offset'] == '0')), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(jsonEncode(jsonResponsePage0), 200));

      // Dispatch SubscriptionRequested
      bloc.add(FilterListSubscriptionRequested());
      
      // We expect loading then loaded with 5 items
      await expectLater(
        bloc.stream,
        emitsThrough(isA<FilterListState>().having((s) => s.filters.length, 'filters length', 5)
                                          .having((s) => s.isLoading, 'isLoading', false)),
      );

      // 2. Mock for page 1 (offset=10)
      final jsonResponsePage1 = {
        'items': List.generate(2, (i) => {'id': 'item_page1_$i', 'createdAt': '2026-05-12T10:00:00Z', 'status': 'processed'}),
        'total': 12,
        'limit': 5,
        'offset': 5
      };

      when(() => mockHttpClient.get(any(that: predicate<Uri>((uri) => uri.queryParameters['offset'] == '5')), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(jsonEncode(jsonResponsePage1), 200));

      // Dispatch PageChanged
      bloc.add(const FilterListPageChanged(1));

      // Wait until items length is 2 (new page)
      await expectLater(
        bloc.stream,
        emitsThrough(isA<FilterListState>().having((s) => s.filters.length, 'filters length', 2)
                                          .having((s) => s.offset, 'offset', 5)),
      );

      // 3. Mock for FiltersApplied (startDate=Jan1)
      final date = DateTime(2026, 1, 1);
      final dateIso = date.toIso8601String();
      
      final jsonResponseFiltered = {
        'items': [{'id': 'filtered_1', 'createdAt': '2026-05-12T10:00:00Z', 'status': 'processed'}],
        'total': 1,
        'limit': 5,
        'offset': 0
      };

      when(() => mockHttpClient.get(
        any(that: predicate<Uri>((uri) => uri.queryParameters['startDate'] != null && uri.queryParameters['offset'] == '0')), 
        headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response(jsonEncode(jsonResponseFiltered), 200));

      // Dispatch FiltersApplied
      bloc.add(FilterListFiltersApplied(startDate: date));

      await expectLater(
        bloc.stream,
        emitsThrough(isA<FilterListState>().having((s) => s.filters.length, 'filters length', 1)
                                          .having((s) => s.startDate, 'startDate', date)
                                          .having((s) => s.currentPage, 'currentPage', 0)),
      );

      // 4. Mock for error
      when(() => mockHttpClient.get(any(that: predicate<Uri>((uri) => uri.queryParameters['offset'] == '0' && uri.queryParameters['startDate'] == null)), headers: any(named: 'headers')))
          .thenThrow(Exception('HTTP Error'));

      bloc.add(FilterListFiltersCleared());

      await expectLater(
        bloc.stream,
        emitsThrough(isA<FilterListState>().having((s) => s.error, 'error', contains('HTTP Error'))
                                          .having((s) => s.isLoading, 'isLoading', false)),
      );
    });
  });
}
