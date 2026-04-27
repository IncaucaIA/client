import 'dart:io';
import 'models/image_document.dart';

abstract class FilterRepository {
  /// Uploads an image with metadata to Azure
  /// 1. Uploads image to Blob Storage
  /// 2. Creates document in Cosmos DB with image URL
  /// Returns the created document
  Future<ImageDocument> uploadImageWithMetadata({
    required File image,
    required String userId,
    List<String> tags = const [],
  });

  /// Returns a stream of real-time notifications from Web PubSub
  Stream<String> listenToNotifications();

  /// Connects to the WebSocket for real-time notifications
  Future<void> connectToNotifications();

  /// Disconnects from the WebSocket
  Future<void> disconnectFromNotifications();
}