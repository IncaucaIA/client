import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:incauca_labs/features/filters/data/local_websocket_datasource_impl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:incauca_labs/core/config.dart';

class MockHttpClient extends Mock implements http.Client {}
class MockWebSocketChannel extends Mock implements WebSocketChannel {}
class MockWebSocketSink extends Mock implements WebSocketSink {}

void main() {
  late LocalWebSocketDatasourceImpl datasource;
  late MockHttpClient mockHttpClient;
  late MockWebSocketChannel mockChannel;
  late MockWebSocketSink mockSink;
  late StreamController<dynamic> streamController;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'token': 'test_token'});
    AppConfig.initialize();
    
    mockHttpClient = MockHttpClient();
    mockChannel = MockWebSocketChannel();
    mockSink = MockWebSocketSink();
    streamController = StreamController<dynamic>();

    when(() => mockChannel.stream).thenAnswer((_) => streamController.stream);
    when(() => mockChannel.sink).thenReturn(mockSink);
    when(() => mockSink.close()).thenAnswer((_) async => null);

    datasource = LocalWebSocketDatasourceImpl(
      httpClient: mockHttpClient,
      channelFactory: (uri, headers) => mockChannel,
    );
  });

  tearDown(() {
    streamController.close();
    datasource.dispose();
  });

  group('LocalWebSocketDatasourceImpl', () {
    test('connect establishes connection and listens to messages', () async {
      await datasource.connect();
      expect(datasource.isConnected, true);
      
      final stream = datasource.getMessageStream();
      final expectations = expectLater(stream, emitsInOrder(['msg1', 'msg2']));
      
      streamController.add('msg1');
      streamController.add('msg2');
      
      await expectations;
    });

    test('disconnect closes channel sink', () async {
      await datasource.connect();
      await datasource.disconnect();
      expect(datasource.isConnected, false);
      verify(() => mockSink.close()).called(1);
    });

    test('handles stream error', () async {
      await datasource.connect();
      streamController.addError('error');
      // Wait for the error to be processed internally
      await Future.delayed(Duration.zero);
      expect(datasource.isConnected, false);
    });

    test('handles stream done', () async {
      await datasource.connect();
      await streamController.close();
      await Future.delayed(Duration.zero);
      expect(datasource.isConnected, false);
    });
  });
}
