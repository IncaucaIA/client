import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:incauca_labs/core/config.dart';
import 'package:incauca_labs/features/filters/domain/websocket_datasource.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class AzureWebSocketDatasourceImpl implements WebSocketDatasource {
  final http.Client httpClient;
  WebSocketChannel? _channel;
  final StreamController<String> _messageController =
      StreamController<String>.broadcast();
  bool _isConnected = false;

  AzureWebSocketDatasourceImpl({required this.httpClient});

  @override
  Future<void> connect() async {
    try {
      final clientUrl = await _getClientUrl();
      _channel = WebSocketChannel.connect(Uri.parse(clientUrl));
      _isConnected = true;

      _channel!.stream.listen(
        (message) {
          print('📩 Azure Web PubSub message: $message');
          _messageController.add(message.toString());
        },
        onError: (error) {
          print('❌ Azure WebSocket error: $error');
          _isConnected = false;
        },
        onDone: () {
          print('🔌 Azure WebSocket closed');
          _isConnected = false;
        },
      );
      print('✅ Connected to Azure Web PubSub');
    } catch (e) {
      _isConnected = false;
      throw Exception('Failed to connect to Azure WebSocket: $e');
    }
  }

  Future<String> _getClientUrl() async {
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();

    final response = await httpClient.get(
      Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.negotiateEndpoint}'),
      headers: {
        if (idToken != null) 'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['url'] as String;
    } else {
      throw Exception('Failed to negotiate Azure WebSocket: ${response.statusCode}');
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
