import 'dart:convert';
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
  late FilterRepositoryImpl repository;
  late MockHttpClient mockHttpClient;
  late MockWebSocketDatasource mockWebSocketDatasource;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    AppConfig.initialize();
    
    mockHttpClient = MockHttpClient();
    mockWebSocketDatasource = MockWebSocketDatasource();
    repository = FilterRepositoryImpl(
      webSocketDataSource: mockWebSocketDatasource,
      httpClient: mockHttpClient,
    );

    registerFallbackValue(Uri());
  });

  group('FilterRepositoryImpl', () {
    test('getFilters returns PaginatedResult on 200', () async {
      // Arrange
      final mockResponse = {
        'items': [
          {
            'id': '1',
            'image': {'url': 'url1', 'uploadedAt': '2024-05-04T10:00:00Z'},
            'aiResults': [{'impurityCount': 5}]
          }
        ],
        'total': 1,
        'limit': 10,
        'offset': 0,
      };

      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      // Act
      final result = await repository.getFilters();

      // Assert
      expect(result, isA<PaginatedResult<FilterDetail>>());
      expect(result.items.length, 1);
      expect(result.items.first.id, '1');
      verify(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).called(1);
    });

    test('getFilters throws exception on non-200', () async {
      // Arrange
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('Error', 404));

      // Act & Assert
      expect(repository.getFilters(), throwsA(isA<Exception>()));
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
  });
}
