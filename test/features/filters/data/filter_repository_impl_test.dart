import 'dart:convert';
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:incauca_labs/features/filters/data/filter_repository_impl.dart';
import 'package:incauca_labs/features/filters/domain/models/filter_detail.dart';
import 'package:incauca_labs/features/filters/domain/models/paginated_result.dart';
import 'package:incauca_labs/features/filters/domain/websocket_datasource.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:incauca_labs/core/config.dart';

class MockHttpClient extends Mock implements http.Client {}
class MockWebSocketDatasource extends Mock implements WebSocketDatasource {}

void main() {
  AppConfig.initialize();

  late FilterRepositoryImpl repository;
  late MockHttpClient mockHttpClient;
  late MockWebSocketDatasource mockWebSocketDatasource;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'token': 'test_token'});
    
    mockHttpClient = MockHttpClient();
    mockWebSocketDatasource = MockWebSocketDatasource();
    repository = FilterRepositoryImpl(
      webSocketDataSource: mockWebSocketDatasource,
      httpClient: mockHttpClient,
    );

    registerFallbackValue(Uri());
  });

  group('FilterRepositoryImpl', () {
    final mockFilterJson = {
      'id': '1',
      'image': {'url': 'url1', 'uploadedAt': '2024-05-04T00:00:00.000'},
      'aiResults': [{
        'impurityCount': 5,
        'metal': 1,
        'other': 2,
        'firstEffect': 1,
        'secondAndThirdEffect': 2,
        'fourthEffect': 1,
        'fifthEffect': 1,
        'quality': 90,
      }],
    };

    final mockResponse = {
      'items': [mockFilterJson],
      'total': 1,
      'limit': 10,
      'offset': 0,
    };

    test('getFilters returns PaginatedResult on 200 with query params', () async {
      // Arrange
      when(() => mockHttpClient.get(
        any(that: predicate<Uri>((uri) {
          return uri.queryParameters['limit'] == '5' &&
                 uri.queryParameters['offset'] == '10' &&
                 uri.queryParameters['startDate'] == '2024-05-01' &&
                 uri.queryParameters['endDate'] == '2024-05-31';
        })),
        headers: any(named: 'headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      // Act
      final result = await repository.getFilters(
        limit: 5,
        offset: 10,
        startDate: '2024-05-01',
        endDate: '2024-05-31',
      );

      // Assert
      expect(result, isA<PaginatedResult<FilterDetail>>());
      expect(result.items.length, 1);
    });

    test('getFilters throws exception on non-200', () async {
      // Arrange
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('Error message', 404));

      // Act & Assert
      expect(
        () => repository.getFilters(),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Error message'))),
      );
    });

    test('watchFilters yields initial data and updates on notifications', () async {
      // Arrange
      final streamController = StreamController<String>();
      when(() => mockWebSocketDatasource.getMessageStream())
          .thenAnswer((_) => streamController.stream);
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      // Act
      final stream = repository.watchFilters();
      
      // Assert
      final expectations = expectLater(
        stream,
        emitsInOrder([
          isA<PaginatedResult<FilterDetail>>(),
          isA<PaginatedResult<FilterDetail>>(),
        ]),
      );

      streamController.add('update');
      await expectations;
      streamController.close();
    });

    test('listenToNotifications returns stream from datasource', () {
      // Arrange
      final stream = Stream<String>.fromIterable(['msg1', 'msg2']);
      when(() => mockWebSocketDatasource.getMessageStream()).thenAnswer((_) => stream);

      // Act
      final result = repository.listenToNotifications();

      // Assert
      expect(result, emitsInOrder(['msg1', 'msg2']));
    });

    test('connectToNotifications calls datasource connect', () async {
      when(() => mockWebSocketDatasource.connect()).thenAnswer((_) async {});
      await repository.connectToNotifications();
      verify(() => mockWebSocketDatasource.connect()).called(1);
    });

    test('disconnectFromNotifications calls datasource disconnect', () async {
      when(() => mockWebSocketDatasource.disconnect()).thenAnswer((_) async {});
      await repository.disconnectFromNotifications();
      verify(() => mockWebSocketDatasource.disconnect()).called(1);
    });
  });
}
