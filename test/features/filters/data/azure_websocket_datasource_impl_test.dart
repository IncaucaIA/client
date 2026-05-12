import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:incauca_labs/features/filters/data/azure_websocket_datasource_impl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'package:incauca_labs/core/config.dart';

class MockHttpClient extends Mock implements http.Client {}
class MockWebSocketChannel extends Mock implements WebSocketChannel {}
class MockWebSocketSink extends Mock implements WebSocketSink {}

void main() {
  late AzureWebSocketDatasourceImpl datasource;
  late MockHttpClient mockHttpClient;
  late MockWebSocketChannel mockChannel;
  late MockWebSocketSink mockSink;
  late StreamController<dynamic> streamController;

  setUp(() async {
    AppConfig.initialize();
    
    mockHttpClient = MockHttpClient();
    mockChannel = MockWebSocketChannel();
    mockSink = MockWebSocketSink();
    streamController = StreamController<dynamic>();

    when(() => mockChannel.stream).thenAnswer((_) => streamController.stream);
    when(() => mockChannel.sink).thenReturn(mockSink);
    when(() => mockSink.close()).thenAnswer((_) async => null);

    datasource = AzureWebSocketDatasourceImpl(
      httpClient: mockHttpClient,
      channelFactory: (uri) => mockChannel,
      tokenProvider: () async => 'test_token',
    );

    registerFallbackValue(Uri());
  });

  tearDown(() {
    streamController.close();
    datasource.dispose();
  });

  group('AzureWebSocketDatasourceImpl', () {
    test('connect negotiates and establishes connection', () async {
      // Negotiate
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(jsonEncode({'url': 'ws://azure.com'}), 200));

      await datasource.connect();
      expect(datasource.isConnected, true);
      
      final stream = datasource.getMessageStream();
      final expectations = expectLater(stream, emitsInOrder(['msg1']));
      
      streamController.add('msg1');
      await expectations;
    });

    test('connect throws exception if negotiation fails', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('Error', 401));

      expect(() => datasource.connect(), throwsA(isA<Exception>()));
      expect(datasource.isConnected, false);
    });

    test('handles stream error', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(jsonEncode({'url': 'ws://azure.com'}), 200));

      await datasource.connect();
      streamController.addError('error');
      await Future.delayed(Duration.zero);
      expect(datasource.isConnected, false);
    });
   group('isConnected', () {
      test('returns true when connected', () async {
        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response(jsonEncode({'url': 'ws://azure.com'}), 200));
        await datasource.connect();
        expect(datasource.isConnected, true);
      });
    });
  });
}
