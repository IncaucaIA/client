abstract class WebSocketDatasource {
  /// Connects to Azure Web PubSub via the negotiate endpoint
  Future<void> connect();

  /// Returns a stream of messages received from the WebSocket
  Stream<String> getMessageStream();

  /// Disconnects from the WebSocket
  Future<void> disconnect();

  /// Returns whether the WebSocket is currently connected
  bool get isConnected;
}
