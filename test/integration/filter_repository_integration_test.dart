import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:incauca_labs/core/config.dart';
import 'package:incauca_labs/features/filters/data/filter_repository_impl.dart';
import 'package:incauca_labs/features/filters/domain/websocket_datasource.dart';
import 'package:incauca_labs/features/filters/domain/models/filter_detail.dart';
import 'package:incauca_labs/features/filters/domain/models/paginated_result.dart';

class MockHttpClient extends Mock implements http.Client {}
class MockWebSocketDatasource extends Mock implements WebSocketDatasource {}

void main() {
  late MockHttpClient mockHttpClient;
  late MockWebSocketDatasource mockWebSocketDatasource;
  late FilterRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    mockWebSocketDatasource = MockWebSocketDatasource();
    
    // Set AppConfig to local to avoid Firebase Auth
    AppConfig.setEnvironmentForTesting('local');
    AppConfig.initialize();
    
    repository = FilterRepositoryImpl(
      webSocketDataSource: mockWebSocketDatasource,
      httpClient: mockHttpClient,
      tokenProvider: () async => 'test_token',
    );
  });

  group('FilterRepository Integration Tests (Test 3 & 4)', () {
    test('Test 3: FilterRepositoryImpl.getFilters parsea respuesta HTTP paginada correctamente', () async {
      // JSON type 1: impurityDetection
      final jsonResponse1 = {
        'items': [
          {
            'imageId': '1',
            'createdAt': '2026-05-12T10:00:00Z',
            'status': 'processed',
            'impurityDetection': {
              'overallPurity': 0.95,
              'anomaliesCount': 2
            }
          }
        ],
        'total': 100,
        'limit': 10,
        'offset': 0
      };

      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(jsonEncode(jsonResponse1), 200));

      final result1 = await repository.getFilters(limit: 10, offset: 0, startDate: '2026-01-01');

      expect(result1.items.length, 1);
      expect(result1.total, 100);
      expect(result1.offset, 0);
      expect(result1.items.first.id, '1');
      // Verify query params
      final capturedUri = verify(() => mockHttpClient.get(captureAny(), headers: any(named: 'headers'))).captured.first as Uri;
      expect(capturedUri.queryParameters['limit'], '10');
      expect(capturedUri.queryParameters['offset'], '0');
      expect(capturedUri.queryParameters['startDate'], '2026-01-01');

      // JSON type 2: legacy (aiResults)
      final jsonResponse2 = {
        'items': [
          {
            'id': '2',
            'createdAt': '2026-05-12T10:00:00Z',
            'status': 'pending',
            'aiResults': [
              {
                'purityScore': 0.88,
              }
            ]
          }
        ],
        'total': 50,
        'limit': 5,
        'offset': 5
      };

      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(jsonEncode(jsonResponse2), 200));

      final result2 = await repository.getFilters(limit: 5, offset: 5);
      expect(result2.items.length, 1);
      expect(result2.items.first.id, '2');
      expect(result2.total, 50);
    });

    test('Test 4: FilterRepositoryImpl.watchFilters emite initial + updates via WebSocket', () async {
      final jsonResponse1 = {
        'items': [{'id': '1', 'createdAt': '2026-05-12T10:00:00Z', 'status': 'processed'}],
        'total': 1, 'limit': 10, 'offset': 0
      };
      
      final jsonResponse2 = {
        'items': [
          {'id': '1', 'createdAt': '2026-05-12T10:00:00Z', 'status': 'processed'},
          {'id': '2', 'createdAt': '2026-05-12T10:05:00Z', 'status': 'pending'}
        ],
        'total': 2, 'limit': 10, 'offset': 0
      };

      int callCount = 0;
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async {
            callCount++;
            if (callCount == 1) {
              return http.Response(jsonEncode(jsonResponse1), 200);
            } else {
              return http.Response(jsonEncode(jsonResponse2), 200);
            }
          });

      final wsController = StreamController<String>();
      when(() => mockWebSocketDatasource.getMessageStream())
          .thenAnswer((_) => wsController.stream);

      final stream = repository.watchFilters(limit: 10, offset: 0);

      expectLater(
        stream,
        emitsInOrder([
          isA<PaginatedResult<FilterDetail>>().having((r) => (r as PaginatedResult<FilterDetail>).items.length, 'length', 1),
          isA<PaginatedResult<FilterDetail>>().having((r) => (r as PaginatedResult<FilterDetail>).items.length, 'length', 2),
        ]),
      );

      // Give time for initial fetch
      await Future.delayed(const Duration(milliseconds: 100));

      // Trigger WS notification
      wsController.add('update_notification');

      await Future.delayed(const Duration(milliseconds: 100));
      await wsController.close();
    });
  });
}
