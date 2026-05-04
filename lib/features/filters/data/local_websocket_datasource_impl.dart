import 'dart:async';
import 'package:incauca_labs/core/config.dart';
import 'package:incauca_labs/features/filters/domain/websocket_datasource.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

class LocalWebSocketDatasourceImpl implements WebSocketDatasource {
  final http.Client httpClient;
  WebSocketChannel? _channel;
  final StreamController<String> _messageController =
      StreamController<String>.broadcast();
  bool _isConnected = false;

  LocalWebSocketDatasourceImpl({required this.httpClient});

  @override
  Future<void> connect() async {
    try {
      final clientUrl = AppConfig.wsEndpoint!;
      _channel = WebSocketChannel.connect(Uri.parse(clientUrl));
      _isConnected = true;

      _channel!.stream.listen(
        (message) {
          print('📩 Local WebSocket message: $message');
          _messageController.add(message.toString());
        },
        onError: (error) {
          print('❌ Local WebSocket error: $error');
          _isConnected = false;
        },
        onDone: () {
          print('🔌 Local WebSocket closed');
          _isConnected = false;
        },
      );
      print('✅ Connected to Local WebSocket');
    } catch (e) {
      _isConnected = false;
      throw Exception('Failed to connect to Local WebSocket: $e');
    }
  }

  @override
  Stream<String> getMessageStream() => _messageController.stream;

  @override
  Future<void> disconnect() async {
    await _channel?.sink.close();
    _isConnected = false;
  }

  @override
  bool get isConnected => _isConnected;

  void dispose() {
    _messageController.close();
    disconnect();
  }
}
