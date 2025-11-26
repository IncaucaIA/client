import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:incauca_labs/core/config.dart';
import 'package:incauca_labs/filters/upload/domain/websocket_datasource.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketDatasourceImpl implements WebSocketDatasource {
  final http.Client httpClient;
  WebSocketChannel? _channel;
  final StreamController<String> _messageController =
      StreamController<String>.broadcast();
  bool _isConnected = false;

  WebSocketDatasourceImpl({required this.httpClient});

  @override
  Future<void> connect() async {
    try {
      // Get the WebSocket URL from the negotiate endpoint
      final clientUrl = await _getClientUrl();

      // Connect to the WebSocket
      _channel = WebSocketChannel.connect(Uri.parse(clientUrl));

      _isConnected = true;

      // Listen to messages and forward them to the stream
      _channel!.stream.listen(
        (message) {
          print('📩 WebSocket message received: $message');
          _messageController.add(message.toString());
        },
        onError: (error) {
          print('❌ WebSocket error: $error');
          _isConnected = false;
        },
        onDone: () {
          print('🔌 WebSocket connection closed');
          _isConnected = false;
        },
      );

      print('✅ Connected to Web PubSub');
    } catch (e) {
      _isConnected = false;
      throw Exception('Failed to connect to WebSocket: $e');
    }
  }

  Future<String> _getClientUrl() async {
    try {
      final response = await httpClient.get(
        Uri.parse(AzureConfig.apiBaseUrl + AzureConfig.negotiateEndpoint),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'] as String;
      } else {
        throw Exception(
          'Failed to get client URL: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to negotiate WebSocket connection: $e');
    }
  }

  @override
  Stream<String> getMessageStream() {
    return _messageController.stream;
  }

  @override
  Future<void> disconnect() async {
    await _channel?.sink.close();
    _isConnected = false;
    print('🔌 Disconnected from Web PubSub');
  }

  @override
  bool get isConnected => _isConnected;

  void dispose() {
    _messageController.close();
    disconnect();
  }
}
